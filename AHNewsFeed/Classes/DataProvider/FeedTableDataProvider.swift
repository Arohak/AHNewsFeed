//
//  FeedTableDataProvider.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 15/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import UIKit

protocol FeedTableDataProviderProtocol: UITableViewDataSource, UITableViewDelegate {
    
    associatedtype T
    var items:[T] {get}
    weak var tableView: UITableView? {get}
    
    init(with tableView: UITableView)
    func updateTableView(with items: [T])
    func insertNewItemsInTableView(with items: [T])
    func updateSelectButton(with index: Int, state: Bool)
}

final class FeedTableDataProvider: NSObject {
    
    var items:[FeedViewModelType] = []
    var tableView: UITableView?
    var willDisplay: ((_ index: Int) -> ())?
    var didSelectPin: ((_ item: FeedViewModelType) -> ())?
    var didSelectRow: ((_ item: FeedViewModelType) -> ())?

    required init(with tableView: UITableView) {
        super.init()

        self.tableView = tableView
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate -
extension FeedTableDataProvider: FeedTableDataProviderProtocol {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FeedTableViewCell.self)
        let item = self.items[indexPath.row]
        cell.cellContentView.selectButton.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
        cell.cellContentView.selectButton.tag = indexPath.row
        cell.setup(with: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        didSelectRow?(item)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplay?(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//MARK: - Actions -
extension FeedTableDataProvider {
    
    @objc func selectButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        items[sender.tag].isSelected = sender.isSelected
        let item = items[sender.tag]
        
        didSelectPin?(item)
    }
}

//MARK: - Update -
extension FeedTableDataProvider {
    
    func updateTableView(with items: [FeedViewModelType]) {
        self.items = items
        self.tableView?.reloadData()
    }
    
    func insertNewItemsInTableView(with items: [FeedViewModelType]) {
        self.items += items
        
        let count = self.items.count
        var indexPaths = [IndexPath]()
        for row in count - 10..<count {
            let path = IndexPath(row: row, section: 0)
            indexPaths.append(path)
        }
        
        self.tableView?.reloadData()
//        self.tableView?.insertRows(at: indexPaths, with: .none)
    }
    
    func updateSelectButton(with index: Int, state: Bool) {
        items[index].isSelected = state
        
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView?.cellForRow(at: indexPath) as? FeedTableViewCell
        cell?.cellContentView.selectButton.isSelected = state
    }
}
