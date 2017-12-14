//
//  ASLandingViewController.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 12/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import Foundation
import Alamofire
import AsyncDisplayKit

final class LandingViewController: ASViewController<ASDisplayNode> {
    
    fileprivate typealias FeedsCallback = (_ model: LandingViewModelType) -> ()
    fileprivate var landingViewModel: LandingViewModelType?
    fileprivate var tableDataProvider: FeedTableDataProvider?
    fileprivate var collectionDataProvider: FeedsCollectionDataProvider?
    fileprivate var timer: DispatchSourceTimer?
    fileprivate var tuple = (pageSize: 10, loading: false)

    lazy var tableNode: ASTableNode = {
        let node = ASTableNode()
        node.view.backgroundColor = bg_color
        node.view.allowsSelection = true
        node.view.separatorStyle = .singleLine
        
        return node
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .white
        view.register(cellType: FeedCollectionViewCell.self)
        
        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.stopTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseConfig()
    }
}

//MARK: - Private Methods -
extension LandingViewController {
    
    fileprivate func baseConfig() {
        self.title = "News Feed"
        
        configureNodes()
        configTableDataProvider()
        configCollectionDataProvider()
        setupInitialState()
        startTimer()
    }
    
    fileprivate func setupInitialState() {
        
        if APIHelper.isConnected() {
            getFeeds(showProgressHUD: true) { [weak self] viewModel in
                self?.update(with: viewModel)
            }
        } else {
            guard let landing = DBHelper.getLanding() else { return }
            let viewModel = LandingViewModel(landing)
            update(with: viewModel)
        }
    }
    
    fileprivate func configureNodes() {
        self.view.addSubview(collectionView)
        self.view.addSubnode(tableNode)

        collectionView.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
        collectionView.autoPinEdge(toSuperviewEdge: .left)
        collectionView.autoPinEdge(toSuperviewEdge: .right)
        collectionView.autoSetDimension(.height, toSize: collection_height)
        
        tableNode.view.autoPinEdge(.top, to: .bottom, of: collectionView)
        tableNode.view.autoPinEdge(toSuperviewEdge: .left)
        tableNode.view.autoPinEdge(toSuperviewEdge: .right)
        tableNode.view.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    fileprivate func configTableDataProvider() {
        tableDataProvider = FeedTableDataProvider(with: tableNode)
        tableDataProvider?.didSelectRow = didSelectTableRow
        tableDataProvider?.didSelectPin = didSelectTablePin
        tableDataProvider?.loadMore = loadMore
    }
    
    fileprivate func configCollectionDataProvider() {
        collectionDataProvider = FeedsCollectionDataProvider(with: collectionView)
        collectionDataProvider?.didSelectRow = didSelectCollectionRow
        collectionDataProvider?.didSelectPin = didSelectCollectionPin
    }
    
    fileprivate func updateTableNode() {
        guard let items = landingViewModel?.tableViewFeeds else { return }
        tableDataProvider?.updateTableNode(with: items)
    }
    
    fileprivate func updateCollectionView() {
        guard let items = landingViewModel?.collectionViewFeeds else { return }
        collectionDataProvider?.updateCollectionView(with: items)
        
        if items.count > 2 {
            let indexPath = IndexPath(row: items.count - 1, section: 0)
            collectionDataProvider?.collectionView?.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }

    fileprivate func update(with  viewModel: LandingViewModelType) {
        landingViewModel = viewModel
        
        updateCollectionView()
        updateTableNode()
    }
    
    fileprivate func update(with items: [FeedViewModelType]) {
        updateCollectionView()
        tableDataProvider?.insertNewItemsInTableNode(with: items)
    }
    
    fileprivate func openDetailPage(with item: FeedViewModelType) {
        let vc = DetailViewController(with: item)
        vc.didSelectDetailPagePin = didSelectDetailPagePin
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Callbacks -
extension LandingViewController {
    
    fileprivate func didSelectTableRow(_ item: FeedViewModelType) {
        openDetailPage(with: item)
    }
    
    fileprivate func didSelectCollectionRow(_ item: FeedViewModelType) {
        openDetailPage(with: item)
    }
    
    fileprivate func didSelectTablePin(_ item: FeedViewModelType) {
        
        //update local feed
        DBHelper.updateFavoriteFeed(item)
        
        if item.isSelected {
            landingViewModel?.collectionViewFeeds.append(item)
        } else {
            guard let index = landingViewModel?.collectionViewFeeds.index(where: { $0.id == item.id }) else { return }
            landingViewModel?.collectionViewFeeds.remove(at: index)
        }

        // update collection view items
        updateCollectionView()
    }
    
    fileprivate func didSelectCollectionPin(_ item: FeedViewModelType) {
        
        //update local feed
        DBHelper.updateFavoriteFeed(item)
        
        guard let index = landingViewModel?.collectionViewFeeds.index(where: { $0.id == item.id }) else { return }
        landingViewModel?.collectionViewFeeds.remove(at: index)

        // update collection view items
        updateCollectionView()

        // update correct table view item
        guard let row = landingViewModel?.tableViewFeeds.index(where: { $0.id == item.id }) else { return }
        tableDataProvider?.updateSelectButton(with: row, state: false)
    }
    
    fileprivate func didSelectDetailPagePin(_ item: FeedViewModelType) {
        didSelectTablePin(item)
        
        // update correct table view item
        guard let row = landingViewModel?.tableViewFeeds.index(where: { $0.id == item.id }) else { return }
        tableDataProvider?.updateSelectButton(with: row, state: item.isSelected)
    }
    
    fileprivate func loadMore() {
        if !tuple.loading {
            tuple.pageSize += 10
            tuple.loading = true
            getFeeds { [weak self] viewModel in
                self?.tuple.loading = (viewModel.tableViewFeeds.count == 0)
                if viewModel.tableViewFeeds.count > 0 {
                    self?.landingViewModel?.tableViewFeeds += viewModel.tableViewFeeds
                    self?.update(with: viewModel.tableViewFeeds)
                }
            }
        }
    }
}

//MARK: - Timer -
extension LandingViewController {
    
    func startTimer() {
        let queue = DispatchQueue(label: "com.arohak.AHNewsFeed")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(30))
        timer!.setEventHandler { [weak self] in
            self?.checkNewFeeds()
        }
        timer!.resume()
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}

//MARK: - API -
extension LandingViewController {
    
    private func checkNewFeeds() {
        NewsFeedEndpoint.getFeeds(showProgressHUD: false, pageSize: 1) { [weak self] data in
            let landing = Landing(data: data)
            guard let currentLanding = DBHelper.getLanding() else { return }
            
            if currentLanding.total != landing.total {
                self?.tuple = (pageSize: 10, loading: false)
                self?.setupInitialState()
            }
        }
    }
    
    private func getFeeds(showProgressHUD: Bool = false, callback: @escaping FeedsCallback) {
        NewsFeedEndpoint.getFeeds(showProgressHUD: showProgressHUD, pageSize: tuple.pageSize) { [weak self] data in
            let obj = Landing(data: data)
            
            //putt in store
            DBHelper.storeLanding(obj)
            
            //get from store
            guard let landing = DBHelper.getLanding((self?.tuple.pageSize)!) else { return }
            let viewModel = LandingViewModel(landing)
            callback(viewModel)
        }
    }
}
