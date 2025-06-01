//
//  AddViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 5/31/25.
//

import UIKit
import UserNotifications

class AddViewController: UIViewController {
    
    var groceryArray : [GroceryItem] = []
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var expireDate: UIDatePicker!
    @IBOutlet weak var addNewGroceryButton: UIButton!
    
    
    @IBAction func toDash(_ sender: UIButton) {
        var newGrocery = GroceryItem(name: itemName.text ?? "", daysItLasts: 3)
        groceryArray.append(newGrocery)
        
        let firstVC = tabBarController?.viewControllers?[0] as? DashboardViewController
        firstVC?.groceryArray = groceryArray
        
        checkForPermission(groceryName: itemName.text ?? "", expireDate: expireDate.date)

        
        self.tabBarController?.selectedIndex = 0
    }
    

    
    override func viewDidLoad() {
        itemName.placeholder = "type here"

        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func checkForPermission(groceryName : String, expireDate: Date) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    self.dispatchNotification(groceryName: groceryName, expireDate: expireDate)
                case .denied:
                    return
                case .notDetermined:
                    notificationCenter.requestAuthorization(options: [.alert, .sound]) {didAllow, error in
                        if didAllow {
                            self.dispatchNotification(groceryName: groceryName, expireDate: expireDate)
                        }
                    }
                default:
                    return
                
                }
            }
        }
    
    func dispatchNotification(groceryName : String, expireDate: Date) {
        let identifier = groceryName
        let title = "You have a grocery about to expire!"
        let body = "Your \(groceryName) expires today"

        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: expireDate)
        
        let date = Date()
        var todayHour = calendar.component(.hour, from: date)
        var todayMinute = calendar.component(.minute, from: date)
        
        if (calendar.isDateInToday(expireDate)) {
            dateComponents.hour = todayHour
            dateComponents.minute = todayMinute + 1
        }

        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
}
