//
//  AddLocationViewController.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/12.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    struct UserData {
        var uniqueKey = ""
        var firstName = ""
        var lastName = ""
        var mapString = ""
        var mediaURL = ""
        var latitude = 0.0
        var longitude = 0.0
    }
    
    var userData =  UserData()
    var newLatitude: Double = 0.0
    var newLongitude: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setMapAnnotation()
    }
    
    
    @IBAction func submit(_ sender: Any) {
        DispatchQueue.main.async {
            self.setUserInfo()
        }
    }
    
    func setUserInfo(){
        guard StudentModel.accountKey != "" else {
            present(Alerts.showFailure(title: "Error", message: "No account!"), animated: true)
            return
        }
        
        print("StudentModel.objectId",StudentModel.objectId)
        print("StudentModel.accountKey",StudentModel.accountKey)

        
        if StudentModel.objectId != "" {
            OTMClient.putStudentLocation(uniqueKey: StudentModel.accountKey, firstName: userData.firstName, lastName: userData.lastName, mapString: userData.mapString, mediaURL: userData.mediaURL, latitude: userData.latitude, longitude: userData.longitude, completion: handlePostStudentLocation(postStudentLocation:error:))
        } else {
            OTMClient.postNewStudentLocation(uniqueKey: StudentModel.accountKey, firstName: userData.firstName, lastName: userData.lastName, mapString: userData.mapString, mediaURL: userData.mediaURL, latitude: userData.latitude, longitude: userData.longitude, completion: handlePostStudentLocation(postStudentLocation:error:))
        }
   
    }
    
    func setMapAnnotation(){
        
        if userData.latitude == 0 || userData.longitude == 0 {
            present(Alerts.showFailure(title: "Error to load student locations", message: "Empty locations"), animated: true,completion: nil)
            return
        }

        let lat = CLLocationDegrees(userData.latitude)
        let long = CLLocationDegrees(userData.longitude)
            
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
        let first = userData.firstName
        let last = userData.lastName
        let mediaURL = userData.mediaURL
            
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
        
        
        // When the array is complete, we add the annotations to the map.
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            let coordinateRegion = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 30000, longitudinalMeters: 30000)
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    func handlePostStudentLocation(postStudentLocation: PostStudentLocation?, error:Error?) {
        guard error == nil else {
            present(Alerts.showFailure(title: "Error Posting", message: error?.localizedDescription ?? ""), animated: true)
            return
        }
        //dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async {
            StudentModel.locations = []
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}


extension AddLocationViewController : MKMapViewDelegate{
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
}
