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
        watchRequest.trainRequest(noOfRequests: 4)
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
        println("delegate is working... from Apple Watch! main controller")
    }
    
    func createTable(services:[[String:String]]) -> Void{
        table.setNumberOfRows(services.count, withRowType: "stationRow")
        for (index,service) in enumerate(services){
            
            let thisRow:row = self.table.rowControllerAtIndex(index)! as row
            
            if let station:String = services[index]["sname"]{
                thisRow.station!.setText(station)
            }
            if let time:String = services[index]["nextTrain"]{
                let centralDate = getTrainTime(time)
                thisRow.time!.setText(time)
                thisRow.trainTimer.setDate(centralDate)
                thisRow.trainTimer.start()
            } else {
                println("no time recieved")
            }
            
        }
    }
    
    func gotTrainTimes(times: [String]) {
        println(times)
    }
    
}

class PageViewController: WKInterfaceController, NationalRailRequestDelegate{

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
    
    override init(context: AnyObject?) {
        super.init(context: context)
        watchRequest.delegate = self
        wasInitialised()
        watchRequest.trainRequest()
    }
    
    
    //override func contextForSegueWithIdentifier --> awa
    

    
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
        println("delegate is working... from Apple Watch page view 1!")
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
        index = 1
    }
    
}

class MapController: WKInterfaceController {

    @IBOutlet weak var map: WKInterfaceMap!
    @IBOutlet weak var label: WKInterfaceLabel!
    
    var stationString:String?
    var lat:CLLocationDegrees?
    var long:CLLocationDegrees?
    
    
    override init(context: AnyObject?) {
        super.init(context: context)
        
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
        
        var latDelta:CLLocationDegrees = 0.005  // the bigger, the less zoomed
        var longDelta:CLLocationDegrees = 0.005
        
        // lat/long for location, lat/long delta for zoom height
        
        
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)  //amalgamate lat/long delta into map zoom heiget
        
        var point:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, long!) // amalgamate lat/long numbers into coordinates
        
        var region: MKCoordinateRegion = MKCoordinateRegionMake(point, span) // create region object, which has all the stuff previously set in it
        map.setCoordinateRegion(region)
        label.setText(stationString)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }
    


    

}

