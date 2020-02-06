//
//  TableViewController.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/11.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OTMClient.getStudentLocation() { locations, error in
            guard locations != nil else {
                self.present(Alerts.showFailure(title: "Error", message: "Could not get student location"), animated: true)
                self.activityIndicator.stopAnimating()
                return
            }

            DispatchQueue.main.async {
                StudentModel.locations = locations ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    
    @IBAction func updateTable(_ sender: Any) {
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
        StudentModel.locations = locations
        DispatchQueue.main.async {
            // reload table
            self.tableView.reloadData()
        }
    }
    
}


extension TableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "StudentTableViewCell")
        
        let studentLocation = StudentModel.locations[indexPath.row]
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = studentLocation.firstName + " " + studentLocation.lastName
        cell.detailTextLabel?.text = studentLocation.mediaURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let toOpen = StudentModel.locations[indexPath.row].mediaURL
        
        guard !toOpen.isEmpty else {
            present(Alerts.showFailure(title: "Error", message: "URL does not Exist!"), animated: true)
            return
        }
        
        app.open(URL(string: StudentModel.locations[indexPath.row].mediaURL) ?? URL(string: "")!, options: [:], completionHandler: nil)
        
    }

}
