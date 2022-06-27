//
//  NotificationViewController.swift
//  Tireless
//
//  Created by Hao on 2022/5/11.
//

import UIKit
import UserNotifications

class NotificationViewController: UIViewController {
    
    @IBOutlet private weak var notifyView: UIView!
    
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    @IBOutlet private weak var checkButton: UIButton!
    
    private let maskView = UIView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMaskView()
        
        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            var nextTriggerDates: [Date] = []
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                    let triggerDate = trigger.nextTriggerDate() {
                    nextTriggerDates.append(triggerDate)
                }
            }
            if let nextTriggerDate = nextTriggerDates.min() {
                DispatchQueue.main.async {
                    self.datePicker.date = nextTriggerDate
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self.view {
            maskView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setMaskView() {
        maskView.backgroundColor = .black
        maskView.alpha = 0
        presentingViewController?.view.addSubview(maskView)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.maskView.alpha = 0.5
        }
    }
    
    private func setupLayout() {
        self.notifyView.layer.cornerRadius = 15
        self.checkButton.layer.cornerRadius = 15
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    @IBAction func checkButtonTap(_ sender: UIButton) {
        let content = UNMutableNotificationContent()
        content.title = "Tireless"
        content.body = "該是時候維持運動好習慣了!"
        content.sound = UNNotificationSound.default
        let date = datePicker.date
        
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let minutes = calender.component(.minute, from: date)
        
        var dateComonents = DateComponents()
        dateComonents.hour = hour
        dateComonents.minute = minutes
        dateComonents.timeZone = TimeZone.current
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComonents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "Tireless Alert", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("adding notification error: \(error)")
                ProgressHUD.showFailure(text: "失敗")
            } else {
                ProgressHUD.showSuccess(text: "成功設定提醒")
                DispatchQueue.main.async {
                    self.maskView.removeFromSuperview()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
