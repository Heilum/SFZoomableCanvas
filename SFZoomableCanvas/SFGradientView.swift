//
//  SFGradientView.swift
//  SFZoomableCanvas
//
//  Created by CHENWANFEI on 8/10/16.
//  Copyright © 2016 SwordFish. All rights reserved.
//

import UIKit

class SFGradientView: UIView {
   
    
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    lazy var gradientLayer: CAGradientLayer = {
        return self.layer as! CAGradientLayer
    }()
}
