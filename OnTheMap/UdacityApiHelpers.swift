//
//  UdacityApiHelpers.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import Foundation
import FBSDKLoginKit

extension OnTheMapClient {
    
    func loginCurrentUser(userName: String, password: String, completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        getUdacitySessionId(username: userName, password: password) { (success, error) in
            if error != nil {
                completionHandler(false, error!)
            } else {
                self.getPublicUserData { (success, error) in
                    if error != nil {
                        completionHandler(false, error!)
                    } else {
                        completionHandler(true, nil)
                    }
                }
            }
        }
    }
    
//    func loginCurrentUserWithFacebook(completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
//        getUdacitySessionIdWithFacebook { (success, error) in
//            if error != nil {
//                completionHandler(false, error!)
//            } else {
//                self.getPublicUserData { (success, error) in
//                    if error != nil {
//                        completionHandler(false, error!)
//                    } else {
//                        completionHandler(true, nil)
//                    }
//                }
//            }
//        }
//    }
    
//    func logoutUsingFacebook() {
//        let manager = FBSDKLoginManager()
//        manager.logOut()
//        FBSDKAccessToken.setCurrent(nil)
//        FBSDKProfile.setCurrent(nil)
//    }
    
    func getUdacitySessionIdWithFacebook(completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        let request = URLRequest(url: getUdacityURLFromParameters(parameters: [String: AnyObject](), withPathExtension: UdacityMethods.Login))
        
        let parameters = ["facebook_mobile": ["access_token":  facebookAccessToken!]]
        
        let _ = taskForPOSTMethod(request, parameters as [String: AnyObject], isUdacityRequest: true) { (response, error) in
            if error == nil {
                if let response = response {
                    if let account = response[UdacityResponseKeys.Account] as? [String: AnyObject] {
                        self.userId = account[UdacityResponseKeys.UserId] as? String
                    }
                    if let session = response[UdacityResponseKeys.Session] as? [String: AnyObject] {
                        self.sessionId = session[UdacityResponseKeys.SessionId] as? String
                    }
                }
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func getUdacitySessionId(username: String, password: String, completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        let request = URLRequest(url: getUdacityURLFromParameters(parameters: [String: AnyObject](), withPathExtension: UdacityMethods.Login))
        let parameters = ["udacity": ["username": username, "password": password]]
        
        let _ = taskForPOSTMethod(request, parameters as [String : AnyObject], isUdacityRequest: true) { (response, error) in
            if error == nil {
                if let response = response {
                    if let account = response[UdacityResponseKeys.Account] as? [String: AnyObject] {
                        self.userId = account[UdacityResponseKeys.UserId] as? String
                    }
                    if let session = response[UdacityResponseKeys.Session] as? [String: AnyObject] {
                        self.sessionId = session[UdacityResponseKeys.SessionId] as? String
                    }
                }
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func getStudentsLocations(completionHandler: @escaping (_ locations: AnyObject?, _ error: String?) -> Void) {
        
        let parameters = [
            "limit": "100" as AnyObject,
            "order": "-updatedAt" as AnyObject
        ] as [String : AnyObject]
        
        let url = getParseURLFromParameters(parameters: parameters, withPathExtension: ParseMethods.StudentsLocation)
        
        var request = URLRequest(url: url)
        request.addValue(OnTheMapClient.UdacityHeaderValues.Parse_Application_Id, forHTTPHeaderField: OnTheMapClient.UdacityHeaderKeys.Parse_Application_Id)
        request.addValue(OnTheMapClient.UdacityHeaderValues.Parse_REST_API_Key, forHTTPHeaderField: OnTheMapClient.UdacityHeaderKeys.Parse_REST_API_Key)
        
        let _ = taskForGETMethod(request, isUdacityRequest: false) { (response, error) in
            if error == nil {
                if let response = response?["results"] as? [[String: AnyObject]] {
                    self.studentsLocations.removeAll()
                    for dictionary in response {
                        
                        if let first = dictionary["firstName"] as? String,
                            let last = dictionary["lastName"] as? String,
                            let mediaURL = dictionary["mediaURL"] as? String,
                            let lat = dictionary["latitude"] as? Double,
                            let long = dictionary["longitude"] as? Double {
                            
                            let studentLocation = StudentLocation(firstName: first, lastName: last, mediaURL: mediaURL, latitude: lat, longitude: long)
                            self.studentsLocations.append(studentLocation)
                        }
                    }
                    completionHandler(self.studentsLocations as AnyObject?, nil)
                }
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    func postStudentLocation(address: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {

        var request = URLRequest(url: getParseURLFromParameters(parameters: [String: AnyObject](), withPathExtension: ParseMethods.StudentsLocation))
        
        request.addValue(UdacityHeaderValues.Parse_Application_Id, forHTTPHeaderField: UdacityHeaderKeys.Parse_Application_Id)
        request.addValue(UdacityHeaderValues.Parse_REST_API_Key, forHTTPHeaderField: UdacityHeaderKeys.Parse_REST_API_Key)
        let parameters = [
            ParseBodyKeys.UserId: currentUser!.userId,
            ParseBodyKeys.FirstName: currentUser!.firstName,
            ParseBodyKeys.LastName: currentUser!.lastName,
            ParseBodyKeys.Address: address,
            ParseBodyKeys.MediaURL: mediaURL,
            ParseBodyKeys.Latitude: latitude,
            ParseBodyKeys.Longitude: longitude
        ] as [String : Any]
        
        let _ = taskForPOSTMethod(request, parameters as [String : AnyObject], isUdacityRequest: false) { (response, error) in
            if error != nil {
                completionHandler(false, "Could not post your location")
            } else {
                completionHandler(true, nil)
            }
        }
    }
    
    func getPublicUserData(completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        
        let request = URLRequest(url: getUdacityURLFromParameters(parameters: [String: AnyObject](), withPathExtension: "\(UdacityMethods.UserPublicProfile)/\(self.userId!)"))
        
        let _ = taskForGETMethod(request, isUdacityRequest: true) { (response, error) in
            if error == nil {
                if let user = response?["user"] as? [String: AnyObject] {
                    if let firstName = user[UdacityResponseKeys.firstName] as? String,
                        let lastName = user[UdacityResponseKeys.lastName] as? String {
                        self.currentUser = LocalUser(firstName: firstName, lastName: lastName, userId: self.userId!)
                        completionHandler(true, nil)
                    } else {
                        completionHandler(false, "Unable to fetch user data")
                    }
                }
            } else {
                completionHandler(false, "Unable to fetch user data")
            }
        }
    }
    
    func logoutCurrentUser(completionHandler: @escaping (_ success: Bool?, _ error: String?) -> Void) {
        var request = URLRequest(url: getUdacityURLFromParameters(parameters: [String: AnyObject](), withPathExtension: UdacityMethods.Login))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: UdacityHeaderKeys.Cookie)
        }
        let _ = taskForDELETEMethod(request, isUdacityRequest: true) { (response, error) in
            if (error == nil) {
                completionHandler(true, nil)
            } else {
                print(error!)
                completionHandler(false, "Failed to logout")
            }
        }
    }
    
    private func getParseURLFromParameters(parameters: [String: AnyObject], withPathExtension: String?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.RequestScheme
        components.host = Constants.ParseHost
        components.path = Constants.ParseApiPath + (withPathExtension ?? "")
    
        if !parameters.isEmpty {
            components.queryItems = [URLQueryItem]()
    
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value as? String)
                components.queryItems?.append(queryItem)
            }
        }
        return components.url!
    }
    
    private func getUdacityURLFromParameters(parameters: [String: AnyObject], withPathExtension: String?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.RequestScheme
        components.host = Constants.UdacityHost
        components.path = Constants.UdacityApiPath + (withPathExtension ?? "")
        
        if !parameters.isEmpty {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        return components.url!
    }
}
