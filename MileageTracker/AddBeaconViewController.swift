//
//  AddBeaconViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 06/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import Parse

class AddBeaconViewController: FormViewController {
    
    @IBOutlet weak var vehicle: UITextField!
    @IBOutlet weak var uuid: UITextField!
    @IBOutlet weak var major: UITextField!
    @IBOutlet weak var minor: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vehicle.delegate = self
        uuid.delegate = self
        major.delegate = self
        minor.delegate = self
        Utils.changeStatusBarColor(color : MyColors.mainColor)
    }
    
    @IBAction func backAction(_ sender: Any){
        PFUser.logOut()
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController")
    }
    
    @IBAction func addBeacon(_ sender: Any) {
        if uuid.text!.isEmpty{
            uuid.textColor = UIColor.red
            uuid.text! = "Câmpul UUID este obligatoriu"
        }
        if major.text!.isEmpty{
            major.textColor = UIColor.red
            major.text! = "Câmpul Major este obligatoriu"
        }
        if minor.text!.isEmpty{
            minor.textColor = UIColor.red
            minor.text! = "Câmpul Minor este obligatoriu"
        }
        if vehicle.text!.isEmpty{
            vehicle.textColor = UIColor.red
            vehicle.text! = "Introduceți un nume pentru autovehicul"
        }
        if  uuid.textColor != UIColor.red &&
            major.textColor != UIColor.red &&
            minor.textColor != UIColor.red &&
            vehicle.textColor != UIColor.red{
            if uuid.text!.characters.count != 36{
                Utils.showAlert(controller: self, message: "UUID trebuie să conțină 32 de caractere alfanumerice împărțite în grupuri de 8,4,4,4,12 caractere separate prin cratimă")
            }else{
                startActivity()
                let beacon = Beacon(uuid: uuid.text!, major: Int(major.text!)!, minor: Int(minor.text!)!, vehicle: vehicle.text!, user: PFUser.current()!)
                beacon.saveEventually()
                beacon.pinInBackground(block: { (success, error) in
                    self.stopActivity()
                    if success {
                        
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
                    }else{
                        Utils.showAlert(controller: self, message: "Adăugarea nu s-a putut efectua cu success, vă rugăm să reîncercați mai târziu!")
                    }
                })
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == uuid{
            if (range.location == 36) {
                return false;
            }
            
            if (range.length == 0 &&
                (range.location == 7 || range.location == 12 || range.location == 17 || range.location == 22)) {
                textField.text = String(format: "%@-", textField.text!+string)
                return false
            }
            
        }
        if textField == major || textField == minor{
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case uuid:
            major.becomeFirstResponder()
            return true
        case major:
            minor.becomeFirstResponder()
            return true
        case minor:
            vehicle.becomeFirstResponder()
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
    }
}
