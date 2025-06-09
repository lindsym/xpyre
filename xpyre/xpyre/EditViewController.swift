//
//  EditViewController.swift
//  xpyre
//
//  Created by Lindsy M on 6/6/25.
//

import UIKit

class EditViewController: UIViewController {
    
    var groceryItemName : String = ""
    var groceryArray : [GroceryItem] = []
    var groceryIndex = -1
    
    var originalDate = Date()
    
    @IBOutlet weak var groceryNameUpdateField: UITextField!
    @IBOutlet weak var groceryItemLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var dateInput: UIDatePicker!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func goBack() {
        performSegue(withIdentifier: "seg2", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seg2" {
            let destinationVC = segue.destination as? DashboardViewController
            destinationVC?.groceryArray = groceryArray
        }
    }
    
    @IBAction func deleteItem() {
        groceryArray.remove(at: groceryIndex)
        self.deleteFromJSON(groceryItemName)

        performSegue(withIdentifier: "seg2", sender:self)
    }
    
    @IBAction func updateItem() {
        //delete if we are updating
        groceryArray.remove(at: groceryIndex)
        self.deleteFromJSON(groceryItemName)
        
        
        //instead of updating info, just create new grocery item
        guard let documentsURL = getDocumentsURL(file: "LocalStorage.json") else {
            print("Could not find Documents directory")
            return
        }

        createEmptyJSONFileIfNeeded(at: documentsURL)

        guard var dashboardData = loadDashboardData(from: documentsURL) else {
            print("Could not load JSON data")
            return
        }

        let newGrocery = GroceryItem(name: groceryNameUpdateField.text ?? "", expirationDate: Date())
        dashboardData.DashboardProducts.append(newGrocery)
        print(dashboardData)
        


        saveDashboardData(dashboardData, to: documentsURL)

        checkForPermission(groceryName: groceryNameUpdateField.text ?? "", expireDate: dateInput.date)
        
        performSegue(withIdentifier: "seg2", sender:self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groceryItemLabel.text = groceryItemName
        groceryNameUpdateField.placeholder = "update here"
        groceryNameUpdateField.text = groceryItemName
        dateInput.date = originalDate
    }
    
    func deleteFromJSON(_ name: String) {
        do {
            let fileManager = FileManager.default
            let url = try fileManager.url(for: .documentDirectory,in: .userDomainMask,appropriateFor: nil,create: true).appendingPathComponent("LocalStorage.json")
            let data = try Data(contentsOf: url)
            var dashboardData = try JSONDecoder().decode(DashboardData.self, from: data)

            dashboardData.DashboardProducts.removeAll { $0.name == name }

            let newData = try JSONEncoder().encode(dashboardData)
            try newData.write(to: url)

            print("Successfully deleted '\(name)' from JSON")
        } catch {
            print("Error deleting from JSON: \(error)")
        }
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
                dateComponents.hour = todayHour + 1
                dateComponents.minute = 0
            }
        } else {
            dateComponents.hour = 5
            dateComponents.minute = 0
            dateComponents.second = 0
        }
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //delete old notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [groceryItemName])
        
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
