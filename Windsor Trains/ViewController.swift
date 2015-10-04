//
//  ViewController.swift
//  Windsor Trains
//
//  Created by Joss Manger on 10/12/2014.
//  Copyright (c) 2014 Joss Manger. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSXMLParserDelegate, NSURLConnectionDelegate, NationalRailRequestDelegate{
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var stationLabel2: UILabel!
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var time2: UILabel!
    
    @IBOutlet weak var timerLabel1: UILabel!
    @IBOutlet weak var timerLabel2: UILabel!
    
    var timer:NSTimer?
    
    var timer2:NSTimer?
    
    var stationString = String()
    
    var timeString = String()
    
    var MyRequest = NationalRailRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MyRequest.delegate = self
        MyRequest.trainRequest()
        timer = NSTimer()
        timer2 = NSTimer()
        resetLabels()
    }
    
    func updateLabels(serviceInfo:[[String : String]]) -> Void{
        if (time.textColor == UIColor.redColor()){
            resetLabels()
        }
        var error = false
        
        disableTimers()
        
        if let centralReturnedTime = serviceInfo[0]["nextTrain"]
        {
            stationLabel.text = serviceInfo[0]["sname"]
            time.text = centralReturnedTime
            let centralTime = getTrainTime(serviceInfo[0]["nextTrain"]!)
            let central:[AnyObject] = [centralTime,timerLabel1]
                    timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerProcess:"), userInfo: central, repeats: true)
        } else {
            error = true
        }
        
        if let riversideReturnedTime = serviceInfo[1]["nextTrain"]{
            stationLabel2.text = serviceInfo[1]["sname"]
            time2.text = riversideReturnedTime
            let riversideTime = getTrainTime(serviceInfo[1]["nextTrain"]!)
            let riverside:[AnyObject] = [riversideTime,timerLabel2]
                 timer2 = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerProcess:"), userInfo: riverside, repeats: true)
        } else {
            error = true
        }
   
        
        if(error){
            errorLabels()
        }
        
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        MyRequest.trainRequest()
    }

    func returnDict(returnDictionary: [[String : String]]) {
        print("from delegate", terminator: "")
        print(returnDictionary, terminator: "")
        updateLabels(returnDictionary)
    }
    
    func wasInitialised() {
            print("delegate is working", terminator: "")
    }
    
    
    func timerProcess(timer:NSTimer) -> Void{
        let service:AnyObject = timer.userInfo!
        let now = NSDate()
        
        let traintime = service[0] as! NSDate
        let label = service[1] as! UILabel
        let elapsedSeconds:NSNumber = now.timeIntervalSinceDate(traintime)
        
        NSLog("Elaped seconds:%ld seconds",elapsedSeconds);
    
        let seconds:NSInteger = elapsedSeconds as Int % 60;
        let minutes:NSInteger = (elapsedSeconds as Int / 60) % 60;
        //var hours:NSInteger = elapsedSeconds as Int / (60 * 60);
        var result:NSString = NSString(format: "%02i:%03i", minutes, seconds)
        print(result, terminator: "")
        result = result.stringByReplacingOccurrencesOfString("-", withString: "")
        label.text = result as String
    }
    
    func errorHappened(error: NSError) {
        print(error, terminator: "")
        errorLabels()
    }
    
    func errorLabels() -> Void{
        disableTimers()
        var label : UILabel
        for (var i=1;i<7;i++){
            label = view.viewWithTag(i) as! UILabel
            label.text = "Error!"
            label.textColor = UIColor.redColor()
        }
    }
    
    func resetLabels() -> Void{
        var label : UILabel
        for (var i=1;i<7;i++){
            label = view.viewWithTag(i) as! UILabel
            label.textColor = UIColor.blackColor()
        }
    }
    
    func disableTimers()->Void{
        if (timer?.valid==true && timer2?.valid==true){
            timer!.invalidate()
            timer2!.invalidate()
        }
    }
    
}



