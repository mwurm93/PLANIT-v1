//
//  TripViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 6/16/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class TripViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    //MARK: Class variables
    var scrollContentViewHeight: NSLayoutConstraint?
    
    var userNameQuestionView: UserNameQuestionView?
    var tripNameQuestionView: TripNameQuestionView?
    var whereTravellingFromQuestionView: WhereTravellingFromQuestionView?
    var datesPickedOutQuestionView: DatesPickedOutQuestionView?
    var datesPickedOutCalendarView: DatesPickedOutCalendarView?
    var decidedOnCityToVisitQuestionView: DecidedOnCityToVisitQuestionView?
    
    
    // MARK: Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        userNameQuestionView = Bundle.main.loadNibNamed("UserNameQuestionView", owner: self, options: nil)?.first! as? UserNameQuestionView
        self.scrollContentView.addSubview(userNameQuestionView!)
        userNameQuestionView?.userNameQuestionTextfield?.delegate = self
        userNameQuestionView?.userNameQuestionTextfield?.becomeFirstResponder()
        let bounds = UIScreen.main.bounds
        self.userNameQuestionView!.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
        let heightConstraint = NSLayoutConstraint(item: userNameQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (userNameQuestionView?.frame.height)!)
        scrollContentViewHeight = NSLayoutConstraint(item: scrollContentView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: scrollContentView.subviews[scrollContentView.subviews.count - 1].frame.maxY)

        view.addConstraints([heightConstraint,scrollContentViewHeight!])
        updateHeightOfScrollView()        
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(calendarDateRangeSelected), name: NSNotification.Name(rawValue: "calendarRangeSelected"), object: nil)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Custom functions
    func updateHeightOfScrollView(){
        let heightOfScrollView = scrollContentView.subviews[scrollContentView.subviews.count - 1].frame.maxY
        scrollContentViewHeight?.constant = heightOfScrollView
        scrollContentView.frame.size.height = heightOfScrollView
        scrollView.contentSize.height = heightOfScrollView
//        scrollView.frame.size.height = heightOfScrollView
    }
    func scrollDownToTopSubview(){
        //Scroll to next question
        UIView.animate(withDuration: 1) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollContentView.subviews[self.scrollContentView.subviews.count - 1].frame.minY), animated: false)
        }
    }
    
    func userNameQuestionAnswered() {
        userNameQuestionView?.userNameQuestionTextfield?.resignFirstResponder()
        if userNameQuestionView?.userNameQuestionTextfield?.text != nil {
            tripNameQuestionView?.questionLabel?.text = "Hi \((userNameQuestionView?.userNameQuestionTextfield?.text!)!)! \nDo you want to name your trip?"
        }
        if tripNameQuestionView == nil {
            //Load next question
            tripNameQuestionView = Bundle.main.loadNibNamed("TripNameQuestionView", owner: self, options: nil)?.first! as? TripNameQuestionView
            tripNameQuestionView?.tripNameQuestionButton?.addTarget(self, action: #selector(self.tripNameQuestionButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
            self.scrollContentView.addSubview(tripNameQuestionView!)
            tripNameQuestionView?.tripNameQuestionTextfield?.delegate = self
            let bounds = UIScreen.main.bounds
            
            self.tripNameQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: tripNameQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (tripNameQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            if userNameQuestionView?.userNameQuestionTextfield?.text != nil {
                tripNameQuestionView?.questionLabel?.text = "Hi \((userNameQuestionView?.userNameQuestionTextfield?.text!)!)! \nDo you want to name your trip?"
            }
            tripNameQuestionView?.tripNameQuestionTextfield?.becomeFirstResponder()
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
    }
    func tripNameQuestionAnswered(){
        tripNameQuestionView?.tripNameQuestionTextfield?.resignFirstResponder()
        if whereTravellingFromQuestionView == nil {
            //Load next question
            whereTravellingFromQuestionView = Bundle.main.loadNibNamed("WhereTravellingFromQuestionView", owner: self, options: nil)?.first! as? WhereTravellingFromQuestionView
            self.scrollContentView.addSubview(whereTravellingFromQuestionView!)
            whereTravellingFromQuestionView?.textfield?.delegate = self
            let bounds = UIScreen.main.bounds
            
            self.whereTravellingFromQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: whereTravellingFromQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (whereTravellingFromQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            
            whereTravellingFromQuestionView?.textfield?.becomeFirstResponder()
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
    }
    func whereTravelingFromQuestionAnswered(){
        whereTravellingFromQuestionView?.textfield?.resignFirstResponder()
        if datesPickedOutQuestionView == nil {
            //Load next question
            datesPickedOutQuestionView = Bundle.main.loadNibNamed("DatesPickedOutQuestionView", owner: self, options: nil)?.first! as? DatesPickedOutQuestionView
            self.scrollContentView.addSubview(datesPickedOutQuestionView!)
            let bounds = UIScreen.main.bounds
            datesPickedOutQuestionView?.button1?.addTarget(self, action: #selector(self.datesPickedOutQuestion_Yes(sender:)), for: UIControlEvents.touchUpInside)
            datesPickedOutQuestionView?.button2?.addTarget(self, action: #selector(self.datesPickedOutQuestion_No(sender:)), for: UIControlEvents.touchUpInside)
            self.datesPickedOutQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: datesPickedOutQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (datesPickedOutQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
    }
    func calendarDateRangeSelected() {
        if decidedOnCityToVisitQuestionView == nil {
            //Load next question
            decidedOnCityToVisitQuestionView = Bundle.main.loadNibNamed("DecidedOnCityToVisitQuestionView", owner: self, options: nil)?.first! as? DecidedOnCityToVisitQuestionView
            self.scrollContentView.addSubview(decidedOnCityToVisitQuestionView!)
            decidedOnCityToVisitQuestionView?.textfield?.delegate = self
            let bounds = UIScreen.main.bounds
            decidedOnCityToVisitQuestionView?.button?.addTarget(self, action: #selector(self.decidedOnCityToVisitQuestion_No(sender:)), for: UIControlEvents.touchUpInside)
            self.decidedOnCityToVisitQuestionView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: decidedOnCityToVisitQuestionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (decidedOnCityToVisitQuestionView?.frame.height)!)
            view.addConstraints([heightConstraint])
            decidedOnCityToVisitQuestionView?.textfield?.becomeFirstResponder()
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()
    }
    
    
    // MARK: Sent events
    func tripNameQuestionButtonClicked(sender:UIButton) {
        if sender.isSelected == true {
            tripNameQuestionAnswered()
        }
    }
    func datesPickedOutQuestion_No(sender:UIButton) {
        
    }
    func datesPickedOutQuestion_Yes(sender:UIButton) {
        if datesPickedOutCalendarView == nil {
            //Load next question
            datesPickedOutCalendarView = Bundle.main.loadNibNamed("DatesPickedOutCalendarView", owner: self, options: nil)?.first! as? DatesPickedOutCalendarView
            self.scrollContentView.addSubview(datesPickedOutCalendarView!)
            let bounds = UIScreen.main.bounds
            self.datesPickedOutCalendarView!.frame = CGRect(x: 0, y: scrollContentView.subviews[scrollContentView.subviews.count - 2].frame.maxY, width: scrollView.frame.width, height: bounds.size.height - scrollView.frame.minY)
            let heightConstraint = NSLayoutConstraint(item: datesPickedOutCalendarView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: (datesPickedOutCalendarView?.frame.height)!)
            view.addConstraints([heightConstraint])            
        }
        updateHeightOfScrollView()
        scrollDownToTopSubview()

    }
    func decidedOnCityToVisitQuestion_No(sender:UIButton) {
        
    }


    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        
        if textField == userNameQuestionView?.userNameQuestionTextfield {
            if userNameQuestionView?.userNameQuestionTextfield?.text == nil || userNameQuestionView?.userNameQuestionTextfield?.text == "" {
                return false
            } else {
                userNameQuestionAnswered()
            }
        }
        
        if textField == tripNameQuestionView?.tripNameQuestionTextfield {
            if tripNameQuestionView?.tripNameQuestionTextfield?.text == nil || tripNameQuestionView?.tripNameQuestionTextfield?.text == "" {
                return false
            } else {
                tripNameQuestionAnswered()
            }
        }
        if textField == whereTravellingFromQuestionView?.textfield {
            if whereTravellingFromQuestionView?.textfield?.text == nil || whereTravellingFromQuestionView?.textfield?.text == "" {
                return false
            } else {
                whereTravelingFromQuestionAnswered()
            }
        }

        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }

}
