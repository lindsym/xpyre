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
    let DashboardProducts: [GroceryItem]
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
        loadGroceryData()
    }
    
    func loadGroceryData() {
        guard let fileURL = Bundle.main.url(forResource: "LocalStorage", withExtension: "json") else {
            print("File not found in bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let dashboardData = try decoder.decode(DashboardData.self, from: data)
            self.groceryArray = dashboardData.DashboardProducts
            tableView.reloadData()
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (groceryArray.count > 0) {
            print("Number of items: \(groceryArray.count)")
        }
        tableView.reloadData() // this is needed to update data from upload page
        // TODO: load in cloud data

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
    
//    // prints selected product
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedProd = groceryArray[indexPath.row].name
//        print(selectedProd)
//    }
    
}
