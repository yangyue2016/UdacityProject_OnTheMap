//
//  AddLocationViewController.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/12.
//  Copyright © 2019 Udacity. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation

class FindLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var uniqueKey: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var mapString: String = ""
    var mediaURL:String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    
    override func viewDidLoad() {
        activityIndicator.stopAnimating()
        super.viewDidLoad()
        
        if !StudentModel.objectId.isEmpty {
            let alert = UIAlertController(title: "", message: "You have alreay posted a student location. Would you like to overwrite your current location?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        //dismiss the keyboard
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationTextField.text = ""
        linkTextField.text = ""
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        activityIndicator.startAnimating()
        if (locationTextField.text?.isEmpty)! || (linkTextField.text?.isEmpty)! {
            present(Alerts.showFailure(title: "Error", message: "Please input location and URL!"), animated: true)
            activityIndicator.stopAnimating()
        }
        else if !(linkTextField.text?.isValidURL)!{
            present(Alerts.showFailure(title: "Error", message: "Please Enter a Valid URL!"), animated: true)
            activityIndicator.stopAnimating()
        }
        else {
            getUserName()
            
        }
    }
    
    func getUserName(){
        OTMClient.getUserName(completion: handleUserName(response:error:))
    }
    
    func handleUserName(response: UserName?,error:Error?){
        if error != nil {
            present(Alerts.showFailure(title: "Error", message: error?.localizedDescription ?? ""), animated: true,completion: nil)
            return
        }
        
        guard let response = response else {
            present(Alerts.showFailure(title: "Error", message: "Could not get student name"), animated: true)
            activityIndicator.stopAnimating()
            return
        }
        
        
        firstName = response.firstName
        lastName = response.lastName

        getCoordinate(location: locationTextField.text!, completion: handleCoordinate(response:error:))
    }
    
}

extension FindLocationViewController : CLLocationManagerDelegate {
    
    func getCoordinate(location : String, completion: @escaping(CLLocationCoordinate2D, Error?) -> Void ) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completion(location.coordinate, nil)
                }
            } else {
                completion(kCLLocationCoordinate2DInvalid, error)
            }
        }
    }
    
    func handleCoordinate(response: CLLocationCoordinate2D, error: Error? ) -> Void{

        if response.latitude == -180 || response.longitude == -180{
            present(Alerts.showFailure(title: "Invalid Location", message: "Please enter a valid location"), animated: true)
            activityIndicator.stopAnimating()
        } else {
            latitude = response.latitude
            longitude = response.longitude
            
            DispatchQueue.main.async  {
                self.activityIndicator.isHidden = true
                guard let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as? AddLocationViewController else {
                    print("Unable to cast ViewController")
                    self.present(Alerts.showFailure(title: "Error", message: "Failed to go to the next step"), animated: true)
                    return
                }
                
                destinationVC.userData.firstName = self.firstName
                destinationVC.userData.lastName = self.lastName
                destinationVC.userData.latitude = self.latitude
                destinationVC.userData.longitude = self.longitude
                destinationVC.userData.mapString = self.locationTextField.text ?? ""
                destinationVC.userData.mediaURL = self.linkTextField.text ?? ""
                destinationVC.newLatitude = self.latitude
                destinationVC.newLongitude = self.longitude
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
            
            activityIndicator.stopAnimating()
        }
    }

}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
}

extension FindLocationViewController : UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications() {
        // Subscribing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func unsubscribeFromKeyboardNotifications() {
        // Unsubscribing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if linkTextField.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)/5
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        // Function to get keyboard height
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
