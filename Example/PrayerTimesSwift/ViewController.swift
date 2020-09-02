//
//  ViewController.swift
//  PrayerTimesSwift
//
//  Created by Abdullah Alhazmy on 01/31/2016.
//  Copyright (c) 2016 Abdullah Alhazmy. All rights reserved.
//

import UIKit
import PrayerTimesSwift

class ViewController: UIViewController {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myPrayerTime = PrayerTimes(
            caculationMethod: .makkah,
            asrJuristic: .shafii,
            adjustHighLats: .none,
            timeFormat: .time12
        )
        let prayerTimes = myPrayerTime.getPrayerTimes(date: .current, latitude: 24.7136, longitude: 46.6753, tZone: 3)
        label.text = prayerTimes.joined(separator: "\n")
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(label)
        // auto layout
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
        ])
    }
    
}

