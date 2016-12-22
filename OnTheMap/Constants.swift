//
//  Constants.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import Foundation

extension OnTheMapClient {
    struct Constants {
        static let RequestScheme = "https"
        static let UdacityHost = "www.udacity.com"
        static let UdacityApiPath = "/api"
        static let UdacitySignUpPage = "https://www.udacity.com/account/auth#!/signup"
        static let ParseHost = "parse.udacity.com"
        static let ParseApiPath = "/parse/classes"
    }
    
    struct UdacityMethods {
        static let Login = "/session"
        static let UserPublicProfile = "/users"
    }
        
    struct UdacityResponseKeys {
        static let UserId = "key"
        static let SessionId = "id"
        static let Account = "account"
        static let Session = "session"
        static let User = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
    }
    
    struct UdacityHeaderValues {
        static let Parse_Application_Id = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let Parse_REST_API_Key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct UdacityHeaderKeys {
        static let Parse_Application_Id = "X-Parse-Application-Id"
        static let Parse_REST_API_Key = "X-Parse-REST-API-Key"
        static let Cookie = "X-XSRF-TOKEN"
    }
    
    struct ParseMethods {
        static let StudentsLocation = "/StudentLocation"
    }
    
    struct ParseBodyKeys {
        static let UserId = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Address = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
}
