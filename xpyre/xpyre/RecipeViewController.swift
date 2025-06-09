//
//  RecipeViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 5/31/25.
//

import UIKit
import FirebaseAI

let ai = FirebaseAI.firebaseAI(backend: .googleAI())
let model = ai.generativeModel(modelName: "gemini-2.0-flash")

// will change this later

class RecipeViewController: UIViewController {
    
    var prompt: String = ""
    var groceryArray : [GroceryItem] = []
    
    @IBOutlet weak var testButton: UIButton!
    @IBAction func generateRecipes() {
        Task { @MainActor in
            do {
                let response = try await model.generateContent(prompt)
                print(response)
                aiResponse.text = response.text
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    @IBOutlet weak var aiResponse: UILabel!
    @IBOutlet weak var recipeScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        loadGroceryData()
        print(groceryArray)
        prompt = "Here is a list of ingredients I have: \(groceryArray). If data is empty, respond only with 'There is no grocery data for me to create recipes with!.' If there is data, create a list of three recipes, prioritizing the ingredients with the least amount of time before expirations. No need to explain rationale or give an introduction, just give the name of the recipe, the ingredients needed, and the instructions."
        recipeScroll.contentSize = CGSize(width: recipeScroll.frame.size.width, height: 2000)
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
            
        } catch {
            print("Failed to load or decode JSON: \(error)")
        }
    }

}
