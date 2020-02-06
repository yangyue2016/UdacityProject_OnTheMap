//
//  ViewController.swift
//  OnTheMap_YY
//
//  Created by MacAir11 on 2019/12/9.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaFBButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            activityIndicator.stopAnimating()
            self.present(Alerts.showFailure(title: "Login Failure", message: "Please enter your email and password"), animated: true, completion: nil)
            return
        }

        loginButton.isEnabled = false
        
        OTMClient.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLogin(success:accountKey:sessionId:error:))
        
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        let url = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
    
    
    func handleLogin(success: Bool, accountKey: String? , sessionId: String?, error: Error?){
        setLoggingIn(false)
        guard let _ = accountKey, let _ = sessionId else {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.loginButton.isEnabled = true
                self.present(Alerts.showFailure(title: "Login Failed", message: error?.localizedDescription ?? ""), animated: true,completion: nil)
                return
            }
            return
        }
        
        if success {
            DispatchQueue.main.async {
                StudentModel.sessionId = sessionId!
                StudentModel.accountKey = accountKey!
                OTMClient.getUserName(completion: { (userName, error) in
                    guard let userName = userName else {
                        self.present(Alerts.showFailure(title: "Login Failed", message: error?.localizedDescription ?? ""), animated: true,completion: nil)
                        return
                    }
                    
                    StudentModel.userFirstName = userName.firstName
                    StudentModel.userLastName = userName.lastName
                    
                })

                let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                self.present(controller, animated: true, completion: nil)
            }
        } else {
            self.present(Alerts.showFailure(title: "Login Failed", message: error?.localizedDescription ?? ""), animated: true,completion: nil)
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        loginViaFBButton.isEnabled = !loggingIn
    }
}
