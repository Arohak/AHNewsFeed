//
//  DetailViewController.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 12/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    
    fileprivate let detailView = DetailView()
    fileprivate var viewModel: FeedViewModelType!
    var didSelectDetailPagePin: ((_ item: FeedViewModelType) -> ())?

    init(with item: FeedViewModelType) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = item
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        baseConfig()
    }
}

//MARK: - Private Methods -
extension DetailViewController {
    
    fileprivate func baseConfig() {
        self.view = detailView
        self.title = viewModel.category
        
        detailView.setup(with: viewModel)
        detailView.selectButton.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
    }
    
    @objc func selectButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.isSelected = sender.isSelected
        
        didSelectDetailPagePin?(viewModel)
    }
}
