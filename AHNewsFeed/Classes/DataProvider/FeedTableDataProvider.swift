//
//  FeedTableDataProvider.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 12/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import AsyncDisplayKit

protocol FeedTableDataProviderProtocol: ASTableDataSource, ASTableDelegate {
    
    associatedtype T
    var items:[T] {get}
    weak var tableNode: ASTableNode? {get}

    init(with tableNode: ASTableNode)
    func updateTableNode(with items: [T])
    func insertNewItemsInTableNode(with items: [T])
    func updateSelectButton(with index: Int, state: Bool)
}

class FeedTableDataProvider: NSObject {
    
    var items: [FeedViewModelType] = []
    weak var tableNode: ASTableNode?
    var didSelectRow: ((_ item: FeedViewModelType) -> ())?
    var didSelectPin: ((_ item: FeedViewModelType) -> ())?
    var loadMore: (() -> ())?

    required init(with tableNode: ASTableNode) {
        super.init()
        
        self.tableNode = tableNode
        self.tableNode?.dataSource = self
        self.tableNode?.delegate = self
    }
}

//MARK: - Datasource and Delegate -
extension FeedTableDataProvider: FeedTableDataProviderProtocol {

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let item = items[indexPath.row]
        let cellNodeBlock = { () -> ASCellNode in
            let cell = FeedTableCell(with: item)
            cell.selectButton.addTarget(self, action: #selector(self.selectButtonAction), forControlEvents: .touchUpInside)
            DispatchQueue.main.async {
                cell.selectButton.view.tag = indexPath.row
            }
            return cell
        }
        
        return cellNodeBlock
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        
        didSelectRow?(item)
    }
}

//MARK: - Actions -
extension FeedTableDataProvider {
    
    @objc func selectButtonAction(_ sender: ASButtonNode) {
        sender.isSelected = !sender.isSelected
        items[sender.view.tag].isSelected = sender.isSelected
        let item = items[sender.view.tag]

        didSelectPin?(item)
    }
}

//MARK: - Load More -
extension FeedTableDataProvider {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        if deltaOffset <= 0 {
            loadMore?()
        }
    }
}

//MARK: - Update -
extension FeedTableDataProvider {
    
    func updateTableNode(with items: [FeedViewModelType]) {
        self.items = items        
        self.tableNode?.reloadData()
    }
    
    func insertNewItemsInTableNode(with items: [FeedViewModelType]) {
        self.items += items

        let count = self.items.count
        var indexPaths = [IndexPath]()
        for row in count - 10..<count {
            let path = IndexPath(row: row, section: 0)
            indexPaths.append(path)
        }

        tableNode?.insertRows(at: indexPaths, with: .bottom)
    }
    
    func updateSelectButton(with index: Int, state: Bool) {
        items[index].isSelected = state
        
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableNode?.view.nodeForRow(at: indexPath) as! FeedTableCell
        cell.updateSelectButton(with: state)
    }
}
