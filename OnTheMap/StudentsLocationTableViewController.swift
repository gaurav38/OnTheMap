//
//  StudentsLocationTableViewController.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import UIKit

class StudentsLocationTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // Mark: - TableView delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentlocationcell")! as UITableViewCell
        cell.imageView?.image = #imageLiteral(resourceName: "pin")
        let firstName = OnTheMapClient.shared.studentsLocations[indexPath.row].firstName
        let lastName = OnTheMapClient.shared.studentsLocations[indexPath.row].lastName
        cell.textLabel?.text = "\(firstName) \(lastName)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let openLink = URL(string: OnTheMapClient.shared.studentsLocations[indexPath.row].mediaURL)
        print(openLink!)
        UIApplication.shared.open(openLink!, options: [String: AnyObject](), completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OnTheMapClient.shared.studentsLocations.count
    }
    
    @IBAction func logout(_ sender: Any) {
        OnTheMapClient.shared.logoutCurrentUser { (result, error) in
            if result! {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(loginViewController, animated: true, completion: nil)
                }
            } else {
                print(error!)
            }
        }
    }
    
    @IBAction func refreshStudentsLocations(_ sender: Any) {
        OnTheMapClient.shared.getStudentsLocations() { (response, error) in
            if error == nil {
                print("Got the data!")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print(error!)
            }
        }
    }
    
    @IBAction func postInformation(_ sender: Any) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostViewController")
        
        self.present(viewController, animated: true, completion: nil)
    }
}

