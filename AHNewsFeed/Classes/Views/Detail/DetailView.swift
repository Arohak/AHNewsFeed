//
//  DetailView.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 12/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import UIKit
import PureLayout

final class DetailView: UIView {
    
    lazy var thumbImageView: UIImageView = {
        let view = UIImageView.newAutoLayout()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true

        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel.newAutoLayout()
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont.boldSystemFont(ofSize: 16)
        view.numberOfLines = 0
        
        return view
    }()
    
    lazy var selectButton: UIButton = {
        let view = UIButton.newAutoLayout()
        view.setBackgroundImage(UIImage(named: "img_favorit_select"), for: .normal)
        view.setBackgroundImage(UIImage(named: "img_favorit_deselect"), for: .selected)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailView: ViewConfiguration {
    
    func configureViews() {
        backgroundColor = bg_color
    }
    
    func buildViewHierarchy() {
        addSubview(thumbImageView)
        thumbImageView.addSubview(titleLabel)
        thumbImageView.addSubview(selectButton)
    }
    
    func setupConstraints() {
        let inset: CGFloat = max_inset
        let width: CGFloat = Screen.width - inset
        
        thumbImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        thumbImageView.autoPinEdge(toSuperviewEdge: .top, withInset: inset)
        thumbImageView.autoSetDimensions(to: CGSize(width: width, height: width))
        
        titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: inset)
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: inset)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: inset)
        
        selectButton.autoPinEdge(toSuperviewEdge: .top)
        selectButton.autoPinEdge(toSuperviewEdge: .right)
        selectButton.autoSetDimensions(to: CGSize(width: 2*inset, height: 3*inset))
    }
}

extension DetailView {
    
    func setup(with item: FeedViewModelType){
        titleLabel.text = item.title
        selectButton.isSelected = item.isSelected
        thumbImageView.download(image: item.image)
    }
}

