//
//  SourcesSelectionVC.swift
//  HelloWorld
//
//  Created by MacPro on 19/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage
import Foundation

class SourcesSelectionVC : UIViewController,UIScrollViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var deSelectBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var laoderView: UIActivityIndicatorView!
    
    
    //MARK: - Variables
    var containerView = UIView()
    var leftGesture = false
    var rightGesture = false
    var isHighLighted:Bool = false
    var selectedButtons = [UIButton]()
    private var focusGuide: UIFocusGuide!
    override weak var preferredFocusedView: UIView? {
        if leftGesture {
            return deSelectBtn
        } else if ( rightGesture ){
            return confirmBtn
        }else {
            return scrollView
        }
    }
    
    //MARK: - ViewController lifeCycle and focus
    override func viewDidLoad()           {
        super.viewDidLoad()
        focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "search-bg.png")!)
        confirmBtn.hidden = true
        deSelectBtn.hidden = true
        let temp = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/sources/free/all"
        Alamofire.request(.GET,temp).responseObject {
            (response: Response<PlaybackSourceModel, NSError>) in
            let apiResponce = response.result.value
            if ( apiResponce?.results?.count > 0 ){
                let buttonHeight = 85
                var y  = CGFloat((0 * buttonHeight))
                let buttonSpace = 20
                for i in 0..<apiResponce!.results!.count {
                    let button = UIButton(type: .System) // let preferred over var here
                    button.frame = CGRectMake(20, y, (self.scrollView.frame.size.width - 40),CGFloat(buttonHeight) )
                    y = CGFloat(((i + 1) * buttonHeight) + ((i + 1) * buttonSpace))
                    button.setTitle(apiResponce!.results![i].display_name, forState: UIControlState.Normal)
                    button.contentHorizontalAlignment = .Left
                    button.addTarget(self, action: #selector(SourcesSelectionVC.sourceSelected(_:)), forControlEvents: UIControlEvents.PrimaryActionTriggered)
                    self.containerView.addSubview(button)
                }
                self.laoderView.stopAnimating()
                self.scrollView.delegate = self
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, y)
                self.scrollView.addSubview(self.containerView)
                self.confirmBtn.hidden = false
                self.deSelectBtn.hidden = false
            }else if (  apiResponce?.results?.count <= 0 ){
            }else {
                //print(apiResponce?.toJSONString())
            }
        }
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SourcesSelectionVC.swipedLeft(_:)))
        swipeLeft.direction = .Left
        self.scrollView .addGestureRecognizer(swipeLeft)
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SourcesSelectionVC.swipedRight(_:)))
        swipeRight.direction = .Right
        self.scrollView .addGestureRecognizer(swipeRight)
        let swipeUPforDeselectBtn:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SourcesSelectionVC.swipedUP(_:)))
        swipeUPforDeselectBtn.direction = .Up
        self.deSelectBtn .addGestureRecognizer(swipeUPforDeselectBtn)
        let swipeUPforConfirmBtn:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SourcesSelectionVC.swipedUP(_:)))
        swipeUPforConfirmBtn.direction = .Up
        self.confirmBtn .addGestureRecognizer(swipeUPforConfirmBtn)
        self.updateFocusIfNeeded()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.frame = CGRectMake(0,0, scrollView.contentSize.width, scrollView.contentSize.height)
    }
    
    //MARK: - Others
    func swipedUP(sender:UISwipeGestureRecognizer)   {
        leftGesture = false
        rightGesture = false
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    func swipedLeft(sender:UISwipeGestureRecognizer) {
        leftGesture = true
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    func swipedRight(sender:UISwipeGestureRecognizer){
        rightGesture = true
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
    }
    func sourceSelected(sender: UIButton)            {
        dispatch_async(dispatch_get_main_queue(), {
            if self.isHighLighted == false{
                sender.selected = true;
                sender.setImage(UIImage(named: "nav-tick-icon")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
                sender.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 950, bottom: 0, right: 0)
                self.isHighLighted = true
                self.selectedButtons.append(sender)
            }else{
                sender.selected = false;
                sender.setImage(nil, forState: .Normal)
                sender.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 950, bottom: 0, right: 0)
                self.isHighLighted = false
            }
        });
    }

    //MARK: - Actions
    @IBAction func deselectAll (sender: UIButton)    {
        for i in 0..<selectedButtons.count {
            let button = selectedButtons[i]
            button.selected = false
            button.setImage(nil, forState: .Normal)
            self.isHighLighted = false
        }
    }
}