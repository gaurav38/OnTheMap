//
//  UdacityStudent.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 12/1/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import Foundation

struct StudentInformation {
    var firstName: String
    var lastName: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    static var studentsInformation = [StudentInformation]()
    
    init(dictionary: [String: AnyObject]) {
        if let first = dictionary["firstName"] as? String {
            firstName = first
        } else {
            firstName = ""
        }
        if let last = dictionary["lastName"] as? String {
            lastName = last
        } else {
            lastName = ""
        }
        if let url = dictionary["mediaURL"] as? String {
            mediaURL = url
        } else {
            mediaURL = ""
        }
        if let lat = dictionary["latitude"] as? Double {
            latitude = lat
        } else {
            latitude = 0.0
        }
        if let long = dictionary["longitude"] as? Double {
            longitude = long
        } else {
            longitude = 0.0
        }
    }
    
    static func saveStudentInformation(_ results: [[String: AnyObject]]) -> [StudentInformation] {
        studentsInformation.removeAll()
        for result in results {
            studentsInformation.append(StudentInformation(dictionary: result))
        }
        return studentsInformation
    }
}
