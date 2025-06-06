//
//  AddViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 5/31/25.
//

import UIKit
import UserNotifications
import Foundation

class NotifHistoryItem: Codable {
    var message : String
    var notifDate : Date
    var checked : Bool = false
    
    init(item: String, date: Date) {
        message = "Your \(item) expires today!"
        notifDate = date
    }
}

class AddViewController: UIViewController {
    
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var expireDate: UIDatePicker!
    @IBOutlet weak var addNewGroceryButton: UIButton!

    @IBAction func daystillExpiration(_ sender: UIDatePicker) {
        
    }
    
    func getDocumentsURL(file: String) -> URL? {
        let fileManager = FileManager.default
        return try? fileManager.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true).appendingPathComponent(file)
    }

    func createEmptyJSONFileIfNeeded(at url: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            // Create initial empty data structure
            let initialData = DashboardData(DashboardProducts: [])
            do {
                let data = try JSONEncoder().encode(initialData)
                try data.write(to: url)
                print("Created new empty file !!!")
            } catch {
                print("Failed to create initial JSON file: \(error)")
            }
        }
    }
    
    func loadDashboardData(from url: URL) -> DashboardData? {
        do {
            let data = try Data(contentsOf: url)
            let dashboardData = try JSONDecoder().decode(DashboardData.self, from: data)
            return dashboardData
        } catch {
            print("Failed to load JSON data: \(error)")
            return nil
        }
    }

    func saveDashboardData(_ data: DashboardData, to url: URL) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            try encodedData.write(to: url)
            print("Saved updated JSON data")
        } catch {
            print("Failed to save JSON data: \(error)")
        }
    }

    
    @IBAction func toDash(_ sender: UIButton) {
            
        guard let documentsURL = getDocumentsURL(file: "LocalStorage.json") else {
            print("Could not find Documents directory")
            return
        }

        createEmptyJSONFileIfNeeded(at: documentsURL)

        guard var dashboardData = loadDashboardData(from: documentsURL) else {
            print("Could not load JSON data")
            return
        }

        let newGrocery = GroceryItem(name: itemName.text ?? "", daysItLasts: 3)
        dashboardData.DashboardProducts.append(newGrocery)
        print(dashboardData)

        saveDashboardData(dashboardData, to: documentsURL)

        // Continue with your existing logic
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
            if (todayMinute != 59) {
                dateComponents.minute = todayMinute + 1
            } else {
                dateComponents.minute = 0
            }
        } else {
            dateComponents.hour = 5
            dateComponents.minute = 0
            dateComponents.second = 0
        }
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        notificationCenter.add(request)
        
        
        
        //JSON notification logic below
        do {
            let fileManager = FileManager.default
            let documentsURL = try fileManager.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: true)
            let notifPath = documentsURL.appendingPathComponent("NotificationHistory.json")
            
            if !fileManager.fileExists(atPath: notifPath.path) {
                saveNotifHistory(items: [], to: notifPath)
            }
            
            var history = loadNotifHistory(from: notifPath)
            history.append(NotifHistoryItem(item: groceryName, date: expireDate))
            saveNotifHistory(items: history, to: notifPath)

        } catch {
            print("not working: \(error)")
        }
    }
    
    func saveNotifHistory(items: [NotifHistoryItem], to url: URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(items)
            try data.write(to: url)
            print("saved notif!")
        } catch {
            print("could not save \(error)")
        }
    }
    
    func loadNotifHistory(from url: URL) -> [NotifHistoryItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: url)
            let items = try decoder.decode([NotifHistoryItem].self, from: data)
            return items
        } catch {
            print("could not load \(error)")
            return []
        }
    }


}
