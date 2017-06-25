//
//  ForgotPassswordController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 04/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import Parse

class ForgotPasswordController : UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var topIconConstraint: NSLayoutConstraint!
    @IBOutlet weak var topIcon: RoundImageView!
    @IBOutlet weak var email: UITextField!
    
    
    @IBAction func resetPassword(_ sender: Any) {
        if !email.text!.contains("@") || !email.text!.contains(".") {
            email.textColor = UIColor.red
            email.text = "Email invalid"
        }
        if email.textColor != UIColor.red{
            if Utils.isConnectedToNetwork(){
                let finalEmail = email.text!.trimmingCharacters(in: .whitespaces)
                PFUser.requestPasswordResetForEmail(inBackground: finalEmail)
                let alert = UIAlertController (title: "Resetare parola", message: "Un email ce conține informații despre resetarea parolei a fost trimis la adresa " + finalEmail , preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
                    action in
                    self.dismiss()
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                Utils.showAlert(controller: self,message: "Vă rugăm să vă conectați la internet pentru a vă putea reseta parola!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topIconConstraint.constant = (5/4.5-1)*topIcon.frame.size.width/2
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.textColor == UIColor.red{
            textField.text = ""
            textField.textColor = MyColors.mainColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
