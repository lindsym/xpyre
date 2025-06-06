//
//  NotifViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 5/31/25.
//

import UIKit

class Notif {
    var notifMessage : String
    var notifDate: String
    
    init(msg: String, timestamp: String) {
        notifMessage = msg
        notifDate = timestamp
    }
}

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    
}

class NotifViewController: UITableViewController {
    var data : [Notif] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        getNotifHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNotifHistory()
    }
    
    func getNotifHistory() {
        data.removeAll() 
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
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
            for i in 0 ..< history.count {
                if (!history[i].checked) {
//                    print("not checked")
                    if (history[i].notifDate <= Date()) {
//                        print("data was checked")
                        history[i].checked = true
                    }
                }
                
                if (history[i].checked == true) {
                    let dateString = dateFormatter.string(from: history[i].notifDate)
                    data.append(Notif(msg: history[i].message, timestamp: dateString))
                }
            }
            saveNotifHistory(items: history, to: notifPath)
            tableView.reloadData()

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
            print("saved notif from all notif controller")
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("here!!!")
//        print("here is data size to see if added: ", data.count)
        let notif = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.message.text = notif.notifMessage
        cell.date.text = notif.notifDate
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
