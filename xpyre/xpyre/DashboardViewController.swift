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
}
