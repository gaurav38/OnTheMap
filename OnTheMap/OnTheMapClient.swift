//
//  OnTheMapClient.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import Foundation

class OnTheMapClient {
    static let shared = OnTheMapClient()
    
    let session = URLSession.shared
    var currentUser: LocalUser? = nil
    var sessionId: String?
    var userId: String?
    var facebookAccessToken: String?
    
    var studentsLocations = [StudentLocation]()
    
    func taskForPOSTMethod(_ request: URLRequest, isUdacityRequest: Bool, completionHandler: @escaping(_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        print(request.url!)
        
        var request = request
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                completionHandler(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard error == nil else {
                print("[taskForPOSTMethod]: \(error!.localizedDescription)")
                if error!.localizedDescription == "The network connection was lost." {
                    sendError(error!.localizedDescription)
                } else {
                    sendError("There was an error with your request \(error)")
                }
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 403 {
                    sendError("Invalid credentials.")
                    return
                } else if !(statusCode >= 200 && statusCode <= 299) {
                    print("[taskForPOSTMethod]: Request code other than 2xx")
                    sendError("Unsuccessful request.")
                    return
                }
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, isUdacityRequest, completionHandlerForConvertData: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    func taskForGETMethod(_ request: URLRequest, isUdacityRequest: Bool, completionHandler: @escaping (_ data: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        print(request.url!)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                completionHandler(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("[taskForGETMethod]: \(error.debugDescription)")
                sendError("There was an error with your request")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("[taskForGETMethod]: Request code other than 2xx")
                sendError("Unsuccessful request.")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, isUdacityRequest, completionHandlerForConvertData: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, _ isUdacityData: Bool, completionHandlerForConvertData: (_ result: AnyObject?, _ error: String?) -> Void) {
        
        var newData = data
        if isUdacityData {
            let range = Range(uncheckedBounds: (5, newData.count))
            newData = newData.subdata(in: range)
        }
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
        } catch {
            print("Could not parse the data as JSON: '\(data)'")
            completionHandlerForConvertData(nil, "Could not parse the data as JSON")
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
}
