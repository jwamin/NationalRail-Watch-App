// Playground - noun: a place where people can play

import Foundation
import UIKit

var str = "Hello, playground"

//let nrToken = "6778f0f8-27b3-4127-984e-f321969b891f"
//
//var url = NSURL(string: "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb6.asmx")
//
//var request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)

var soap = "<?xml version=\"1.0\"?><soap:Envelope xmlns:soap=\"http://www.w3.org/2001/12/soap envelope\"soap:encodingStyle=\"http://www.w3.org/2001/12/soap-encoding\"><soap:Header></soap:Header><soap:Body><soap:Fault></soap:Fault></soap:Body></soap:Envelope>"

//
//var error:NSErrorPointer? = nil
//
//var d = NSXMLDocument(XMLString: soap, options: kNilOptions, error: &error)
//


var xmlString:String = "<?xml version=\"1.0\"><results><item1><name>Something</name><price>10.99</price></item1></results>"
var error: NSErrorPointer? = nil
//var xml:NSXMLDocument = NSXMLDocument(XMLString: xmlString, options: kNilOptions, error: &error)

//xml
//
//var d = NSData(contentsOfFile: "request.xml")
//
//var px = NSXMLParser(data: d)
//
//px.

countElements(xmlString)




var timeArray = ["08:22", "23:41"]

var cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
var centralDate = NSDate()

let mostUnits: NSCalendarUnit = .YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit

var com = cal?.components(mostUnits , fromDate: centralDate)


var hours = timeArray[1].componentsSeparatedByString(":")[0].toInt()


com?.setValue(hours!, forComponent: .HourCalendarUnit)



centralDate = NSCalendar.currentCalendar().dateFromComponents(com!)!

println(centralDate)




let     services  =  [["sname": "Windsor & Eton Central", "nextTrain": "05:48"], ["sname": "Windsor & Eton Riverside", "nextTrain": "05:53"]]

//var indices:[Int] = []
//
//for service in services{
//    var tempArray = services as NSArray
//    indices.append(tempArray.indexOfObject(service))
//
//    find(services,service)
//
//}
//
//indices


let     moreTrains:Array  =  [["sname": "Windsor & Eton Central", "trains": ["22:45","21.22"]], ["sname": "Windsor & Eton Riverside", "trains": ["23:45","01.22"]]]

//let     moreTrainsCopy:Array  =  [["sname": "Windsor & Eton Central"]]
//
//var addArray:[String] = ["22:45","21.22"]




