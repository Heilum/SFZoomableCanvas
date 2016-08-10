//
//  SFModels.swift
//  SFZoomableCanvas
//
//  Created by CHENWANFEI on 8/8/16.
//  Copyright © 2016 SwordFish. All rights reserved.
//

import Foundation
import CoreGraphics
struct SFStroke{
    let color:CGColor;
    let lineWidth:CGFloat;
    let path:CGPath;
}


public class SFStrokeArrayBox :NSObject {
    let unbox:[SFStroke]
    init(_ value: [SFStroke]) {
        self.unbox = value
    }
}
