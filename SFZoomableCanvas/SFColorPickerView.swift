//
//  SFColorPickerView.swift
//  SFZoomableCanvas
//
//  Created by CHENWANFEI on 8/10/16.
//  Copyright © 2016 SwordFish. All rights reserved.
//

import UIKit





class SFColorPickerView: UIView {
    
    
    private let gradientViewHeight = CGFloat(20);
    private let gradientViewGap = CGFloat(20);
    private let crossHairWidth = CGFloat(38);
    private let scrabSize = CGSize(width:15,height:40);
   
    
    private weak var  hueSaturationImageView:UIImageView!;
    private weak var  hueSaturationCrossHairs:UIView!;
    private weak var  gradientView:SFGradientView!
    private weak var  brightnessScrab:UIView!
    
    
    private var currentHue:CGFloat = 0
    private var currentSaturation:CGFloat = 0
    private var currentBrightness:CGFloat = 1;
    
    private var lastTouchLocation:CGPoint?
    private var isDragingCrossHair:Bool = false;
    private var isDragingScrab:Bool = false;
    
    var initColor:UIColor?{
        didSet{
            if let color = self.initColor{
                    color.getHue(&self.currentHue, saturation: &self.currentSaturation, brightness: &currentBrightness, alpha: nil);
            }
     
            
            
        }
    }
    
    var colorSelection:((UIColor) -> Void)?
    
    private var color:UIColor{
        return UIColor(hue: currentHue, saturation: currentSaturation, brightness: currentBrightness, alpha: 1);
    }
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.doInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.doInit()
    }
    
    private func doInit(){
        //set the container's minimum height for layout
        self.clipsToBounds = false;
        self.bounds = CGRect(x: 0, y: 0, width: 0, height: gradientViewHeight + gradientViewGap);
        
        let hueSaturationImageView = UIImageView();
        hueSaturationImageView.image = #imageLiteral(resourceName: "colormap")
        
    
        hueSaturationImageView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - gradientViewHeight - gradientViewGap);
        
        hueSaturationImageView.autoresizingMask = [UIViewAutoresizing.flexibleHeight,UIViewAutoresizing.flexibleWidth];
        
        
        self.addSubview(hueSaturationImageView);
        
        self.hueSaturationImageView = hueSaturationImageView;
        
        
        let hueSaturationCrossHairs = UIView(frame: CGRect(x: 0, y: 0, width: crossHairWidth, height: crossHairWidth));
            
        hueSaturationImageView.addSubview(hueSaturationCrossHairs);
        
        hueSaturationCrossHairs.layer.cornerRadius = crossHairWidth / 2;
        hueSaturationCrossHairs.layer.borderColor = UIColor.white().withAlphaComponent(0.8).cgColor;
        hueSaturationCrossHairs.layer.borderWidth = 2;
        hueSaturationCrossHairs.layer.shadowColor = UIColor.black().cgColor
        hueSaturationCrossHairs.layer.shadowRadius = 1;
        hueSaturationCrossHairs.layer.shadowOpacity = 0.5
        hueSaturationCrossHairs.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        hueSaturationCrossHairs.center = CGPoint(x:0,y:0);
        
        
        self.hueSaturationCrossHairs = hueSaturationCrossHairs;
        
        
        
        
        
        let gradientView = SFGradientView(frame: CGRect(x: 0, y: self.bounds.height - gradientViewHeight , width: self.bounds.width, height: gradientViewHeight));
        gradientView.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin,UIViewAutoresizing.flexibleWidth];
        //test
        gradientView.backgroundColor = UIColor.red();
        
        gradientView.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5);
        gradientView.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5);
        
        self.addSubview(gradientView);
        self.gradientView = gradientView;
        
        let brightnessScrab = UIView(frame:CGRect(x: 0, y: 0, width: scrabSize.width, height: scrabSize.height));
        
        brightnessScrab.layer.cornerRadius = scrabSize.width / 2;
        brightnessScrab.layer.borderColor = UIColor.white().withAlphaComponent(0.8).cgColor;
        brightnessScrab.layer.borderWidth = 2;
     
        gradientView.addSubview(brightnessScrab);
        brightnessScrab.center = CGPoint(x:0,y:gradientView.bounds.height / 2);
        self.brightnessScrab = brightnessScrab
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first{
            self.lastTouchLocation = t.location(in: self);
            
            let gradientArea = self.gradientView.frame.insetBy(dx: -20, dy: -20);
            let hueSaturationImageViewArea = hueSaturationImageView.frame.insetBy(dx: -20, dy: -20);
            if hueSaturationImageViewArea.contains(self.lastTouchLocation!) {
                isDragingCrossHair = true;
            }else if gradientArea.contains(self.lastTouchLocation!) {
                isDragingScrab = true;
            }
            
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first{
            self.onTouchMove(location: t.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchLocation = nil;
        isDragingScrab = false;
        isDragingCrossHair = false;
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchLocation = nil;
        isDragingScrab = false;
        isDragingCrossHair = false;
    }
    
    private func onTouchMove(location:CGPoint){
        
        if let lastTouchLocation = self.lastTouchLocation{
            let thisLocation = location;
            
            let deltaX = thisLocation.x - lastTouchLocation.x;
            let deltaY = thisLocation.y - lastTouchLocation.y;
            
            if isDragingCrossHair{
                
                var newCX = hueSaturationCrossHairs.center.x + deltaX;
                newCX = min(max(newCX, 0), hueSaturationImageView.bounds.width);
                
                var newCY = hueSaturationCrossHairs.center.y + deltaY;
                newCY = min(max(newCY, 0), hueSaturationImageView.bounds.height);
                
                let cp = CGPoint(x: newCX, y: newCY);
                
                
                updateHueSatWithMovement(location: cp);
                
                
            }else if isDragingScrab{
                var newCX = brightnessScrab.center.x + deltaX;
                newCX = min(max(newCX, 0), gradientView.bounds.width);
                
                let newCY = gradientView.bounds.height / 2;
                
                let cp = CGPoint(x: newCX, y: newCY);
                
                
                updateScrabWithMovement(location: cp);
            }
            
            self.lastTouchLocation = thisLocation;
            
        }
        
      
    }
    
    private func onColorFactorChanged(callHandler:Bool = false){
        let beginColor = UIColor(hue: currentHue, saturation: currentSaturation, brightness: 1, alpha: 1);
        let endColor =  UIColor(hue: currentHue, saturation: currentSaturation, brightness: 0, alpha: 1);
        
        self.gradientView.gradientLayer.colors = [beginColor.cgColor,endColor.cgColor];
        
        
        
        let c = self.color;
        hueSaturationCrossHairs.layer.backgroundColor = c.cgColor;
        brightnessScrab.layer.backgroundColor = hueSaturationCrossHairs.layer.backgroundColor;
        if callHandler {
            if let selection = self.colorSelection {
                selection(c);
            }
        }
       

    }
    
    
    private func updateHueSatWithMovement(location:CGPoint){
        currentHue = location.x / hueSaturationImageView.bounds.width;
        currentSaturation = CGFloat(1.0) - (location.y / hueSaturationImageView.bounds.height);
        hueSaturationCrossHairs.center = location;
        
        self.onColorFactorChanged(callHandler: true)
    }
    
    private func updateScrabWithMovement(location:CGPoint){

        currentBrightness = CGFloat(1.0) - (location.x / gradientView.bounds.width);
        brightnessScrab.center = location;
        
        self.onColorFactorChanged(callHandler: true)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        if let _ = self.initColor{
            
            let x = self.hueSaturationImageView.bounds.width * self.currentHue
            
            hueSaturationCrossHairs.center = CGPoint(x:x,y:hueSaturationImageView.bounds.size.height * (1 - self.currentSaturation));
            brightnessScrab.center = CGPoint(x:self.gradientView.bounds.width * (1 - self.currentBrightness),y:self.gradientView.bounds.height / 2);
            
            self.onColorFactorChanged();
            
            self.initColor = nil;

        }
    }
    
    

}
