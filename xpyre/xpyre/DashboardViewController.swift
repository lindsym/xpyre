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

class filterCell: UITableViewCell {
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var applyButton: UIButton!
    
    var applySort: ((Int) -> Void)?
    
    @IBAction func onApplyTapped(_ sender: Any) {
        applySort?(filterSegment.selectedSegmentIndex)
    }
    
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
        loadGroceryData()
        tableView.reloadData()
    }
    
    // sets up table size rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryArray.count + 1
    }
    
    // sets up data in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filter", for: indexPath) as? filterCell else {
                fatalError("Could not dequeue cell with identifier 'filter'")
            }
            // TODO: delete print statements

            cell.applySort = { [weak self] selectedIndex in
                 self?.sort(selectedIndex)
             }
            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? tableCell else {
                fatalError("Could not dequeue cell with identifier 'cell'")
            }
            let item = groceryArray[indexPath.row - 1]
            cell.cellName.text = item.name
            cell.cellDate.text = "Expires in " + String(item.daysItLasts) + " days"
            return cell
        }
    }
    
    func sort(_ index : Int) {
        var filteredArray = groceryArray
       
        // alphabetic sort
        if index == 0 {
            filteredArray.sort { $0.name < $1.name }

        // date sort
        } else {
            filteredArray.sort { $0.daysItLasts < $1.daysItLasts }
        }
        groceryArray = filteredArray
        tableView.reloadData()

    }
    
    // height of row at every index
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    // prints selected product
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProd = groceryArray[indexPath.row - 1].name
        print("Selected: \(selectedProd)")

        let alert = UIAlertController(title: "Delete this item?", message: "\(selectedProd)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            // delete from local store
            self.groceryArray.remove(at: indexPath.row - 1)
            
            self.deleteFromJSON(selectedProd)
            
            // delete from table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            print(self.groceryArray)

        } )
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        print(groceryArray)
    }
    
    // does as the title states
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
}
