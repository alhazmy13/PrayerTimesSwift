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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let myPrayerTime = PrayerTimes(Caculationmethod: PrayerTimes.CalculationMethods.Makkah, asrJuristic: PrayerTimes.AsrJuristicMethods.Hanafi, adjustHighLats: PrayerTimes.AdjustingMethods.None, timeFormat: PrayerTimes.TimeForamts.Time24)
        let prayerTimes = myPrayerTime.getPrayerTimes(NSCalendar.currentCalendar(), latitude: 24.7993689, longitude: 46.6176563, tZone: 3)
        for time in prayerTimes{
            print(time)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

