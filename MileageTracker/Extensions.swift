//
//  StringExtensions.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 04/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import Foundation
import UIKit

extension String {
    static func getAttrString(htmlString: String) -> NSAttributedString {
        var attributedString: NSAttributedString
        do {
            let encodedData = htmlString.data(using: String.Encoding.utf8)!
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
            ]
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            fatalError("Unhandled error: \(error)")
        }
        return attributedString
    }
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width:self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1), to: self.startOfMonth())!
    }
    
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: self)
    }
    
    func toMonthYearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }

    
    func toHourString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func toString()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

extension TimeInterval{
    func toHoursMinutesString()->String{
        let ti = NSInteger(self)
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        if hours == 0{
             return NSString(format: "%dmin",minutes) as String
        }else{
            return NSString(format: "%dh %dmin",hours,minutes) as String
        }
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Dictionary
{
    public init(keys: [Key], values: [Value])
    {
        precondition(keys.count == values.count)
        
        self.init()
        
        for (index, key) in keys.enumerated()
        {
            self[key] = values[index]
        }
    }
}
