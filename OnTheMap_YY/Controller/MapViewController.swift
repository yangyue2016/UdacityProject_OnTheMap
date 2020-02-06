//
//  TabBarViewController.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/10.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        OTMClient.getStudentLocation(completion:handleMultiStudentLocation(locations:error:))
        
    }
    
    @IBAction func updateMap(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        OTMClient.getStudentLocation(completion:handleMultiStudentLocation(locations:error:))
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        OTMClient.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func handleMultiStudentLocation(locations:[StudentLocation]?, error:Error?) {
        guard let locations = locations else {
            present(Alerts.showFailure(title: "Error to load student locations", message: error?.localizedDescription ?? ""), animated: true,completion: nil)
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            return
        }
        addAnnotationsToMap(locations: locations)
    }
    
    func addAnnotationsToMap(locations: [StudentLocation]?){
        
        
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        guard let locations = locations else {
            present(Alerts.showFailure(title: "Error to load student locations", message: "Empty locations"), animated: true,completion: nil)
            return
        }
        
        if !annotations.isEmpty {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for location in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
        } else {
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
                guard !toOpen.isEmpty else {
                    present(Alerts.showFailure(title: "Error", message: "URL Does not Exist!"), animated: true)
                    return
                }
                app.open(URL(string: toOpen) ?? URL(string: "")!, options: [:], completionHandler: nil)
            }
        }
    }
}
