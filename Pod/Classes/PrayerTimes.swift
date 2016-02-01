//
//  main.swift
//  PrayerTimes
//
//  Created by Abdullah Alhazmy on 1/26/16.
//  Copyright © 2016 Abdullah Alhazmy. All rights reserved.
//

import Foundation

public class PrayerTimes{
    
    // ---------------------- Global Variables --------------------
    public var caculationMethod = CalculationMethods(rawValue: 4)! // caculation method
    public var asrJuristic = AsrJuristicMethods(rawValue: 0)! // Juristic method for Asr
    var dhuhrMinutes: Int = 0 // minutes after mid-day for Dhuhr
    public var adjustHighLats = AdjustingMethods(rawValue: 0)! // adjusting method for higher latitudes
    public var timeFormat = TimeForamts(rawValue: 0)! // time format
    var prayerTimesCurrent: [Double] = []
    var offsets: [Double] = [0,0,0,0,0,0,0]
    var lat: Double = 0.0 // latitude
    var lng: Double = 0.0 // longitude
    var timeZone: Double = 0.0 // time-zone
    var JDate: Double = 0.0 // Julian date
    // ------------------------------------------------------------
    // Calculation Methods
    public enum CalculationMethods: Int {
        case jafari = 0 // Ithna Ashari
        case karachi = 1 // University of Islamic Sciences, Karachi
        case isna = 2 // Islamic Society of North America (ISNA)
        case mwl = 3 // Muslim World League (MWL)
        case makkah = 4 // Umm al-Qura, Makkah
        case egypt = 5 // Egyptian General Authority of Survey
        case custom = 6 // Custom Setting
        case tehran = 7 // Institute of Geophysics, University of Tehran
    }
    // ------------------------------------------------------------
    // Juristic Methods
    public enum AsrJuristicMethods: Int {
        case shafii = 0 // Shafii (standard)
        case hanafi = 1 // Hanafi
    }
    
    // ------------------------------------------------------------
    // Adjusting Methods for Higher Latitudes
    public enum AdjustingMethods: Int {
        case none = 0 // No adjustment
        case midNight = 1 // middle of night
        case oneSeventh = 2 // 1/7th of night
        case angleBased = 3 // floating point number
    }
    
    // ------------------------------------------------------------
    // Time Formats
    public enum TimeForamts: Int {
        case time24 = 0 // 24-hour format
        case time12 = 1 // 12-hour format
        case time12NS = 2 // 12-hour format with no suffix
        case floating = 3 // angle/60th of night
    }
    
    // ------------------------------------------------------------
    // Time Names
    let timeNames: [String] = ["Fajr","Sunrise","Dhuhr","Asr","Sunset","Maghrib","Isha"]
    let InvalidTime: String = "-----" // The string used for invalid times
    // ------------------------------------------------------------
    // Time Names
    let numIterations: Int = 1// number of iterations needed to compute times
    var methodParams: [CalculationMethods: [Double]] = [
        CalculationMethods.jafari: [16,0,4,0,14],
        CalculationMethods.karachi: [18,1,0,0,18],
        CalculationMethods.isna: [15,1,0,0,15],
        CalculationMethods.mwl: [18,1,0,0,17],
        CalculationMethods.makkah: [18.5,1,0,1,90],
        CalculationMethods.egypt: [18,1,0,0,17],
        CalculationMethods.custom: [19.5,1,0,0,17.5],
        CalculationMethods.tehran: [17.7,0,4.5,0,14]
        
    ]
    
    // ------------------------------------------------------------
    // Init
    public init(caculationmethod: CalculationMethods, asrJuristic: AsrJuristicMethods, adjustHighLats:AdjustingMethods , timeFormat:TimeForamts){
        self.caculationMethod = caculationmethod
        self.asrJuristic = asrJuristic
        self.adjustHighLats = adjustHighLats
        self.timeFormat = timeFormat
        
    }
    public init(caculationmethod: CalculationMethods, asrJuristic: AsrJuristicMethods, adjustHighLats:AdjustingMethods , timeFormat:TimeForamts, offsets:[Double]){
        self.offsets = offsets
    }
 
    // ---------------------- Trigonometric Functions -----------------------
    // range reduce angle in degrees.
    func  fixangle(var a: Double) -> Double {
        
        a = a - (360 * (floor(a / 360.0)))
        
        a = a < 0 ? (a + 360) : a
        
        return a
    }
    
    // range reduce hours to 0..23
    func fixhour(var a: Double) -> Double {
        a = a - 24.0 * floor(a / 24.0)
        a = a < 0 ? (a + 24) : a
        return a
    }
    
    // radian to degree
    func radiansToDegrees(alpha: Double) -> Double {
        return ((alpha * 180.0) / M_PI)
    }
    
    // deree to radian
    func DegreesToRadians(alpha: Double) -> Double {
        return ((alpha * M_PI) / 180.0)
    }
    
    // degree sin
    func dsin(d: Double) -> Double {
        return (sin(DegreesToRadians(d)))
    }
    
    // degree cos
    func dcos(d: Double) -> Double {
        return (cos(DegreesToRadians(d)))
    }
    
    // degree tan
    func dtan(d:Double) -> Double {
        return (tan(DegreesToRadians(d)))
    }
    
    // degree arcsin
    func darcsin(x: Double) -> Double {
        return radiansToDegrees(asin(x))
    }
    
    // degree arccos
    func darccos(x: Double) -> Double {
        return radiansToDegrees(acos(x))
    }
    
    // degree arctan
    func darctan(x: Double) -> Double {
        return radiansToDegrees(atan(x))
    }
    
    // degree arctan2
    func darctan2(y: Double, x: Double) -> Double {
        return radiansToDegrees(atan2(y, x))
    }
    
    // degree arccot
    func darccot(x: Double) -> Double{
        return radiansToDegrees(atan2(1.0, x))
    }
    
    
    
    
    // ---------------------- Julian Date Functions -----------------------
    // calculate julian date from a calendar date
    func julianDate(var year: Int,var month: Int, day: Int) -> Double{
        
        if (month <= 2) {
            year = year - 1
            month = month + 12
        }
        let a = floor(Double(year) / 100.0)
        let b = 2 - a + floor(a / 4.0)
        let jd1 = floor(365.25 * Double(year + 4716))
        let jd2 = floor(30.6001 * Double(month + 1))
        let jd = jd1 + jd2 + Double(day) + b - 1524.5
        
        return jd
    }
    
    // convert a calendar date to julian date (second method)
    func calcJD(year: Int,month: Int,day: Int) ->Double {
        let J1970 = 2440588.0
        let dateComponents = NSDateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        let calendar = NSCalendar.currentCalendar().dateFromComponents(dateComponents)
        let ms = (calendar?.timeIntervalSince1970)!*1000 // # of milliseconds since midnight Jan 1,
        // 1970
        let days = floor(ms / (1000.0 * 60.0 * 60.0 * 24.0))
        return J1970 + days - 0.5
        
    }
    // ---------------------- Calculation Functions -----------------------
    // References:
    // http://www.ummah.net/astronomy/saltime
    // http://aa.usno.navy.mil/faq/docs/SunApprox.html
    // compute declination angle of sun and equation of time
    func sunPosition(jd: Double) -> [Double] {
        
        let D = jd - 2451545
        let g = fixangle(357.529 + 0.98560028 * D)
        let q = fixangle(280.459 + 0.98564736 * D)
        let L = fixangle(q + (1.915 * dsin(g)) + (0.020 * dsin(2 * g)))
        
        // double R = 1.00014 - 0.01671 * [self dcos:g] - 0.00014 * [self dcos:
        // (2*g)]
        let e = 23.439 - (0.00000036 * D)
        let d = darcsin(dsin(e) * dsin(L))
        var RA = darctan2((dcos(e) * dsin(L)), x: dcos(L))/15.0
        RA = fixhour(RA)
        let EqT = q/15.0 - RA
        let sPosition: [Double] = [d,EqT]
        return sPosition
    }
    
    // compute equation of time
    func equationOfTime(jd: Double) -> Double {
        return sunPosition(jd)[1]
    }
    
    // compute declination angle of sun
    func sunDeclination(jd: Double) -> Double {
        return sunPosition(jd)[0]
    }
    
    // compute mid-day (Dhuhr, Zawal) time
    func computeMidDay(t: Double) -> Double {
        let T = equationOfTime(JDate + t)
        let Z = fixhour(12 - T)
        return Z
    }
    
    // compute time for a given angle G
    func computeTime(G: Double, t: Double) -> Double {
        let D = sunDeclination(JDate + t)
        let Z = computeMidDay(t)
        let Beg = -dsin(G) - dsin(D) * dsin(lat)
        let Mid = dcos(D) * dcos(lat)
        let V = darccos(Beg/Mid)/15.0
        return Z + (G > 90 ? -V : V)
    }
    
    // compute the time of Asr
    // Shafii: step=1, Hanafi: step=2
    func computeAsr(step: Double, t: Double) -> Double {
        let D = sunDeclination(JDate + t)
        let G = -darccot(step + dtan(abs(lat - D)))
        return computeTime(G, t: t)
    }
    
    
    // ---------------------- Misc Functions -----------------------
    // compute the difference between two times
    func timeDiff(time1: Double, time2: Double) -> Double {
        return fixhour(time2 - time1)
    }
    
    // -------------------- Interface Functions --------------------
    // return prayer times for a given date
    func getDatePrayerTimes(year: Int, month: Int, day: Int, latitude: Double, longitude: Double, tZone: Double) -> Set<String>{
        lat = latitude
        lng = longitude
        timeZone = tZone
        JDate = julianDate(year, month: month, day: day)
        let lonDiff = longitude / (15.0 * 24.0)
        JDate = JDate - lonDiff
        return computeDayTimes()
    }
    
    // return prayer times for a given date
    public func getPrayerTimes(date: NSCalendar, latitude: Double, longitude: Double, tZone: Double) -> Set<String> {
        
        let year = (date.component(NSCalendarUnit.Year, fromDate: NSDate()))
        let month = (date.component(NSCalendarUnit.Month, fromDate: NSDate()))
        let day = (date.component(NSCalendarUnit.Day, fromDate: NSDate()))
        
        return getDatePrayerTimes(year, month: month, day: day, latitude: latitude, longitude: longitude, tZone: tZone)
    }
    
    // set custom values for calculation parameters
    public func setCustomParams(var params: [Double]) {
        var newCustomeParms: [Double] = []
        for i in 1...5 {
            if (params[i] == -1) {
                let parm = methodParams[caculationMethod]
                newCustomeParms.append(parm![i])
            } else {
                newCustomeParms.append(params[i])
            }
        }
        methodParams[CalculationMethods.custom] = newCustomeParms
        caculationMethod = CalculationMethods.custom
    }
    
    // set the angle for calculating Fajr
    func setFajrAngle(angle: Double) {
        let params = [angle, -1, -1, -1, -1]
        setCustomParams(params)
    }
    
    // set the angle for calculating Maghrib
    func setMaghribAngle(angle: Double) {
        let params = [-1, 0, angle, -1, -1]
        setCustomParams(params)
        
    }
    
    // set the angle for calculating Isha
    func setIshaAngle(angle: Double) {
        let params = [-1, -1, -1, 0, angle]
        setCustomParams(params)
        
    }
    
    // convert double hours to 24h format
    func floatToTime24(var time: Double) -> String {
        
        var result: String
        
        if (time.isNaN) {
            return InvalidTime
        }
        
        time = fixhour(time + 0.5 / 60.0) // add 0.5 minutes to round
        let hours = Int(floor(time))
        let minutes = Int(floor((Double(time) - Double(hours)) * 60.0))
        
        if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
            result = "0\(hours):0\((minutes))"
        } else if ((hours >= 0 && hours <= 9)) {
            result = "0\(hours):\((minutes))"
        } else if ((minutes >= 0 && minutes <= 9)) {
            result = "\(hours):0\((minutes))"
        } else {
            result = "\(hours):\((minutes))"
        }
        return result
    }
    
    // convert double hours to 12h format
    func floatToTime12(var time: Double,noSuffix: Bool) ->String {
        
        if (time.isNaN){
            return InvalidTime
        }
        
        time = fixhour(time + 0.5 / 60) // add 0.5 minutes to round
        var hours: Int = Int(floor(time))
        let minutes = Int(floor((Double(time) - Double(hours)) * 60))
        var suffix: String, result: String
        if (hours >= 12) {
            suffix = "pm"
        } else {
            suffix = "am"
        }
        hours = (((hours+12)-1)%12)+1
        /*hours = (hours + 12) - 1
        int hrs = (int) hours % 12
        hrs += 1*/
        if (noSuffix == false) {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0\(hours):0\((minutes)) \(suffix)"
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0\(hours):\((minutes)) \(suffix)"
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = "\(hours):0\((minutes)) \(suffix)"
            } else {
                result = "\(hours):\((minutes)) \(suffix)"
            }
            
        } else {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0\(hours):0\((minutes))"
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0\(hours):\((minutes))"
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = "\(hours):0\((minutes))"
            } else {
                result = "\(hours):\((minutes))"
            }
        }
        return result
        
    }
    
    // convert double hours to 12h format with no suffix
    func floatToTime12NS(time: Double) -> String{
        return floatToTime12(time, noSuffix: true)
    }
    
    // ---------------------- Compute Prayer Times -----------------------
    // compute prayer times at given julian date
    func computeTimes(times: [Double]) -> [Double] {
        
        let t = dayPortion(times)
        let parm: [Double] = methodParams[caculationMethod]!
        let Fajr = computeTime(180 - parm[0], t: t[0])
        
        let Sunrise = computeTime(180 - 0.833, t: t[1])
        
        let Dhuhr = computeMidDay(t[2])
        let Asr = computeAsr(1.0 + Double(asrJuristic.rawValue), t: t[3])
        let Sunset = computeTime(0.833, t: t[4])
        
        let Maghrib = computeTime(parm[2],t: t[5])
        let Isha = computeTime(parm[4], t: t[6])
        
        let CTimes: [Double] = [Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha]
        
        return CTimes
        
    }
    // compute prayer times at given julian date
    func computeDayTimes() -> Set<String> {
        var times: [Double] = [5, 6, 12, 13, 18, 18, 18] // default times
        for _ in 1...numIterations{
            times = computeTimes(times)
        }
        times = adjustTimes(times)
        times = tuneTimes(times)
        return adjustTimesFormat(times)
    }
    
    // adjust times in a prayer time array
    func adjustTimes(var times: [Double]) -> [Double] {
        for i in 0...times.count-1{
            times[i] += timeZone - lng / 15
        }
        let parm = methodParams[caculationMethod]!
        
        times[2] = times[2] + Double(dhuhrMinutes) / 60 // Dhuhr
        if (parm[1] == 1) // Maghrib
        {
            times[5] = times[4] + parm[2]/60
        }
        if (parm[3] == 1) // Isha
        {
            times[6] = times[5] + parm[4]/60
        }
        
        if (adjustHighLats != AdjustingMethods.none) {
            times = adjustHighLatTimes(times)
        }
        
        return times
    }
    
    // convert times array to given time format
    func adjustTimesFormat(times: [Double]) -> Set<String> {
        
        var result = Set<String>()
        
        if (timeFormat == TimeForamts.floating) {
            for time in times {
                result.insert(String(time))
            }
            return result
        }
        
        for i in 0 ... 6{
            if (timeFormat == TimeForamts.time12) {
                result.insert(floatToTime12(times[i], noSuffix: false))
            } else if (timeFormat == TimeForamts.time12NS) {
                result.insert(floatToTime12(times[i], noSuffix: true))
            } else {
                result.insert(floatToTime24(times[i]))
            }
        }
        return result
    }
    
    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    func adjustHighLatTimes(var times: [Double]) -> [Double]{
        let nightTime = timeDiff(times[4], time2: times[1]) // sunset to sunrise
        
        // Adjust Fajr
        let parm = methodParams[caculationMethod]!
        let FajrDiff = nightPortion(parm[0]) * nightTime
        
        if (times[0].isNaN || timeDiff(times[0], time2: times[1]) > FajrDiff) {
            times[0] = times[1] - FajrDiff
        }
        
        // Adjust Isha
        let IshaAngle = (parm[3] == 0) ? parm[4] : 18
        let IshaDiff = nightPortion(IshaAngle) * nightTime
        if (times[6].isNaN || timeDiff(times[4], time2: times[6]) > IshaDiff) {
            times[6] = times[4] + IshaDiff
        }
        
        // Adjust Maghrib
        let MaghribAngle = (parm[1] == 0) ? parm[2] : 4
        let MaghribDiff = nightPortion(MaghribAngle) * nightTime
        if (times[5].isNaN || timeDiff(times[4], time2: times[5]) > MaghribDiff) {
            times[5] = times[4] + MaghribDiff
        }
        
        return times
    }
    // the night portion used for adjusting times in higher latitudes
    func nightPortion(angle: Double) -> Double {
        var calc : Double = 0.0
        if (adjustHighLats == AdjustingMethods.angleBased){
            calc = (angle)/60.0
        }else if (adjustHighLats == AdjustingMethods.midNight){
            calc = 0.5
        }else if (adjustHighLats == AdjustingMethods.oneSeventh){
            calc = 0.14286
        }
        return calc
    }
    
    // convert hours to day portions
    func dayPortion(var times: [Double]) -> [Double] {
        for i in 0...6{
            times[i] /= 24
        }
        return times
    }
    
    // Tune timings for adjustments
    // Set time offsets
    func tune(offsetTimes: [Double]) {
        for i in 0...offsets.count{ // offsetTimes length
            // should be 7 in order
            // of Fajr, Sunrise,
            // Dhuhr, Asr, Sunset,
            // Maghrib, Isha
            offsets[i] = offsetTimes[i]
            
        }
        
    }
    
    public func tuneTimes(var times: [Double]) -> [Double] {
        for i in 0...times.count-1{
            times[i] = times[i]+offsets[i]/60.0
        }
        
        
        return times
    }
    
    public func getTimeNames() -> [String]{
        return timeNames
    }
}
