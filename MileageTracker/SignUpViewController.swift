//
//  SignUpViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 02/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: FormViewController{
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
   
    var valid = true

    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        username.delegate = self
        email.delegate = self
        password.delegate = self
        Utils.changeStatusBarColor(color : MyColors.mainColor)
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true,completion: nil)
    }
   
    @IBAction func signUp(_ sender: Any) {
        if Utils.isConnectedToNetwork(){
            if firstName.text!.isEmpty{
                firstName.textColor = UIColor.red
                firstName.text! = "Introduceți numele dumneavoastră"
            }
            if lastName.text!.isEmpty{
                lastName.textColor = UIColor.red
                lastName.text! = "Introduceți prenumele dumneavoastră"
            }
            if username.text!.isEmpty{
                username.textColor = UIColor.red
                username.text! = "Introduceți un nume de utilizator"
            }
            if !email.text!.contains("@") || !email.text!.contains(".") {
                email.textColor = UIColor.red
                email.text! = "Introduceți un email valid"
            }
            if (password.text?.characters.count)! < 6{
                password.isSecureTextEntry = false
                password.textColor = UIColor.red
                password.text! = "Parola nu conține cel puțin 6 caractere"
            }
            if firstName.textColor != UIColor.red &&
                email.textColor != UIColor.red &&
                username.textColor != UIColor.red &&
                password.textColor != UIColor.red &&
                lastName.textColor != UIColor.red {
                
                startActivity()
                
                let newUser = PFUser()
                newUser.email = email.text!.trimmingCharacters(in: .whitespaces)
                newUser.username = username.text!
                newUser.password = password.text!
                
                newUser.signUpInBackground(block: { (success, error ) in
                    
                    if ((error) != nil) {
                        self.stopActivity()
                        switch (error! as NSError).code{
                        case 202:
                            Utils.showAlert(controller: self, message: "Acest nume de utilizator este deja utilizat!")
                                break
                        case 203:
                            Utils.showAlert(controller: self, message: "Acestă adresa de email este deja utilizată!")
                                break
                        default:
                            Utils.showAlert(controller: self, message: "Contul dumneavoastră nu a putut fi creat. Vă rugăm să reîncercați mai târziu!")
                        }
                    } else {
                        if let user = PFUser.current(){
                            user["first_name"] = self.firstName.text!
                            user["last_name"] = self.lastName.text!
                            user.saveInBackground(block: { (success, error) in
                                if success{
                                    self.stopActivity()
                                    DispatchQueue.main.async {
                                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "AddBeaconViewController") as! AddBeaconViewController
                                        self.present(vc, animated: true, completion:nil)
                                    }
                                }else{
                                    PFUser.current()?.deleteInBackground(block: { (sucees, error) in
                                        self.stopActivity()
                                        Utils.showAlert(controller: self, message: "Contul dumneavoastră nu a putut fi creat. Vă rugăm să reîncercați mai târziu!")
                                    })
                                }
                            })
                        }
                    }
                    
                })
            }
        }else{
             Utils.showAlert(controller: self, message: "Vă rugam să vă conectați la internet pentru a putea creea un cont nou!")
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstName:
            lastName.becomeFirstResponder()
            return true
        case lastName:
            username.becomeFirstResponder()
            return true
        case username:
            email.becomeFirstResponder()
            return true
        case email:
            password.becomeFirstResponder()
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
        if textField == password{
            textField.isSecureTextEntry = true
        }
    }
}
