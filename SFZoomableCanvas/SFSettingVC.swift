//
//  SFSettingVC.swift
//  SFZoomableCanvas
//
//  Created by CHENWANFEI on 8/10/16.
//  Copyright © 2016 SwordFish. All rights reserved.
//

import UIKit

class SFSettingVC: UIViewController {
    fileprivate var windowTapgesture:UIGestureRecognizer!
    
    
    @IBOutlet weak var colorPickerView: SFColorPickerView!
    
    @IBOutlet weak var thicknessSlider: UISlider!
    
    var initColor:UIColor?
    var colorSelection:((UIColor) -> Void)?
    var initThickness:CGFloat?;
    var thickneessSelection:((CGFloat) -> Void)?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addWindowTapGesture();
        self.windowTapgesture.delegate = self;
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated);
        self.view.window!.removeGestureRecognizer(self.windowTapgesture);
    }

    @IBAction func onSlide(_ sender: AnyObject) {
        
        if let handler = self.thickneessSelection{
            handler(CGFloat(self.thicknessSlider.value))
        }
        
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad();
        if let color = self.initColor{
            colorPickerView.initColor = color;
        }
        
        colorPickerView.colorSelection = self.colorSelection;
        
        if let initThickness = self.initThickness{
            self.thicknessSlider.value = Float(initThickness);
        }
        
    }
}

extension SFSettingVC:UIGestureRecognizerDelegate{
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    func addWindowTapGesture(){
        let tapBGGesture = UITapGestureRecognizer(target: self, action: #selector(windowTaped))
        
        tapBGGesture.numberOfTapsRequired = 1
        tapBGGesture.cancelsTouchesInView = false
        self.view.window!.addGestureRecognizer(tapBGGesture)
        
        self.windowTapgesture = tapBGGesture;
        
    }
    
    func removeWindowTapGesture(){
        if let w = self.view.window,let g = self.windowTapgesture{
            w.removeGestureRecognizer(g);
        }
        
    }
    
    private dynamic func windowTaped(sender: UITapGestureRecognizer){
        if sender.state == UIGestureRecognizerState.ended{
            guard let presentedView = self.view else {
                return
            }
            
            
            if !presentedView.bounds.contains(sender.location(in: presentedView)) {
                self.dismiss(animated: true, completion:nil)
            }
        }
    }
    


}
