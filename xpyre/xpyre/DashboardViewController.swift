//
//  DashboardViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 5/31/25.
//

import UIKit

class GroceryItem {
    var name: String
    var daysItLasts: Int
    
    init(name: String, daysItLasts: Int) {
        self.name = name
        self.daysItLasts = daysItLasts
    }
}

class DashboardViewController: UITableViewController {
    
    var groceryArray : [GroceryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (groceryArray.count > 0) {
            print(groceryArray[0].name)
        }
    }
    
    // sets up table size rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryArray.count
    }
    
    // sets up data in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        cell.textLabel?.text = groceryArray[indexPath.row].name
        return cell
    }
    
    
    // height of row at every index
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedProd = groceryArray[indexPath.row]
//        print(selectedProd)
//    }
    
}
