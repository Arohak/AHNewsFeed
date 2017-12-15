//
//  TagView.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 15/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import UIKit

class TagView: UIView {
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        self.addSubview(self.label)
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-4.0-[label]-4.0-|",
                                                                      options: .directionLeadingToTrailing,
                                                                      metrics: nil,
                                                                      views: ["label" : self.label]))
        constraints.append(NSLayoutConstraint(item: self.label,
                                              attribute: .height,
                                              relatedBy: .greaterThanOrEqual,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 24))
        constraints.append(NSLayoutConstraint(item: self.label,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 6))
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.label,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 6))
        NSLayoutConstraint.activate(constraints)
    }
    
    
    open func image() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}

class TagsLabel: UILabel {

    open var tags: [String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setup() {
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.textAlignment = .left
        self.backgroundColor = bg_color
        self.isUserInteractionEnabled = true
    }

    open func setTags(_ tags: [String]) {
        self.tags = tags
        
        let mutableString = NSMutableAttributedString()
        let cell = UITableViewCell()
        tags.enumerated().forEach { (_, tag) in
            let view = TagView()
            view.label.attributedText = attributed(with: tag, font: UIFont.boldSystemFont(ofSize: 14))
            view.label.backgroundColor = .lightGray
            let size = view.systemLayoutSizeFitting(view.frame.size,
                                                    withHorizontalFittingPriority: UILayoutPriority.fittingSizeLevel,
                                                    verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
            view.frame = CGRect(x: 0, y: 0, width: size.width + 20, height: size.height)
            cell.contentView.addSubview(view)
            
            let image = view.image()
            let attachment = NSTextAttachment()
            attachment.image = image
            
            let attrString = NSAttributedString(attachment: attachment)
            mutableString.beginEditing()
            mutableString.append(attrString)
            mutableString.endEditing()
        }
        
        self.attributedText = mutableString
    }
    
    func attributed(with title: String, font: UIFont) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.headIndent = paragraphStyle.firstLineHeadIndent
        paragraphStyle.tailIndent = paragraphStyle.firstLineHeadIndent
        
        let attributes = [
            NSAttributedStringKey.paragraphStyle  : paragraphStyle,
            NSAttributedStringKey.font            : font
        ]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
}
