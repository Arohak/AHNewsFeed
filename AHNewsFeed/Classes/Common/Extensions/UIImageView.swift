//
//  UIImageView.swift
//  AHNewsFeed
//
//  Created by Ara Hakobyan on 12/12/2017.
//  Copyright © 2017 Ara Hakobyan. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImageView {
    
    func download(image url: URL?) {
        guard let imageURL = url else { return }
        self.af_setImage(withURL: imageURL, placeholderImage:#imageLiteral(resourceName: "img_placeholder"))
    }
}
