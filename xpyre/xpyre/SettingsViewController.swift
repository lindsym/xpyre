//
//  SettingsViewController.swift
//  xpyre
//
//  Created by Brandon Kim on 6/8/25.
//
import Foundation
import UIKit

struct NotifSettings {
    static var daysBeforeNotif: Int {
        get {
            return UserDefaults.standard.integer(forKey: "daysBeforeNotif")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "daysBeforeNotif")
        }
    }
    static var notificationTime: Date {
        get {
            return UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notificationTime")
        }
    }
    static var defaultTime: Date {
        var components = DateComponents()
        components.hour = 0
        components.minute = 0
        return Calendar.current.date(from: components)!
    }
}

class NotifSettingsViewController: UIViewController {
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var daysStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysStepper.value = Double((NotifSettings.daysBeforeNotif))
        timePicker.date = NotifSettings.notificationTime
        daysLabel.text = "\(Int(daysStepper.value))"
        
        timePicker.datePickerMode = .time
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        daysLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        NotifSettings.daysBeforeNotif = Int(daysStepper.value)
        NotifSettings.notificationTime = timePicker.date
        
        let alert = UIAlertController(title: "Saved", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
