//
//  Utils.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 20/03/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import SystemConfiguration


class Utils: NSObject {
    
    static func showNotification(body: String){
        let content = UNMutableNotificationContent()
        content.body = body
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier:randomString(length: 7), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){(error) in
            if (error != nil){
                print(error?.localizedDescription)
            }
        }

    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func showAlert(controller:UIViewController, message:String){
        let alertController = UIAlertController(title: "Eroare", message:message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Închide", style: UIAlertActionStyle.default,handler: nil))
        alertController.view.tintColor  = MyColors.mainColor
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func showSuccessAlert(controller:UIViewController, message:String){
        let alertController = UIAlertController(title: "Succes", message:message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Închide", style: .default) { (alert: UIAlertAction!) in
            controller.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(action)
        alertController.view.tintColor  = MyColors.mainColor
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    static func getActivityIndicator(view : UIView) -> UIView{
        let container: UIView = UIView()
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColor(hexString:"#000000A5")
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.white
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        actInd.color = MyColors.mainColor
        actInd.center = CGPoint(x:loadingView.frame.size.width / 2,
                                y:loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        view.addSubview(container)
        actInd.startAnimating()
        
        container.isHidden = true
        
        return container
    }

    static func changeStatusBarColor(color: UIColor){
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }
}
