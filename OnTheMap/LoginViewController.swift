//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Gaurav Saraf on 11/28/16.
//  Copyright © 2016 Gaurav Saraf. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController, UITextFieldDelegate, LoginButtonDelegate {

    @IBOutlet weak var emailTextField: BetterTextField!
    @IBOutlet weak var passwordTextField: BetterTextField!
    @IBOutlet weak var loginWithUdacityButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rootStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let facebookLoginButton = LoginButton(readPermissions: [.publicProfile, .email])
        facebookLoginButton.delegate = self
        rootStackView.addArrangedSubview(facebookLoginButton)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - Facebook login
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
        case .cancelled:
            print("User cancelled login.")
        case .success( _, _, let accessToken):
            print("Facebook login successful!")
            activityIndicator.startAnimating()
            OnTheMapClient.shared.facebookAccessToken = accessToken.authenticationToken
            print("Facebook token: \(accessToken.authenticationToken)")
            OnTheMapClient.shared.loginCurrentUserWithFacebook { (success, error) in
                if error == nil {
                    print("Established seesion with Udacity using Facebook.")
                    self.loadStudentsLocations()
                } else {
                    DispatchQueue.main.async {
                        self.showErrorToUser(error: error!)
                        self.enableUI()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        return
    }
    
    // MARK: - Text Field delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField && textField.text! == "Email" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Udacity Login
    
    @IBAction func UdacityLoginButtonClicked(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        disableUI()
        activityIndicator.startAnimating()
        
        OnTheMapClient.shared.loginCurrentUser(userName: emailTextField.text!, password: passwordTextField.text!) { (sucess: Bool?, error: String?) in
            if error == nil {
                print("Login successful")
                self.loadStudentsLocations()
            } else {
                DispatchQueue.main.async {
                    self.showErrorToUser(error: error!)
                    self.enableUI()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func showErrorToUser(error: String) {
        let alertController = UIAlertController(title: "Login failed!", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func SignUpButtonClicked(_ sender: Any) {
        let openLink = URL(string: OnTheMapClient.Constants.UdacitySignUpPage)
        UIApplication.shared.open(openLink!, options: [String: AnyObject](), completionHandler: nil)
    }
    
    private func loadStudentsLocations() {
        OnTheMapClient.shared.getStudentsLocations() { (response, error) in
            if error == nil {
                print("Got the data!")
            } else {
                print(error!)
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "LaunchTabView", sender: self)
            }
        }
    }
}

extension LoginViewController {
    func disableUI() {
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        loginWithUdacityButton.isEnabled = false
        signUpButton.isEnabled = false
    }
    
    func enableUI() {
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        loginWithUdacityButton.isEnabled = true
        signUpButton.isEnabled = true
    }
}
