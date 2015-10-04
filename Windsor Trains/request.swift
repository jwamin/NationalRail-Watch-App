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
    optional func gotTrainTimes(times:[[String]])
    optional func errorHappened(error:NSError)
}

class NationalRailRequest: NSObject, NSURLConnectionDelegate, NSXMLParserDelegate,NSURLSessionDelegate,NSURLSessionDataDelegate {
    
    var completedRequests = 0
    
    var requestNumber = 0
    
    var requestedRequests = 1
    
    var foundTrain = false
    
    var delegate:NationalRailRequestDelegate? = nil
    
    var trainServices:[[String:String]] = []
    
    var thisTrain:[String:String] = [:]
    
    var services:[[String]] = [[],[]]
    
    // [["sname":"Central","nextTrain":"22:25"],["sname":"SlamDoor","nextTrain":"23:05"]]
    var stations:[String] = ["WNC","WNR"]
    
    var currentElement = String()
    
    var foundValue = String()
    
    //var connection = NSURLConnection()
    
    var NationalrequestArray:[NSMutableURLRequest] = []
    
    var foundSname:Bool = false
    
    var parser = NSXMLParser()
    
    var returnStructure = TrainData()
    
    override init() {
        super.init()
        delegate?.wasInitialised()
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        let workstring = string
        if(!(workstring==" ")){
            if(!(workstring=="\n")){
                foundValue += workstring
            }
            
        }
        
    }
    
    
    func trainRequest(noOfRequests:Int = oneRequest) -> Void{
        requestedRequests = noOfRequests
        for station in stations{
            
            let file:String! = NSBundle.mainBundle().pathForResource("request", ofType: "xml")
            let d:NSData! = NSData(contentsOfFile: file)
            
            let newString:NSString! = NSString(data: d, encoding: NSUTF8StringEncoding)
            
            let myStationCode = station
            let requestInt = String(noOfRequests)
            let finalstring = NSString(format: newString, ApiKey, requestInt, myStationCode)
            
            let finaldata = finalstring.dataUsingEncoding(NSUTF8StringEncoding)!
            
            //println(finalstring)
            
            let url:NSURL! = NSURL(string: "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb6.asmx")
            
            let request = NSMutableURLRequest(URL: url, cachePolicy:NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
            //let length = finaldata.length
            
            request.HTTPMethod = "POST"
            request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = finaldata
            
            NationalrequestArray.append(request)
        }
        startRequests()
    }
    
    
    
    func startRequests() -> Void{
    //    NSURLConnection(request: NationalrequestArray[0], delegate: self, startImmediately: true)!
  
        
        //NSURLSession.sharedSession().dataTaskWithRequest(NationalrequestArray[0])
        
        print("start called")
        let session = NSURLSession.sharedSession()
        for trainrequest in NationalrequestArray{
            let request = session.dataTaskWithRequest(trainrequest, completionHandler: {
                (data,response,errr) in
                if ((errr) != nil){
                    print("fail?")
                    print(errr)
                } else {
                    print("success?")
                    self.parserInit(data!)
                }
            })
            request.resume()
        }
    }
    
    
 /*
    func continueRequests() -> Void{
        print("continue called")
        let request = NSURLSession.sharedSession().dataTaskWithRequest(NationalrequestArray[1], completionHandler: {
            (data,response,errr) in
            if ((errr) != nil){
                print("err")
                print(errr)
            } else {
                print("second request data")
              self.parserInit(data!)
            }
        })
        request.resume()
    }
   
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        //if(requestNumber==1){
            print("continue requests called", terminator: "")
            continueRequests()
        //}
    }
    

    
    func connectionDidFinishLoading(connection: NSURLConnection){
        if(requestNumber==1){
            print("continue requests called", terminator: "")
            continueRequests()
        }
    }

    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print("yup, error", terminator: "")
        print(error, terminator: "")
        delegate?.errorHappened!(error)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        _ = NSString(data: data, encoding: NSUTF8StringEncoding)!
        //println(returnedData)
        parserInit(data)
    }
    */
    
    
    //#PRAGMA MARK XML Parser Delegate methods
    
    func parserInit(MyData:NSData) -> Void{
        let d = MyData
        parser = NSXMLParser(data: d)
        parser.delegate = self
        parser.parse()
    }
    
    func parserDidStartDocument(parser: NSXMLParser) {
        
    }
    
    
    func resetVars()->Void{
        thisTrain = [:]
        services = [[],[]]
        trainServices = []
        completedRequests=0
        requestNumber=0
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        completedRequests++
        print("ended")
        trainServices.append(thisTrain)
        thisTrain = [:]
        foundSname = false
        foundTrain = false
        requestNumber++
        
        print("completed requests: \(completedRequests)")
        print("requestnumber requests: \(requestNumber)")
        if (completedRequests==2){
            print("requests completed")
            print(trainServices, terminator: "")
            print(services, terminator: "")
            
            delegate?.returnDict(trainServices)
            resetVars()
        }
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if(elementName=="std"){
            if (foundTrain != true){
                thisTrain["nextTrain"] = foundValue
                foundTrain=true
            }
            services[requestNumber].append(foundValue)
            print(services, terminator: "")
        } else if (elementName=="locationName" && !foundSname){
            thisTrain["sname"] = foundValue
            foundSname = true
        }
        
        foundValue = String()
        
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        NSLog("%@", parseError)
    }
    
}

func getTrainTime(timeString:String) -> NSDate{
    let timeArray:[String] = timeString.componentsSeparatedByString(":")
    let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    var date = NSDate()
    let mostUnits: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute]
    let com = cal?.components(mostUnits , fromDate: date)
    let hours = Int(timeArray[0])
    let minute = Int(timeArray[1])
    com?.setValue(hours!, forComponent: .Hour)
    com?.setValue(minute!, forComponent: .Minute)
    date = NSCalendar.currentCalendar().dateFromComponents(com!)!
    
    return date
}

struct TrainData {
    var trainServices:[[String:String]]
    var trains:[String]
    
    init(){
        trainServices = []
        trains = []
    }
    
}