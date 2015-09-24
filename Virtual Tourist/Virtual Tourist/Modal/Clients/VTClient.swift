//
//  VTClient.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/10/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import UIKit

class VTClient: NSObject {
    
    var session: NSURLSession
    
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func taskforgGetImageFromFlickrByLatLong(methodArguments: [String : AnyObject], completionHandler: (JSONResult: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask  {
        
         /* 1. Set the parameters */
        
        /* 2/3. Build the URL and configure the request */
        let urlString = VTClient.Flickr.BASE_URL + VTClient.escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                

                
                VTClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                

            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task;
    }
    
    
    // MARK: - All purpose task method for images
    
    func taskForImageWithSize(size: String, filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: filePath)!
        
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = VTClient.errorForData(data, response: response, error: downloadError!)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }

    
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[VTClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    func showAlert(title: String, message: String, DismissButtonMsg: String, sender: AnyObject){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: DismissButtonMsg, style: UIAlertActionStyle.Default, handler: nil))
        
        
        
        sender.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }

    
    // MARK: - Shared Instance
    
    class func sharedInstance () -> VTClient{
        
        struct Singleton{
            static var sharedInstance = VTClient()
        }
        return Singleton.sharedInstance
    }
}
