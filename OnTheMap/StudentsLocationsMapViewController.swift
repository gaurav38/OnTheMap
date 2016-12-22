//
//  FirstViewController.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class StudentsLocationsMapViewController: UIViewController, MKMapViewDelegate {

    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView()
    }
    
    private func createAnnotations() {
        for studentLocation in StudentInformation.studentsInformation {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            annotation.subtitle = studentLocation.mediaURL
            
            annotations.append(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [String: AnyObject](), completionHandler: nil)
            }
        }
    }

    @IBAction func refreshStudentsLocations(_ sender: Any) {
        activityIndicator.startAnimating()
        OnTheMapClient.shared.getStudentsLocations() { (response, error) in
            if error == nil {
                print("Got the data!")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.refreshView()
                }
            } else {
                print(error!)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showErrorToUser(title: "Failed!", message: "Error during refresh.")
                }
            }
        }
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
                DispatchQueue.main.async {
                    self.showErrorToUser(title: "Failed!", message: "Error during log-out.")
                }
            }
        }
    }
    
    @IBAction func postInformation(_ sender: Any) {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostViewController")
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    func refreshView() {
        annotations.removeAll()
        createAnnotations()
        mapView.addAnnotations(annotations)
    }
    
    private func showErrorToUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}

