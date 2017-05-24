//
//  ReportComposer.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 04/04/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit

class ReportComposer: NSObject {

    let pathToReportHTMLTemplate = Bundle.main.path(forResource: "raport", ofType: "html")
    
    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_item", ofType: "html")
    
    var month: String!
    
    var pdfFilename: String!
    
    
    override init() {
        super.init()
    }
    
    
    func renderReport(car: String, driver: String, date: String, items: [Trip]) -> String! {
        self.month = date
        
        do {
            var HTMLContent = try String(contentsOfFile: pathToReportHTMLTemplate!)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SOFER#", with: driver)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LUNA_RAPORT#", with: date)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#AUTOVEHICUL#", with: car)
            
            var allItems = ""
            var total = 0.0
            for item in items {
                var itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ADRESA_PLECARE#", with: (item.startPlace != nil) ? item.startPlace! : "")
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#DATA_PLECARE#", with: item.startTime.toDateString())
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ORA_PLECARE#", with: item.startTime.toHourString())
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ADRESA_SOSIRE#", with: (item.endPlace != nil) ? item.endPlace! : "")
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#DATA_SOSIRE#", with: item.endTime.toDateString())
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ORA_SOSIRE#", with: item.endTime.toHourString())
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#DISTANTA#", with: "\((item.distance/1000).roundTo(places: 2))")

                
                // Add the item's HTML code to the general items string.
                allItems += itemHTMLContent
                total += item.distance
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL#", with: "\((total/1000).roundTo(places: 2))")

            // Set the items.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
            
            // The HTML code is ready.
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return nil
    }
    
    
    func exportHTMLContentToPDF(HTMLContent: String) {
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        pdfFilename = "\(AppDelegate.getAppDelegate().getDocDir())/Raport\(month).pdf"
        pdfData?.write(toFile: pdfFilename, atomically: true)
        
        print(pdfFilename)
    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 1...printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i-1, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        return data
    }
    
}
