//
//  FirstViewController.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import UIKit
import MapKit

class StudentsLocationsMapViewController: UIViewController, MKMapViewDelegate {

    var annotations = [MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseStudentsLocations()
        mapView.delegate = self
        refreshView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseStudentsLocations()
        mapView.delegate = self
        refreshView()
    }
    
    private func parseStudentsLocations() {
        for dictionary in OnTheMapClient.shared.studentsLocations! {
            
            if let first = dictionary["firstName"] as? String,
                let last = dictionary["lastName"] as? String,
                let mediaURL = dictionary["mediaURL"] as? String,
                let lat = dictionary["latitude"] as? Double,
                let long = dictionary["longitude"] as? Double {
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
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
        OnTheMapClient.shared.getStudentsLocations() { (response, error) in
            if error == nil {
                print("Got the data!")
                DispatchQueue.main.async {
                    self.refreshView()
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
    
    func refreshView() {
        annotations.removeAll()
        parseStudentsLocations()
        mapView.addAnnotations(annotations)
    }

}

