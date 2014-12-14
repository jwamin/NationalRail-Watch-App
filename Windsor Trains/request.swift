//
//  request.swift
//  Windsor Trains
//
//  Created by Joss Manger on 11/12/2014.
//  Copyright (c) 2014 Joss Manger. All rights reserved.
//

import Foundation

@objc protocol NationalRailRequestDelegate{
    func returnDict(returnDictionary: [[String:String]])
    func wasInitialised()
    optional func errorHappened(error:NSError)
}



class NationalRailRequest: NSObject, NSURLConnectionDelegate, NSXMLParserDelegate {

    var completedRequests = 0
    
    var requestNumber = 0
    
    var delegate:NationalRailRequestDelegate? = nil
    
    var collection:[String] = []
    
    var dict:[String:[String]] = ["Station1":[],"Station2":[]]
    
    var trainServices:[[String:String]] = []
    
    var thisTrain:[String:String] = [:]
    
    // [["sname":"Central","nextTrain":"22:25"],["sname":"SlamDoor","nextTrain":"23:05"]]
    var stations:[String] = ["WNC","WNR"]
    
    var currentElement = String()
    
    var foundValue = String()
    
    var NationalrequestArray:[NSMutableURLRequest] = []
    
    var foundSname:Bool = false
    
    var parser = NSXMLParser()
    
    override init() {
        super.init()
        delegate?.wasInitialised()
    }
    
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        
        //if(currentElement=="locationName"||currentElement=="std"||currentElement=="ldb:crs"){
          //  let workstring = string.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
        let workstring = string
            if(!(workstring==" ")){
                if(!(workstring=="\n")){
                    foundValue += workstring
                }
                
           }
        //}
        
    }
    
    
    func trainRequest() -> Void{
        
        for station in stations{
        
        var file = NSBundle.mainBundle().pathForResource("request", ofType: "xml")
        let d = NSData(contentsOfFile: file!)
        
        let newString = NSString(data: d!, encoding: NSUTF8StringEncoding)
        
        var myStationCode = station
        
        let finalstring = NSString(format: newString!, ApiKey, myStationCode)
        
        let finaldata = finalstring.dataUsingEncoding(NSUTF8StringEncoding)
        
        //println(finalstring)
        
        let url = NSURL(string: "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb6.asmx")
        
        var request = NSMutableURLRequest(URL: url!, cachePolicy:NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
        let length = finaldata?.length
        
        request.HTTPMethod = "POST"
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = finaldata!
        
        NationalrequestArray.append(request)
        }
        startRequests()
    }
    
    func startRequests() -> Void{
        NSURLConnection(request: NationalrequestArray[0], delegate: self)
    }
    
    func continueRequests() -> Void{
       NSURLConnection(request: NationalrequestArray[1], delegate: self)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection){
        if(requestNumber==1){
            println("continue requests called")
            continueRequests()
        }
    }
    
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("yup, error")
        println(error)
        delegate?.errorHappened!(error)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        let returnedData = NSString(data: data, encoding: NSUTF8StringEncoding)!
        println(returnedData)
        parserInit(data)
    }
    
    
    func parserInit(MyData:NSData) -> Void{
        var d = MyData
        parser = NSXMLParser(data: d)
        parser.delegate = self
        parser.parse()
    }
    
    func parserDidStartDocument(parser: NSXMLParser!) {
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        completedRequests++
        println("ended")
        //println(dict)
        //println(collection)
        trainServices.append(thisTrain)
        thisTrain = [:]
        foundSname = false
        println(trainServices)
        
        requestNumber++
        if (completedRequests==2){
            delegate?.returnDict(trainServices)
            
            dict = ["Station1":[],"Station2":[]]
            collection = []
            trainServices = []
            completedRequests=0
            requestNumber=0
        }
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        currentElement = elementName
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
        if(elementName=="std"&&requestNumber==0){
            dict["Station1"]!.append(foundValue)
        } else if (elementName=="std"&&requestNumber==1){
            dict["Station2"]!.append(foundValue)
        } else {
            collection.append(foundValue)
        }
        
        if(elementName=="std"){
            thisTrain["nextTrain"] = foundValue
        } else if (elementName=="locationName" && !foundSname){
        thisTrain["sname"] = foundValue
            foundSname = true
        }
        
        foundValue = String()
        
        
    }
    
    func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        NSLog("%@", parseError)
    }
    
    
    func returnDict()->[String:[String]]{
        return dict
    }
    

    
    
}

