//
//  ViewController.swift
//  PPS-Data
//
//  Created by Joshua Ren on 2019-06-24.
//  Copyright © 2019 Joshua Ren. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForPushNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // check if we want to automatically open any surveys upon opening the app
        checkAutoOpenSurvey()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Action: openEmail
     * Description: Opens the user's default email client, and an email within
     * the client addressed to the email address below.
     */
    @IBAction func openEmail(_ sender: Any) {
        let email = "renj@stanford.edu" // Email to be contacted
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    /*
     * Function: openSurvey
     * Description: uses a SFSafariViewController to open a Qualtrics-based ESM.
     */
    @IBAction func openSurvey(_ sender: Any) {
        let urlString = NSURL(string: "https://stanforduniversity.qualtrics.com/jfe/form/SV_0P1d0g3k8oB6UV7")
        let svc = SFSafariViewController(url: urlString! as URL)
        self.present(svc, animated: true, completion: nil)
    }
    
    
    // will automatically open the survey if notification title contains "survey" or "Survey"
    // and user clicks notification within the given time range
    func checkAutoOpenSurvey() {
        // a +/- value from the time sent of a notifcation
        // range you want auto openSurvey for
        let timeRange = 3
        
        // here we check if the times are equal to survey or diary time
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        // get fullArr of all notifications
        var fullArr = getNotificationTimes()
        for (key, _) in fullArr { // filter any notifications that aren't surveys
            if (!key.contains("survey") && !key.contains("Survey")) {
                fullArr[key] = nil
            }
        }
        for (_, surveyTimes) in fullArr { // for each survey title
            for surveyTime in surveyTimes { // for each survey time
                if (surveyTime[hour] != nil) { // if the current time matches a survey hour
                    switch true { // if you are within the window for auto opening then open
                    case (surveyTime[hour] == minutes):
                        openSurvey((Any).self)
                    case (minutes...(minutes + timeRange) ~= surveyTime[hour]!):
                        openSurvey((Any).self)
                    case ((minutes - timeRange)...minutes ~= surveyTime[hour]!):
                        openSurvey((Any).self)
                    case ((minutes - surveyTime[hour]! + 60) < timeRange):
                        openSurvey((Any).self)
                    case ((surveyTime[hour]! - minutes + 60) < timeRange):
                        openSurvey((Any).self)
                    default:
                        print("Too Late for Survey :(")
                    }
                }
            }
        }
    }
    
  
}
