//
//  ReportPreviewViewController.swift
//  MileageTracker
//
//  Created by Vlad Alexandru on 12/05/2017.
//  Copyright © 2017 Vlad Alexandru. All rights reserved.
//

import UIKit
import MessageUI
import Parse

class ReportPreviewViewController: UIViewController,MFMailComposeViewControllerDelegate {
    @IBOutlet weak var webPreview: UIWebView!
    
    var trips : [Trip]!
    
    var reportComposer: ReportComposer!
    
    var HTMLContent: String!
    
    var driver = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = PFUser.current(){
            let info = user.dictionaryWithValues(forKeys: ["first_name","last_name"])
            driver = "\(info["first_name"] as! String) \(info["last_name"] as! String)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createReportAsHTML()
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        reportComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent)

        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            
            mailComposeViewController.setSubject("Raport \((trips.first?.startTime.toMonthYearString())!)")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: reportComposer.pdfFilename)! as Data, mimeType: "application/pdf", fileName: (trips.first?.startTime.toMonthYearString())!)
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)

    }
    
    func createReportAsHTML() {
        reportComposer = ReportComposer()
        if let reportHTML = reportComposer.renderReport(car: (trips.first?.beacon.vehicle)!, driver: driver, date: (trips.first?.startTime.toMonthYearString())!.uppercased(), items: trips){
            
            webPreview.loadHTMLString(reportHTML, baseURL: NSURL(string: reportComposer.pathToReportHTMLTemplate!)! as URL)
            HTMLContent = reportHTML
        }
    }
}
