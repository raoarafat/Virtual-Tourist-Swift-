//
//  VTConstants.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/10/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import Foundation
import UIKit

extension VTClient {
    

    struct Flickr {
        
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "c659a451ad26fd31af8fcf10f600f0f4"
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let PER_PAGE = "15"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        
    }
    
    // MARK: - Errors
    struct Errors {
        
        static let StudentInfoLocationFailed = "Student Location Failed."
        static let LoginFailed = "Login Failed (Session ID)."
        static let ReverseGeocodingFailed = "Forward Geocoding Failed."
        static let Error = "Error!"
        static let Dismiss = "Dismiss"
        static let OK = "OK"
        static let EmptyUrl = "Media URL Empty"
        static let WrongURL = "Please enter correct URL"
        static let OverriteLocation = "You have already posted a location. Do you want to overrite you location?"
        static let StudentInformationFailed = "Student Information Failed. Please Refresh it again."
        static let LogoutFailed = "Logout Failed."
    }
    
    // MARK: - Messages
    struct Messages {
        
        static let Overrite = "Overrite"
        static let OverriteLocation = "You have already posted a location. Do you want to overrite you location?"
        static let FbAuthFailed = "Something wrong with facebook authentication, please try again"
        
    }
    
    
    // MARK: - Methods
    struct Methods {
        
        
        // MARK: Authentication
        static let AuthenticationSessionNew = "session"
        
        
        // MARK: User
        static let UserInformation = "users/"
        
        
        // "https://api.parse.com/1/classes/StudentLocation?limit=100"
        
        //https://api.parse.com/1/classes/StudentLocation
        
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        static let Method = "method"
        static let BBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let PerPage = "per_page"
        static let Page = "page"
        static let NoJsonCallBack = "nojsoncallback"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let Password = "password"
        static let UserName = "username"
        static let FBAccessToken = "access_token"
        static let Udacity = "udacity"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
        
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let Photos = "photos"
        static let Photo = "photo"
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        static let Title = "title"
        static let ImagePath = "url_m"
        static let ID = "id"
    }
    
    
}
