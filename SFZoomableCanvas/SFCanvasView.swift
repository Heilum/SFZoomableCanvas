//
//  SFCanvasView.swift
//  SFZoomableCanvas
//
//  Created by CHENWANFEI on 8/8/16.
//  Copyright © 2016 SwordFish. All rights reserved.
//

import UIKit




class SFCanvasView: UIView {
    var strokes:[SFStroke]?{
        didSet{
             self.setNeedsDisplay();
        }
    }
   
    
    override func draw(_ rect: CGRect) {
        super.draw(rect);
        if let ss = self.strokes{
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }
            
            
            for s in ss{
                context.setStrokeColor(s.color)
                context.setLineWidth(s.lineWidth)
                context.addPath(s.path);
                context.drawPath(using: .stroke)
            }
        }
       
        
    }
    
}
