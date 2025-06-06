//
//  AddViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 5/31/25.
//

import UIKit
import UserNotifications
import Foundation


struct HistoryItem: Codable {
    let name: String
    let days: Int
}

class NotifHistoryItem: Codable {
    var message : String
    var notifDate : Date
    var checked : Bool = false
    
    init(item: String, date: Date) {
        message = "Your \(item) expires today!"
        notifDate = date
    }
}

class AddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var historyArray : [HistoryItem] = []
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var expireDate: UIDatePicker!
    @IBOutlet weak var addNewGroceryButton: UIButton!
    var expirationDays: Int?
    var defaultDate : Date?

    @IBOutlet weak var historyTable: UITableView!
    
    override func viewDidLoad() {
        itemName.placeholder = "type here"

        super.viewDidLoad()
        // Do any additional setup after loading the view.
        historyTable.delegate = self
        historyTable.dataSource = self
        
        // datepicker testing
//        let calendar = Calendar.current
//        var components = DateComponents()
//        components.year = 2012
//        components.month = 5
//        components.day = 23
//        let defaultDate = calendar.date(from: components)!
//        expireDate.date = defaultDate
        
        expireDate.date = defaultDate ?? Date()

        if let url = getDocumentsURL() {
            print("JSON file path: \(url.path)")
        }
        if let historyURL = getHistoryURL() {
                createEmptyHistoryFileIfNeeded(at: historyURL)
                historyArray = loadHistory(from: historyURL)
                historyTable.reloadData()
            }
    }
    
    @IBAction func daystillExpiration(_ sender: UIDatePicker) {
        let calendar = Calendar.current
        
        let todaysDate = calendar.startOfDay(for: Date())
        let selectedDate = sender.date
        
        let components = calendar.dateComponents([.day], from: todaysDate, to: selectedDate)
        print(components)
        
        expirationDays = components.day
    }
    

    // gets the url of the json file
    func getDocumentsURL() -> URL? {
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

        let newGrocery = GroceryItem(name: itemName.text ?? "", daysItLasts: expirationDays ?? 0)
        dashboardData.DashboardProducts.append(newGrocery)
        print(dashboardData)

        saveDashboardData(dashboardData, to: documentsURL)

        checkForPermission(groceryName: itemName.text ?? "", expireDate: expireDate.date)
        self.tabBarController?.selectedIndex = 0
        
        let historyItem = HistoryItem(name: itemName.text ?? "", days: expirationDays ?? 0)
        if !historyArray.contains(where: { $0.name == historyItem.name }) {
            historyArray.append(historyItem)
            historyTable.reloadData()
            
            if let historyURL = getHistoryURL() {
                    saveHistory(historyArray, to: historyURL)
                }
        }
    }
    
    // history table stuff
    
    //amount of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    //data in each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
            
        cell.textLabel?.text = historyArray[indexPath.row].name + " - " + String(historyArray[indexPath.row].days) + " days"
        
        return cell
    }
    
    //height of row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //cell function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProd = historyArray[indexPath.row].name
        print("Selected \(selectedProd)")
        
        itemName.text = selectedProd
        defaultDate = calendarDate(fromDays: historyArray[indexPath.row].days)!
        viewDidLoad( )
    }
    
    //cell swipe to delete func
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            historyArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if let historyURL = getHistoryURL() {
                saveHistory(historyArray, to: historyURL)
            }
        }
    }
    
    func getHistoryURL() -> URL? {
        let fileManager = FileManager.default
        return try? fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("History.json")
    }
    
    func createEmptyHistoryFileIfNeeded(at url: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            do {
                let emptyData = try JSONEncoder().encode([HistoryItem]())
                try emptyData.write(to: url)
                print("Created empty History.json")
            } catch {
                print("Failed to create History file: \(error)")
            }
        }
    }

    func loadHistory(from url: URL) -> [HistoryItem] {
        do {
            let data = try Data(contentsOf: url)
            let history = try JSONDecoder().decode([HistoryItem].self, from: data)
            return history
        } catch {
            print("Failed to load history: \(error)")
            return []
        }
    }
    
    func saveHistory(_ history: [HistoryItem], to url: URL) {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: url)
            print("Saved history")
        } catch {
            print("Failed to save history: \(error)")
        }
    }

    
    // days to calendardate conversopm
    func calendarDate(fromDays daysFromNow: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()

        let futureDate = calendar.date(byAdding: .day, value: daysFromNow, to: today)

        return futureDate
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
