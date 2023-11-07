import UIKit
import SafariServices
import com_awareframework_ios_sensor_locations
import CoreData
import AWAREFramework
import Foundation
import UserNotifications
import CoreLocation

class ConversationTracker {
    private var conversationCount = 0
    private var lastResetDate: Date?
    
    func TrackingConversation() {
        let core = AWARECore.shared()
        core.requestPermissionForBackgroundSensing { (status) in
            core.startBaseLocationSensor()
            let conversation = Conversation(awareStudy: AWAREStudy.shared())
            conversation.startSensor()
            conversation.setSensorEventHandler { [weak self] (sensor, data) in
                guard let self = self else { return }
                
                // Check if a conversation is detected with two people
                if let isConversation = data?["is_conversation"] as? Bool,
                   isConversation,
                   let numberOfPeople = data?["number_of_people"] as? Int,
                   numberOfPeople == 2 {
                    
                    // Check if the conversation count needs to be reset
                    if let lastResetDate = self.lastResetDate,
                       !Calendar.current.isDateInToday(lastResetDate) {
                        self.conversationCount = 0
                        self.lastResetDate = Date()
                    }
                    
                    // Trigger the openSurvey function if the limit has not been reached
                    if self.conversationCount < 3 {
                        self.openSurvey()
                        self.conversationCount += 1
                    }
                }
            }
            conversation.setDebug(true)
            let manager = AWARESensorManager.shared()
            manager.add(conversation)
            manager.startAllSensors()
        }
    }
    
    weak var viewController: UIViewController?

    func openSurvey() {
        guard let url = URL(string: "https://wustl.az1.qualtrics.com/jfe/form/SV_0HyB20WVoAztGTk") else {
            print("Invalid URL")
            return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        DispatchQueue.main.async {
            self.viewController?.present(safariViewController, animated: true)
        }
    }
}
