//
//  ViewController.swift
//  SFZoomableCanvas
//
//  Created by CHENWANFEI on 8/8/16.
//  Copyright © 2016 SwordFish. All rights reserved.
//

import UIKit


enum SFCanvasMode :Int {
    case none = 0;
    case drawing = 1;
    case positioning = 2;
}



final class SFZoomableCanvasVC: UIViewController {
    
    
    private let tintColor = UIColor(red: 208.0/225, green: 2.0/225, blue: 27.0/225, alpha: 1.0);
    private let animationDuration = TimeInterval(0.25)
    
    private let toolBtnWidth = CGFloat(50);
    
    
    @IBOutlet weak var canvasView: SFCanvasView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var canvasPanGesture: UIPanGestureRecognizer!
    
    private var strokes = [SFStroke]();
    
    private var currentPath:UIBezierPath?;

    @IBOutlet weak var toolBtn: UIButton!
    
    @IBOutlet weak var toolsPanel: UIView!
    
    @IBOutlet weak var toolPanelHeightConstraint: NSLayoutConstraint!
    
  
    
   
    
    @IBOutlet weak var modeBtn: UIButton!
    
    @IBOutlet weak var undoBtn: UIButton!
   
    @IBOutlet weak var redoBtn: UIButton!
    
    @IBOutlet weak var clearBtn: UIButton!
    
    @IBOutlet weak var settingBtn: UIButton!
    
    
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    private var _undoManager = UndoManager()
    override var undoManager: UndoManager {
        return _undoManager
    }
    
    private var thickness = CGFloat(0.5) {
        didSet{
            
            self.settingBtn.setImage(self.buildSettingIcon(), for: []);
            
            
        }
    }
    private var lineColor = UIColor(red: 208.0/225, green: 2.0/225, blue: 27.0/225, alpha: 1.0){
        didSet{
              self.settingBtn.setImage(self.buildSettingIcon(), for: []);
        }
    }
    
    private func buildSettingIcon() -> UIImage?{
        
    
        let size = CGSize(width: toolBtnWidth, height: toolBtnWidth)
        
        let center =  CGPoint(x: size.width / 2,y:size.height / 2);
        
        let radius = size.width * thickness / 2

        UIGraphicsBeginImageContextWithOptions(size,false,0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState();
       
       
        // flip the image
        
        context?.scaleBy(x: 1, y: -1.0);
        context?.translateBy(x: 0.0, y: -size.height)
        
       
        
        // multiply blend mode
        context?.setBlendMode(CGBlendMode.multiply)
        
        let rect = CGRect(x:0, y:0, width:size.width, height:size.height)

        
        context?.clip(to: rect, mask: UIImage(named: "circle_icon")!.cgImage!)
        
        tintColor.setFill()
        context?.fill(rect)
        
        
        context?.restoreGState();
        
        let path =  UIBezierPath(arcCenter:center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true);
        context?.setFillColor(self.lineColor.cgColor);
        
        context?.addPath(path.cgPath);
        context?.fillPath();
       
        
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage

    }
    
    @IBAction func onClear(_ sender: AnyObject) {
        
        
        let alertVC = UIAlertController(title: "Warnning", message: "All content will be erased, this operation can't undo, continue?", preferredStyle: UIAlertControllerStyle.alert);
        alertVC.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
            
            if let this = self{
                this.strokes.removeAll();
                this.canvasView.strokes = [];
                
                this.undoManager.removeAllActions();
                
                this.updateUndoAndRedoButtons();
                
                this.scrollView.setZoomScale(this.scrollView.minimumZoomScale, animated: true);
                
                this.mode = .drawing;
                
            }
            
          
            
            
        }));
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
        self.present(alertVC, animated: true, completion: nil);
        
    }
    
    fileprivate var mode:SFCanvasMode = SFCanvasMode.none{
        didSet{
            if mode == SFCanvasMode.drawing{
                self.scrollView.isScrollEnabled = false;
                self.canvasPanGesture.isEnabled = true;
                
              
               
                self.modeBtn.isSelected = false;
                
                
            }else if(mode == SFCanvasMode.positioning){
                self.scrollView.isScrollEnabled = true;
                self.canvasPanGesture.isEnabled = false;
                
                self.modeBtn.isSelected = true;

            }
        }
    }
  
   
    @IBAction func onToggleToolsBtn(_ sender: AnyObject) {
        self.showToolPanel(show: !self.toolBtn.isSelected,animated:  true)
    }
    
    private func showToolPanel(show:Bool,animated:Bool){
        self.toolBtn.isSelected =  show;
        if self.toolBtn.isSelected {
            
            self.toolPanelHeightConstraint.constant = 353;
            
        }else{
          
            
            self.toolPanelHeightConstraint.constant = 50;
        }
        
        if animated {
            
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    

    }
    
    @IBAction func onModeSwitch(_ sender: AnyObject) {
        if self.mode == .drawing{
            self.mode = .positioning;
            
            self.showInfo(info: "Positioning mode");
           
        }else{
            self.mode = .drawing;
            self.showInfo(info: "Drawing mode");
          
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.showToolPanel(show: false,animated:  false);
        mode = .drawing
        self.modeBtn.isEnabled = false;
        
        self.lineColor = tintColor;
        self.thickness = 0.5
        self.infoLabel.textColor = tintColor;
        self.infoLabel.alpha = 0;
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUndoAndRedoButtons), name: Notification.Name.NSUndoManagerDidUndoChange, object: self.undoManager)
       
      

        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUndoAndRedoButtons), name: Notification.Name.NSUndoManagerDidRedoChange, object: self.undoManager);
        
        
        updateUndoAndRedoButtons();

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private dynamic func updateUndoAndRedoButtons() {
    
        self.undoBtn.isEnabled = undoManager.canUndo;
        self.redoBtn.isEnabled = undoManager.canRedo;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(_ delay: Double,  closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure);
        
        
    }

    
    override var prefersStatusBarHidden: Bool {
        return true;
    }
    
    
    
    private func convertPath(_ path:UIBezierPath) -> SFStroke{
        let color = self.lineColor;
        let lineWidth = self.settingBtn.bounds.width * thickness;
        let path = path.cgPath;
        let stroke = SFStroke(color: color.cgColor, lineWidth: lineWidth, path: path);
       
        return stroke;

    }
    
    override var canBecomeFirstResponder:Bool {
        return true
    }
    
    @IBAction func onCanvasPaning(_ sender: AnyObject) {
        let g = sender as! UIPanGestureRecognizer;
        let point =  g.location(in: self.canvasView);
        switch g.state {
        case .began:
            self.currentPath = UIBezierPath();
            self.currentPath?.lineCapStyle = CGLineCap.round;
            self.currentPath?.lineJoinStyle = CGLineJoin.round;
            self.currentPath?.move(to: point);
            let stroke = self.convertPath(self.currentPath!)
            self.strokes.append(stroke);
            
            
            
        case .changed:
            
           
            
            
            if let path = self.currentPath{
                path.addLine(to: point);
                let stroke = self.convertPath(path)
                
                self.strokes[self.strokes.count - 1] = stroke;
                self.canvasView.strokes = self.strokes;
            }

            
            break;
            
        case .ended,.cancelled:
            
            let oldStroks = [SFStroke](self.strokes.prefix(self.strokes.count - 1));
            
            (undoManager.prepare(withInvocationTarget: self) as AnyObject).handleUndoRedo(SFStrokeArrayBox(oldStroks), newStrokes: SFStrokeArrayBox(self.strokes));
            
            
            
            undoManager.setActionName("Add Stroke")
            self.updateUndoAndRedoButtons();
            
            self.currentPath = nil;
            
            break;
            
        default:
            break;
        }
       
    }
    
    
    @objc func handleUndoRedo(_ oldStrokes:SFStrokeArrayBox,newStrokes:SFStrokeArrayBox){
        
        //add undo
        
        self.strokes = oldStrokes.unbox;
        self.canvasView.strokes = self.strokes;
        
        //add redo
        (undoManager.prepare(withInvocationTarget: self) as AnyObject).handleUndoRedo(newStrokes,newStrokes: oldStrokes);
        undoManager.setActionName("Remove Stroke")
    }
    
   
    

    
    @IBAction func onDoubleTaped(_ sender: AnyObject) {
        //self.canvasView.transform = CGAffineTransform(scaleX: 2, y: 2);
      
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true);
            let s = NSString(format: "%.01f X",scrollView.maximumZoomScale);
            self.showInfo(info:  s as String)
        }else{
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true);
            
            let s = NSString(format: "%.01f X",scrollView.minimumZoomScale);
            self.showInfo(info:  s as String)
            
           
        }
       

    }
    
    
    private func createSnapshotImage() -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(self.canvasView.bounds.size, false, 0);
        self.canvasView.drawHierarchy(in: self.canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        return image;
    }
    
    
    @IBAction func onShare(_ sender: AnyObject) {
        
        
        
        if let image = self.createSnapshotImage() {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            vc.popoverPresentationController?.sourceView = self.shareBtn;
            vc.popoverPresentationController?.sourceRect = self.shareBtn.bounds;
            present(vc, animated: true, completion: nil)
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingVC = segue.destination as? SFSettingVC{
            
            settingVC.initColor = self.lineColor;
            settingVC.colorSelection = { [weak self] (color:UIColor) in
                self?.lineColor = color;
            }
            
            settingVC.initThickness = self.thickness;
            settingVC.thickneessSelection =  { [weak self] (thickness:CGFloat) in
                self?.thickness = thickness;
            }
            
            settingVC.view.tintColor = tintColor;

        }
    }
    
    fileprivate func showInfo(info:String){
        self.infoLabel.text = info;
        self.infoLabel.alpha = 1.0;
        delay(2) {  [weak self] in
            if let this = self{
                UIView.animate(withDuration: this.animationDuration, animations: {
                    this.infoLabel.alpha = 0;
                })
            }
            
        }
    }
  
    
}

extension SFZoomableCanvasVC:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {

        return self.canvasView;
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        self.modeBtn.isEnabled = scrollView.zoomScale > scrollView.minimumZoomScale;
        if self.modeBtn.isEnabled == false && self.mode == .positioning{
            self.mode = .drawing;
        }
        
        let s = NSString(format: "%.01f X",scrollView.zoomScale);
        self.showInfo(info: s as String)
        
    }
}

