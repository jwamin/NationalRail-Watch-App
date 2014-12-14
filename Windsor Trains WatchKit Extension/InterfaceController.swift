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
        //UIView.animateWithDuration(1.0, animations: {
            self.table.setAlpha(0.0)
            self.table.setHidden(true)
            self.errorLabel.setHidden(false)
            self.errorLabel.setAlpha(1.0)
        //})
    }
    
    func reshowElements(){
        //UIView.animateWithDuration(1.0, animations: {
            self.table.setAlpha(1.0)
            self.table.setHidden(false)
            self.errorLabel.setHidden(true)
            self.errorLabel.setAlpha(0.0)
        //})
    }
    
    func wasInitialised() {
        println("delegate is working... from Apple Watch!")
    }
    
    func createTable(services:[[String:String]]) -> Void{
        table.setNumberOfRows(services.count, withRowType: "stationRow")
        for(var i=0;i<services.count;i++){
            let thisRow:row = self.table.rowControllerAtIndex(i)! as row
            let station:String = services[i]["sname"]!
            let time:String = services[i]["nextTrain"]!
            thisRow.station!.setText(station)
            thisRow.time!.setText(time)
            
            let timeArray = time.componentsSeparatedByString(":")
            
            let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            var centralDate = NSDate()
            
            let mostUnits: NSCalendarUnit = .YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit
            
            let com = cal?.components(mostUnits , fromDate: centralDate)
            
            
            let hours = timeArray[0].toInt()
            
            let minute = timeArray[1].toInt()
            
            
            com?.setValue(hours!, forComponent: .HourCalendarUnit)
            com?.setValue(minute!, forComponent: .MinuteCalendarUnit)
            
            
            centralDate = NSCalendar.currentCalendar().dateFromComponents(com!)!
            
            
            thisRow.trainTimer.setDate(centralDate)
            
            thisRow.trainTimer.start()
            
            
            
        }
    }
    
}

