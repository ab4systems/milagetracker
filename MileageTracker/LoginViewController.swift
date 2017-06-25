//
//  LoginViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 04/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4


class LoginViewController: FormViewController {
    
    
    @IBOutlet weak var facebookContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if scrollView.contentSize.height != 0 && firstTime{
            let constraint = scrollView.frame.height - scrollView.contentSize.height
            if constraint > 0 {
                facebookContainerHeight.constant = constraint + 160
            }
            firstTime = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.changeStatusBarColor(color : UIColor.white)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if Utils.isConnectedToNetwork(){
            if usernameField.text!.isEmpty{
                usernameField.textColor = UIColor.red
                usernameField.text! = "Introduceți numele de utiliztor"
            }
            if passwordField.text!.isEmpty{
                passwordField.textColor = UIColor.red
                passwordField.isSecureTextEntry = false
                passwordField.text! = "Introduceți parola"
            }
            if passwordField.textColor != UIColor.red &&
                usernameField.textColor != UIColor.red {
                startActivity()
                PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!, block: { (user, error) -> Void in
                    if error != nil{
                        self.stopActivity()
                        if (error! as NSError).code == 101 {
                            Utils.showAlert(controller: self, message: "Nume de utilizator sau parola incorecte")
                        }else{
                            Utils.showAlert(controller: self, message: "Eroare la conectare. Vă rugăm să reîncercați mai târziu!")
                        }
                    }
                    if user != nil {
                        self.goToApp()
                    } else {
                        self.stopActivity()
                        Utils.showAlert(controller: self, message: "Eroare la conectare. Vă rugăm să reîncercați mai târziu!")
                    }
                })
                
            }
        }else{
            self.stopActivity()
            Utils.showAlert(controller: self, message: "Vă rugam să vă conectați la internet pentru a vă putea conecta!")
        }
        
    }
    
    
    @IBAction func fbLoginAction(_ sender: Any) {
        startActivity()
        if Utils.isConnectedToNetwork(){
            PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile","email"]) { (user, error) in
                if error != nil {
                    self.stopActivity()
                    Utils.showAlert(controller: self, message: "Eroare la conectare cu Facebook. Vă rugăm să reîncercați mai târziu!")
                    return
                }
                
                if FBSDKAccessToken.current() != nil && PFUser.current()?.email == nil{
                    let requestParameters = ["fields": "email, first_name, last_name"]
                    let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)!
                    userDetails.start(completionHandler: { (connection, result, error) in
                        if error != nil {
                            self.stopActivity()
                            Utils.showAlert(controller: self, message: "Eroare la conectarea cu Facebook. Vă rugăm să reîncercați mai târziu!")
                            return
                        }
                        
                        let user = PFUser.current()!
                        if result != nil {
                            let dict = result as! Dictionary<String, AnyObject>
                            if let userFirstName =  dict["first_name"]{
                                user["first_name"] = userFirstName as! String
                            }
                            if let userLastName =  dict["last_name"]{
                                user["last_name"] = userLastName as! String
                            }
                            if let userEmail = dict["email"]{
                                user["email"] = userEmail as! String
                            }
                            user.saveInBackground(block: { (success, error) in
                                if success {
                                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "AddBeaconViewController") as! AddBeaconViewController
                                    self.present(vc, animated: true, completion:nil)
                                }else{
                                    self.stopActivity()
                                    Utils.showAlert(controller: self, message: "Eroare la conectarea cu Facebook. Vă rugăm să reîncercați mai târziu!")
                                }
                            })
                        }
                        
                    })
                }else if PFUser.current() != nil{
                    self.goToApp()
                }else{
                    self.stopActivity()
                    Utils.showAlert(controller: self, message: "Trebuie să oferiți permisiunea aplicației pentru a vă putea conecta!")
                    
                }
            }
        }else{
            self.stopActivity()
            Utils.showAlert(controller: self, message: "Vă rugam să vă conectați la internet pentru a vă putea conecta!")
        }
    }
    
    func goToApp(){
        Beacon.queryOffline()?.countObjectsInBackground(block: { (nr, error) in
            if error == nil{
                if nr > 0{
                    DispatchQueue.main.async {
                        LocationManager.mainInstance.startMonitoringBeacons()
                        self.stopActivity()
                        UIView.animate(withDuration: 2, delay: 0.0, options: [.curveEaseOut],animations: {
                            self.carImage.center.x += self.view.bounds.width
                        },completion: { finished in
                            let initialVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = initialVC
                        })
                    }
                }else{
                    Beacon.query()!.findObjectsInBackground { (objects, error) in
                        if error == nil{
                            if objects?.count != 0{
                                PFObject.pinAll(inBackground: objects, block: { (success, error) in
                                    if success{
                                        let group = DispatchGroup()
                                        group.enter()
                                        Trip.query()?.findObjectsInBackground(block: { (objects, error) in
                                            if error == nil{
                                                PFObject.pinAll(inBackground: objects, block: { (success, error) in
                                                    if success{
                                                        group.leave()
                                                    }
                                                })
                                                for trip in objects as! [Trip]{
                                                    group.enter()
                                                    Location.queryOnlineFor(trip: trip)?.findObjectsInBackground(block: { (locations, error) in
                                                        if error == nil{
                                                            PFObject.pinAll(inBackground: locations, block: { (success, error) in
                                                                if success{
                                                                    group.leave()
                                                                }
                                                            })
                                                        }
                                                    })
                                                }
                                            }
                                        })
                                        group.notify(queue: .main, execute: {
                                            LocationManager.mainInstance.startMonitoringBeacons()
                                            self.stopActivity()
                                            UIView.animate(withDuration: 2, delay: 0.0, options: [.curveEaseOut],animations: {
                                                self.carImage.center.x += self.view.bounds.width
                                            },completion: { finished in
                                                let initialVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                                                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = initialVC
                                            })
                                        })
                                    }else{
                                        self.stopActivity()
                                        Utils.showAlert(controller: self, message: "Eroare la conectare. Vă rugăm să reîncercați mai târziu!")
                                    }
                                })
                                
                            }else{
                                self.stopActivity()
                                DispatchQueue.main.async(execute: { () -> Void in
                                    UIView.animate(withDuration: 2, delay: 0.0, options: [.curveEaseOut],animations: {
                                        self.carImage.center.x += self.view.bounds.width
                                    },completion: { finished in
                                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "AddBeaconViewController") as! AddBeaconViewController
                                        self.present(vc, animated: true, completion:nil)
                                    })
                                })
                            }
                        }else{
                            self.stopActivity()
                            Utils.showAlert(controller: self, message: "Eroare la conectare. Vă rugăm să reîncercați mai târziu!")
                        }
                        
                    }
                }
            }else{
                self.stopActivity()
                Utils.showAlert(controller: self, message: "Eroare la conectare. Vă rugăm să reîncercați mai târziu!")
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
            return true
        default:
            textField.resignFirstResponder()
            return true
        }
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        if textField.textColor == UIColor.red{
            textField.text = ""
            textField.textColor = MyColors.mainColor
        }
        if textField == passwordField{
            textField.isSecureTextEntry = true
        }
    }
    
}
