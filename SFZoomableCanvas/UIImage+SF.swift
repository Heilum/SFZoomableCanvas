//
//  UIImageExtensions.swift
//  BlasterZonePlayer
//
//  Created by CHENWANFEI on 2/9/16.
//  Copyright © 2016 Creative. All rights reserved.
//
import UIKit;

extension UIImage{
   
    func tintWithColor(color:UIColor)->UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size,false,0)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context!.scale(x: 1.0, y: -1.0)
        context!.translate(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context!.setBlendMode(CGBlendMode.multiply)
        
        let rect = CGRect(x:0, y:0, width:self.size.width, height:self.size.height)
        context!.clipToMask(rect, mask: self.cgImage!)
        color.setFill()
        context!.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
   
    func crop(_ rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    static func fromColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    var imageToDisplayBasedOnOrientation:UIImage{
        if self.imageOrientation == UIImageOrientation.up{
            return self;
        }
        
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height));

            
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage!;
    }
    

}
