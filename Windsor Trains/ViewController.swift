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
    }
    
    func updateLabels(serviceInfo:[[String : String]]) -> Void{
        
        if (timer?.valid==true && timer2?.valid==true){
            timer!.invalidate()
            timer2!.invalidate()
        }
        
        stationLabel.text = serviceInfo[0]["sname"]
        time.text = serviceInfo[0]["nextTrain"]
        
        stationLabel2.text = serviceInfo[1]["sname"]
        time2.text = serviceInfo[1]["nextTrain"]
        
        var centralTime = getTrainTime(serviceInfo[0]["nextTrain"]!)
        var riversideTime = getTrainTime(serviceInfo[1]["nextTrain"]!)
        
        let central:[AnyObject] = [centralTime,timerLabel1]
        let riverside:[AnyObject] = [riversideTime,timerLabel2]

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerProcess:"), userInfo: central, repeats: true)
    
        timer2 = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerProcess:"), userInfo: riverside, repeats: true)
        
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        MyRequest.trainRequest()
    }

    func returnDict(returnDictionary: [[String : String]]) {
        println("from delegate")
        println(returnDictionary)
        updateLabels(returnDictionary)
    }
    
    func wasInitialised() {
            println("delegate is working")
    }
    
    
    func timerProcess(timer:NSTimer) -> Void{
        println("it works!")
        var service:AnyObject = timer.userInfo!
        var now = NSDate()
        
        var traintime = service[0] as NSDate
        var label = service[1] as UILabel
        var elapsedSeconds:NSNumber = now.timeIntervalSinceDate(traintime)
        
        NSLog("Elaped seconds:%ld seconds",elapsedSeconds);
    
        var seconds:NSInteger = elapsedSeconds as Int % 60;
        var minutes:NSInteger = (elapsedSeconds as Int / 60) % 60;
        var hours:NSInteger = elapsedSeconds as Int / (60 * 60);
        var result:NSString = NSString(format: "%02ld:%02ld", minutes, seconds)
        result = result.stringByReplacingOccurrencesOfString("-", withString: "")
        label.text = result
    }
    
    
}



