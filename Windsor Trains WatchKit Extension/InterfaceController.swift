//
//  InterfaceController.swift
//  Windsor Trains WatchKit Extension
//
//  Created by Joss Manger on 10/12/2014.
//  Copyright (c) 2014 Joss Manger. All rights reserved.
//

import WatchKit
import Foundation

var localBackup = []

class row : NSObject{
    
    @IBOutlet weak var station: WKInterfaceLabel!
    @IBOutlet weak var time: WKInterfaceLabel!
    @IBOutlet weak var trainTimer: WKInterfaceTimer!
    
}

class MainController: WKInterfaceController, NationalRailRequestDelegate{
    
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var errorLabel: WKInterfaceLabel!
    
    @IBAction func refreshButton() {
        watchRequest.trainRequest()
    }
    
    var watchRequest:NationalRailRequest!


    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        watchRequest = NationalRailRequest()
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
        print("Error!", terminator: "")
        print(error, terminator: "")
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
        print("delegate is working... from Apple Watch! main controller", terminator: "")
    }
    
    func createTable(services:[[String:String]]) -> Void{
        table.setNumberOfRows(services.count, withRowType: "stationRow")
        for (index,service) in services.enumerate(){
            
            let thisRow:row = self.table.rowControllerAtIndex(index)! as! row
            
            if let station:String = service["sname"]{
                print(station)
                thisRow.station.setText(station)
            }
            if let time:String = service["nextTrain"]{
                let centralDate = getTrainTime(time)
                thisRow.time.setText(time)
                thisRow.trainTimer.setDate(centralDate)
                thisRow.trainTimer.start()
            } else {
                print("no time recieved")
            }
            
        }
    }
    
    func gotTrainTimes(times: [[String]]) {
        print(times, terminator: "")
    }
    
}

class PageViewController: WKInterfaceController, NationalRailRequestDelegate{
    @IBOutlet var label: WKInterfaceLabel!

    @IBOutlet weak var trainTime: WKInterfaceLabel!
    
    @IBAction func forceRefresh() {
        watchRequest.trainRequest()
    }
    
    @IBAction func list() {
        presentControllerWithName("list", context: self)
    }
    @IBAction func mapView() {
        presentControllerWithName("riversideView", context: self)
    }

    @IBOutlet weak var trainTimer: WKInterfaceTimer!
    
    var watchRequest = NationalRailRequest()
    
    var index = 0
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        watchRequest.delegate = self
        wasInitialised()
        print("did appear")
        
    }
    
    
    //override func contextForSegueWithIdentifier --> awa
    
    
   
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        NSLog("%@ will activate", self)
        
        resultsExist()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    
    override func didAppear() {
        resultsExist()
    }
    
    func resultsExist(){
        if(localBackup.count==0){
            watchRequest.trainRequest()
        } else {
            print("using backup")
            returnDict(localBackup as! [[String : String]])
        }
    }
    
    func returnDict(returnDictionary: [[String : String]]) {
        reshowElements()
        localBackup = returnDictionary
        updateLabels(returnDictionary)
    }
    
    func errorHappened(error: NSError) {
        print("Error!", terminator: "")
        print(error, terminator: "")
    }
    
    func reshowElements(){
        
    }
    
    func wasInitialised() {
        print("delegate is working... from Apple Watch page view 1!", terminator: "")
    }
    
    func updateLabels(services:[[String : String]]) -> Void{
        if let time:String = services[index]["nextTrain"]{
            let centralDate = getTrainTime(time)
            if(centralDate.timeIntervalSinceNow<0.0){
                label.setText("You missed it")
            } else {
                label.setText("Doors will slam in...")
            }
            trainTime.setText(time)
            trainTimer.setDate(centralDate)
            trainTimer.start()
        } else {
            print("no time recieved", terminator: "")
        }
    }
    
}

class PageViewController2 : PageViewController{
    
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
      index = 1
        
    }
    
    override func willActivate() {
        print("will activate")
    }
    

    
    override func wasInitialised() {
        print("delegate is working... from Apple Watch page view 2!")

    }
    
}

class MapController: WKInterfaceController {

    @IBOutlet weak var map: WKInterfaceMap!
    @IBOutlet weak var label: WKInterfaceLabel!
    
    var stationString:String?
    var lat:CLLocationDegrees?
    var long:CLLocationDegrees?
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if (context!.index==1){
        stationString = "Windsor & Eton Riverside"
        self.setTitle("WNR")
        lat = 51.485846
        long = -0.606179
        } else {
            stationString = "Windsor & Eton Central"
            self.setTitle("WNC")
            lat = 51.483270
            long = -0.610370
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
        
        let latDelta:CLLocationDegrees = 0.005  // the bigger, the less zoomed
        let longDelta:CLLocationDegrees = 0.005
        
        // lat/long for location, lat/long delta for zoom height
        
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)  //amalgamate lat/long delta into map zoom heiget
        
        let point:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, long!) // amalgamate lat/long numbers into coordinates
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(point, span) // create region object, which has all the stuff previously set in it
        map.setRegion(region)
        label.setText(stationString)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    


    

}

