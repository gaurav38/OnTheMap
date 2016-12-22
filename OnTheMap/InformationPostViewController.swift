//
//  InformationPostViewController.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 12/3/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import UIKit
import MapKit

class InformationPostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userInputLocation: UITextView!
    @IBOutlet weak var findOnTheMapView: UIView!
    @IBOutlet weak var headerTextView: UITextView!
    @IBOutlet weak var showOnMapView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let blueColor = UIColor(red: 25, green: 100, blue: 192)
    let headerFont = UIFont.systemFont(ofSize: 26, weight: UIFontWeightThin)
    let boldFont = UIFont.boldSystemFont(ofSize: 26.0)
    
    var state: State = .Search
    var coordinate: CLLocationCoordinate2D? = nil
    var userAddress: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIToSearchState()
    }
    
    // Mark: - TextView delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == headerTextView && state == .Search {
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            self.activityIndicator.stopAnimating()
            if error != nil {
                print(error!)
                self.showErrorToUser(error: "Could not determine location")
                return
            }
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                self.coordinate = location?.coordinate
                print("\nlat: \(self.coordinate!.latitude), long: \(self.coordinate!.longitude)")
                
                self.state = .Submit
                self.setUIToSubmitState()
                self.setMapView()
            }
        })
    }
    
    private func showErrorToUser(error: String) {
        let alertController = UIAlertController(title: "Failed!", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setMapView() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!), span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func findAddressOnMap(_ sender: Any) {
        userAddress = userInputLocation.text!
        activityIndicator.startAnimating()
        forwardGeocoding(address: userInputLocation.text!)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        if headerTextView.text!.isEmpty {
            showErrorToUser(error: "Link cannot be empty")
            return
        }
        
        OnTheMapClient.shared.postStudentLocation(address: userAddress!, mediaURL: headerTextView.text!, latitude: (coordinate?.latitude)! as Double, longitude: (coordinate?.longitude)! as Double) { (success, error) in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.showErrorToUser(error: error!)
                }
                return
            }
            
            if success! {
                DispatchQueue.main.async {
                    self.cancel(self)
                }
            }
        }
    }
    
    private func setUIToSearchState() {
        showOnMapView.isHidden = true
        userInputLocation.delegate = self
        headerTextView.delegate = self
        
        findOnMapButton.layer.cornerRadius = 10
        submitButton.layer.cornerRadius = 10
        
        let attributedString = NSMutableAttributedString(string: headerTextView.text)
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: blueColor, range: NSRange(location: 0, length: headerTextView.text.characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: headerFont, range: NSRange(location: 0, length: headerTextView.text.characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: boldFont, range: NSRange(location: 14, length: 8))
        headerTextView.attributedText = attributedString
        headerTextView.textAlignment = NSTextAlignment.center
    }
    
    private func setUIToSubmitState() {
        findOnTheMapView.isHidden = true
        showOnMapView.isHidden = false
        view.backgroundColor = blueColor
        cancelButton.backgroundColor = blueColor
        cancelButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        headerTextView.text = "http://udacity.com"
        headerTextView.backgroundColor = blueColor
        
        let attributedString = NSMutableAttributedString(string: headerTextView.text)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location: 0, length: headerTextView.text.characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: headerFont, range: NSRange(location: 0, length: headerTextView.text.characters.count))
        headerTextView.attributedText = attributedString
        headerTextView.textAlignment = NSTextAlignment.center
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}

enum State {
    case Search
    case Submit
}
