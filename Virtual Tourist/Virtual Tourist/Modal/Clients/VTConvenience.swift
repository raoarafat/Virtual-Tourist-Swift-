//
//  VTConvenience.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/10/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import Foundation

extension VTClient{

    func getImageFromFlickrByLatLong(latitude: Double?, longitude: Double?, completionHandler: (success: Bool, result: [[String:AnyObject]]? , errorString: String?) -> Void) -> NSURLSessionDataTask {
    
    let randomPage = Int(arc4random_uniform(UInt32(50))) + 1
    
    /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
    var mutableMethod : String = VTClient.Methods.AuthenticationSessionNew
    
    let methodArguments = [
        VTClient.ParameterKeys.Method: VTClient.Flickr.METHOD_NAME,
        VTClient.ParameterKeys.ApiKey: VTClient.Flickr.API_KEY,
        VTClient.ParameterKeys.BBox: self.createBoundingBoxString(latitude!, longitude: longitude!),
        VTClient.ParameterKeys.SafeSearch: VTClient.Flickr.SAFE_SEARCH,
        VTClient.ParameterKeys.Extras: VTClient.Flickr.EXTRAS,
        VTClient.ParameterKeys.Format: VTClient.Flickr.DATA_FORMAT,
        VTClient.ParameterKeys.PerPage: VTClient.Flickr.PER_PAGE,
        VTClient.ParameterKeys.Page:  String(randomPage),
        VTClient.ParameterKeys.NoJsonCallBack: VTClient.Flickr.NO_JSON_CALLBACK
    ]
    
    
    /* 2. Make the request */
    
    let task = taskforgGetImageFromFlickrByLatLong(methodArguments, completionHandler: { JSONResult, error in

   // let task = taskForPOSTCommonLoginMethod(mutableMethod, body: jsonBody!) { JSONResult, error in
        
        /* 3. Send the desired value(s) to completion handler */
        if let error = error {
            completionHandler(success: false , result: nil, errorString: VTClient.Errors.LoginFailed)
        } else {
            
            
                if let photosDictionary = JSONResult.valueForKey(VTClient.JSONResponseKeys.Photos) as? [String:AnyObject] {
                    
                   // if let totalPages = photosDictionary[VTClient.JSONResponseKeys.Photo] as? Int {
                    if let photosArray = photosDictionary[VTClient.JSONResponseKeys.Photo] as? [[String: AnyObject]] {

                        completionHandler(success: true ,  result: photosArray, errorString: nil)
                    }else               {
                        completionHandler(success: false , result: nil, errorString: VTClient.Errors.LoginFailed)
                    }
            }
            }
           
            
        
    })
    
    return task
    
}

    // MARK: Helpers
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - VTClient.Flickr.BOUNDING_BOX_HALF_WIDTH, VTClient.Flickr.LON_MIN)
        let bottom_left_lat = max(latitude - VTClient.Flickr.BOUNDING_BOX_HALF_HEIGHT, VTClient.Flickr.LAT_MIN)
        let top_right_lon = min(longitude + VTClient.Flickr.BOUNDING_BOX_HALF_HEIGHT, VTClient.Flickr.LON_MAX)
        let top_right_lat = min(latitude + VTClient.Flickr.BOUNDING_BOX_HALF_HEIGHT, VTClient.Flickr.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
}

}
    