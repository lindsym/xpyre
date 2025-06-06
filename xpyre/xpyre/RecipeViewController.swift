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
let prompt = "What recipes can i make with three apples? Format your response so iOS UILabel can read the headings and display them"

class RecipeViewController: UIViewController {
    
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
        recipeScroll.contentSize = CGSize(width: recipeScroll.frame.size.width, height: 2000)
    }

}
