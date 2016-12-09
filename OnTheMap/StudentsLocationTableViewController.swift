//
//  StudentsLocationTableViewController.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import UIKit

class StudentsLocationTableViewController: UITableViewController {
    
    var studentsLocations = [UdacityStudent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseStudentsLocations()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseStudentsLocations()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentlocationcell")! as UITableViewCell
        cell.imageView?.image = #imageLiteral(resourceName: "pin")
        cell.textLabel?.text = studentsLocations[indexPath.row].studentName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let openLink = URL(string: studentsLocations[indexPath.row].studentLink)
        print(openLink!)
        UIApplication.shared.open(openLink!, options: [String: AnyObject](), completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsLocations.count
    }
    
    private func parseStudentsLocations() {
        for dictionary in OnTheMapClient.shared.studentsLocations! {
    
            if let first = dictionary["firstName"] as? String,
                let last = dictionary["lastName"] as? String,
                let mediaURL = dictionary["mediaURL"] as? String {
    
                    print("\(first) \(last), \(mediaURL)")
                    let student = UdacityStudent(studentName: "\(first) \(last)", studentLink: mediaURL)
                    self.studentsLocations.append(student)
            }
        }
    }
    
    @IBAction func postInformation(_ sender: Any) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostViewController")
        
        self.present(viewController, animated: true, completion: nil)
    }
    
}

