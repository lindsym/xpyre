//
//  DashboardViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 5/31/25.
//

import UIKit

struct GroceryItem: Codable {
    let name: String
    let daysItLasts: Int
}

struct DashboardData: Codable {
    var DashboardProducts: [GroceryItem]
}

class tableCell: UITableViewCell {
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellDate: UILabel!
}

class DashboardViewController: UITableViewController {

    var groceryArray : [GroceryItem] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // UNCOMMENT THIS WHEN GROCERY LIST GET TOO LONG
        // COMMENT IT BACK FOR TESTING
        // clearDashboardData()

    }
    
    // THIS FUNCTION PURELY FOR TESTING
    // IT RESETS THE JSON EVERYTIME THE APP IS LOADED
    func clearDashboardData() {
        guard let fileURL = documentsFileURL() else {
            print("Could not find Documents directory")
            return
        }

        let emptyData = DashboardData(DashboardProducts: [])
        do {
            let encoded = try JSONEncoder().encode(emptyData)
            try encoded.write(to: fileURL)
            print("Cleared dashboard data file")
        } catch {
            print("Failed to clear dashboard data: \(error)")
        }
    }
    
    func documentsFileURL() -> URL? {
        let fileManager = FileManager.default
        return try? fileManager.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: true)
            .appendingPathComponent("LocalStorage.json")
    }
    
    func loadGroceryData() {
        guard let fileURL = documentsFileURL() else {
            print("Could not find Documents directory")
            return
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            if let bundleURL = Bundle.main.url(forResource: "LocalStorage", withExtension: "json") {
                do {
                    try fileManager.copyItem(at: bundleURL, to: fileURL)
                    print("Copied JSON file to Documents")
                } catch {
                    print("Failed to copy JSON to Documents: \(error)")
                }
            }
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let dashboardData = try JSONDecoder().decode(DashboardData.self, from: data)
            self.groceryArray = dashboardData.DashboardProducts
            tableView.reloadData()
        } catch {
            print("Failed to load or decode JSON: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (groceryArray.count > 0) {
            print("Number of items: \(groceryArray.count)")
        }
        
        groceryArray.sort { $0.daysItLasts < $1.daysItLasts }

        loadGroceryData()
//        tableView.reloadData()

    }
    
    // sets up table size rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryArray.count
    }
    
    // sets up data in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? tableCell else {
            fatalError("Could not dequeue cell with identifier 'cell'")
        }
        
        cell.cellName.text = groceryArray[indexPath.row].name
        cell.cellDate.text = "Expires in " + String(groceryArray[indexPath.row].daysItLasts) + " days"
        return cell
    }
    
    // height of row at every index
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // prints selected product
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProd = groceryArray[indexPath.row].name
        print("Selected: \(selectedProd)")

        let alert = UIAlertController(title: "Delete this item?", message: "\(selectedProd)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            // delete from local store
            self.groceryArray.remove(at: indexPath.row)
            
            // TODO: delete item from JSON
            self.deleteFromJSON(selectedProd)
            
            // delete from table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            print(self.groceryArray)

        } )
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        print(groceryArray)
    }
    
//    func deleteFromJSON(_ name: String) {
//        do {
//            let fileManager = FileManager.default
//            let fm = try fileManager.url(for: .documentDirectory,in: .userDomainMask,appropriateFor: nil,create: true).appendingPathComponent("LocalStorage.json")
//            let data = try Data(contentsOf: fm)
//            var contents = try JSONDecoder().decode([GroceryItem].self, from: data)
//            
//            contents.removeAll { $0.name == name }
//            
//            if let newData = try? JSONEncoder().encode(contents) {
//                try? newData.write(to: fm)
//                print("Successfully deleted from JSON")
//            }
//        } catch {
//            print("Error deleting from JSON")
//            return
//        }
//    }
    
    func deleteFromJSON(_ name: String) {
//        guard let documentsURL = getDocumentsURL() else {
//            print("Could not find Documents directory")
//            return
//        }


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


    
}
