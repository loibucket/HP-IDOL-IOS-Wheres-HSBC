//
//  ViewController.swift
//  WheresMyHSBC
//
//  Created by loichengllc on 6/6/15.
//  Copyright (c) 2015 Loi Cheng LLC. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var findButton: UIButton!
    var imageURL = "http://i.imgur.com/lrE25tr.jpg?1"
    
    // HSBC image
    func hsbcImage() {

        let switcher = arc4random()%5
        
        switch switcher{
            
        case 0: imageURL = "http://i.imgur.com/5Kcbfn6.png?1"
            
        case 1: imageURL = "http://i.imgur.com/KXlkVWi.png?1"
            
        case 2: imageURL = "http://i.imgur.com/MIt5wlj.jpg?1"
            
        case 3: imageURL = "http://i.imgur.com/bq59zfL.png?1"
            
        case 4: imageURL = "http://i.imgur.com/28zca10.jpg?1"
        
        default: imageURL = "http://i.imgur.com/lrE25tr.jpg?1"
        
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        
        self.masterLoad()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func masterLoad(){
        
        self.hsbcImage()
        
        self.hideButton()
        
        load_image(imageURL)
        
        HPIDOLPlaygroundClient().queryImageRecognition(imageURL)
        
        var timerTwo = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("unhideButton"), userInfo: nil, repeats: false)
        
    }
    
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBAction func reloadAction(sender: AnyObject) {
        for view in self.view.subviews {
            if view is CircleView {
            view.removeFromSuperview()
            }
        }
        self.masterLoad()
    }
    
    func unhideButton(){
        findButton.hidden = false
        reloadButton.hidden = false
    }
    
    func hideButton(){
        findButton.hidden = true
        reloadButton.hidden = true
    }
    
    func doNothing(){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // show where HSBC is
    @IBAction func findHSBC(sender: AnyObject) {
        
        let jsonObject : AnyObject? = HPIDOLPlaygroundClient().getJSON()

        if (jsonObject != nil) {
            if let corners: AnyObject? = (((jsonObject as! NSDictionary)["object"] as! NSArray)[0] as! NSDictionary)["corners"]{
                
                let vertex = corners as! NSArray
                
                let vertex0 = vertex[0] as! NSDictionary
                let ex0 = vertex0["x"] as! CGFloat / self.imageView.image!.size.width * imageView.frame.width
                let y0 = vertex0["y"] as! CGFloat / self.imageView.image!.size.height * imageView.frame.height + imageView.frame.minY
                
                let vertex1 = vertex[1] as! NSDictionary
                let ex1 = vertex1["x"] as! CGFloat / self.imageView.image!.size.width * imageView.frame.width
                let y1 = vertex1["y"] as! CGFloat / self.imageView.image!.size.height * imageView.frame.height + imageView.frame.minY
                
                let vertex2 = vertex[2] as! NSDictionary
                let ex2 = vertex1["x"] as! CGFloat / self.imageView.image!.size.width * imageView.frame.width
                let y2 = vertex1["y"] as! CGFloat / self.imageView.image!.size.height * imageView.frame.height + imageView.frame.minY
                
                let vertex3 = vertex[3] as! NSDictionary
                let ex3 = vertex1["x"] as! CGFloat / self.imageView.image!.size.width * imageView.frame.width
                let y3 = vertex1["y"] as! CGFloat / self.imageView.image!.size.height * imageView.frame.height + imageView.frame.minY
                
                let avgEx = (ex0 + ex1 + ex2 + ex3) / 4
                let avgY = (y0 + y1 + y2 + y3) / 4
                
                let maxX = max(ex0, ex1, ex2, ex3)
                let minX = min(ex0, ex1, ex2, ex3)
                let maxY = max(y0, y1, y2, y3)
                let minY = min(y0, y1, y2, y3)
                
                let dia = max(maxY - minY, maxX - minX) * 1.2
                
                var circleView = CircleView(frame: CGRectMake(avgEx - dia / 2, avgY - dia / 2, dia, dia))
                view.addSubview(circleView)
            }
        }
        
        HPIDOLPlaygroundClient().queryImageRecognition(imageURL)
        sleep(1)
    }
    
    // load image from URL
    // http://www.kaleidosblog.com/uiimage-from-url-with-swift
    func load_image(urlString:String)
    {
        var imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    self.imageView.image = UIImage(data: data)
                }
        })
        
    }
    
    // draw a rectangle
    // http://stackoverflow.com/questions/25229916/how-to-procedurally-draw-rectangle-lines-in-swift-using-cgcontext
    func drawCustomImage(size: CGSize) -> UIImage {
        // Setup our context
        let bounds = CGRect(origin: CGPoint.zeroPoint, size: size)
        let opaque = false
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup complete, do drawing here
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 2.0)
        
        CGContextStrokeRect(context, bounds)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
        CGContextAddLineToPoint(context, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))
        CGContextMoveToPoint(context, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
        CGContextAddLineToPoint(context, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
        CGContextStrokePath(context)
        
        // Drawing complete, retrieve the finished image and cleanup
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

