//
//  HPIDOLPlaygroundClient.swift
//  WheresMyHSBC
//
//  Created by loichengllc on 6/6/15.
//  Copyright (c) 2015 Loi Cheng LLC. All rights reserved.
//

import Foundation
import UIKit

let API_KEY = "GET YOUR OWN KEY"

let API_PROTOCOL = "https://"
let API_HOST = "api.idolondemand.com"

let API_PATH_TEXT_QUERY = API_PROTOCOL + API_HOST + "/1/api/sync/querytextindex/v1?text=%@:title&indexes=wiki_eng&apikey=" + API_KEY

let API_PATH_IMAGE_REC = API_PROTOCOL + API_HOST + "/1/api/sync/recognizeimages/v1?url=%@&image_type=complex_3d&match_image=HBC&apikey=" + API_KEY

var jsonData: AnyObject?

class HPIDOLPlaygroundClient : NSObject, NSURLConnectionDataDelegate {
    
    func queryTextIndex(query: String) {
        var filteredQuery = query.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var urlString = String(format: API_PATH_TEXT_QUERY, filteredQuery)
        var url = NSURL(string: urlString)
        if url != nil {
            var request = NSURLRequest(URL: url!)
            NSURLConnection(request: request, delegate: self, startImmediately: true)
        } else {
            //println("url is malformed")
        }
    }
    
    func queryImageRecognition(query: String) {
        var urlString = String(format: API_PATH_IMAGE_REC, query)
        var url = NSURL(string: urlString)
        if url != nil {
            var request = NSURLRequest(URL: url!)
            NSURLConnection(request: request, delegate: self, startImmediately: true)
        } else {
            //println("url is malformed")
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        var error: NSError?
        var jsonObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error)
        if error == nil {
            // printing out the result
            jsonData = jsonObject
            //println(jsonData!)
        } else {
            //println("Unable to serialize received data to json object: " + error!.description)
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        // debugging the error description
        println(error.description)
    }
    
    func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if API_HOST == challenge.protectionSpace.host {
            challenge.sender.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust), forAuthenticationChallenge: challenge)
        }
    }
    
    func getJSON() -> AnyObject? {
        if (jsonData != nil) { NSLog("JSON OK") }
        else { NSLog("JSON NIL") }
        return jsonData
    }
}

