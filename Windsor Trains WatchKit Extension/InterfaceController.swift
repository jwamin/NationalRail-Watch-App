//
//  InterfaceController.swift
//  Windsor Trains WatchKit Extension
//
//  Created by Joss Manger on 10/12/2014.
//  Copyright (c) 2014 Joss Manger. All rights reserved.
//

import WatchKit
import Foundation

class row : NSObject{
    
    @IBOutlet weak var station: WKInterfaceLabel!
    @IBOutlet weak var time: WKInterfaceLabel!
    @IBOutlet weak var trainTimer: WKInterfaceTimer!
    
}

class MainController: WKInterfaceController,NationalRailRequestDelegate{
    
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var errorLabel: WKInterfaceLabel!
    
    @IBAction func refreshButton() {
        watchRequest.trainRequest()
    }
    
    var watchRequest = NationalRailRequest()

    override init(context: AnyObject?) {
        super.init(context: context)
        watchRequest.delegate = self
        wasInitialised()
        watchRequest.trainRequest()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    
    func returnDict(returnDictionary: [[String : String]]) {
        reshowElements()
        createTable(returnDictionary)
    }
    
    func errorHappened(error: NSError) {
        println("Error!")
        println(error)
            self.table.setAlpha(0.0)
            self.table.setHidden(true)
            self.errorLabel.setHidden(false)
            self.errorLabel.setAlpha(1.0)
    }
    
    func reshowElements(){
            self.table.setAlpha(1.0)
            self.table.setHidden(false)
            self.errorLabel.setHidden(true)
            self.errorLabel.setAlpha(0.0)
    }
    
    func wasInitialised() {
        println("delegate is working... from Apple Watch!")
    }
    
    func createTable(services:[[String:String]]) -> Void{
        table.setNumberOfRows(services.count, withRowType: "stationRow")
        for(var i=0;i<services.count;i++){
            let thisRow:row = self.table.rowControllerAtIndex(i)! as row
            
            if let station:String = services[i]["sname"]{
                thisRow.station!.setText(station)
            }
            if let time:String = services[i]["nextTrain"]{
                let centralDate = getTrainTime(time)
                thisRow.time!.setText(time)
                thisRow.trainTimer.setDate(centralDate)
                thisRow.trainTimer.start()
            } else {
                println("no time recieved")
            }
            
        }
    }
    
}

class PageViewController: WKInterfaceController, NationalRailRequestDelegate{

    @IBOutlet weak var trainTime: WKInterfaceLabel!
    
    @IBOutlet weak var trainTimer: WKInterfaceTimer!
    
    var watchRequest = NationalRailRequest()
    
    var index = 0
    
    override init(context: AnyObject?) {
        super.init(context: context)
        watchRequest.delegate = self
        wasInitialised()
        watchRequest.trainRequest()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    
    func returnDict(returnDictionary: [[String : String]]) {
        reshowElements()
        updateLabels(returnDictionary)
    }
    
    func errorHappened(error: NSError) {
        println("Error!")
        println(error)
    }
    
    func reshowElements(){
        
    }
    
    func wasInitialised() {
        println("delegate is working... from Apple Watch!")
    }
    
    func updateLabels(services:[[String : String]]) -> Void{
        if let time:String = services[index]["nextTrain"]{
            let centralDate = getTrainTime(time)
            trainTime.setText(time)
            trainTimer.setDate(centralDate)
            trainTimer.start()
        } else {
            println("no time recieved")
        }
    }
    
}

class PageViewController2 : PageViewController{
    
    
    override init(context: AnyObject?) {
        super.init(context: context)
        watchRequest.delegate = self
        wasInitialised()
        watchRequest.trainRequest()
        index = 1
    }
    
}

