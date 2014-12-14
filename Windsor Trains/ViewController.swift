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
    
    var stationString = String()
    
    var timeString = String()
    
    var MyRequest = NationalRailRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MyRequest.delegate = self
        MyRequest.trainRequest()
    }
    
    func updateLabels(serviceInfo:[[String : String]]) -> Void{
        
        stationLabel.text = serviceInfo[0]["sname"]
        time.text = serviceInfo[0]["nextTrain"]
        
        stationLabel2.text = serviceInfo[1]["sname"]
        time2.text = serviceInfo[1]["nextTrain"]
        
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
    
}