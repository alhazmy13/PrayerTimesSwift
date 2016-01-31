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
    public var Caculationmethod: Int = 4 // caculation method
    public var asrJuristic: Int = 0 // Juristic method for Asr
    public var dhuhrMinutes: Int = 0 // minutes after mid-day for Dhuhr
    public var adjustHighLats: Int = 0 // adjusting method for higher latitudes
    public var timeFormat: Int = 0 // time format
    var prayerTimesCurrent: [Double] = []
    var offsets: [Double] = [0,0,0,0,0,0,0]
    var lat: Double = 0.0 // latitude
    var lng: Double = 0.0 // longitude
    var timeZone: Double = 0.0 // time-zone
    var JDate: Double = 0.0 // Julian date
    // ------------------------------------------------------------
    // Calculation Methods
    public struct CalculationMethods {
        public static let Jafari: Int = 0 // Ithna Ashari
        public static let Karachi: Int = 1 // University of Islamic Sciences, Karachi
        public static let ISNA: Int = 2 // Islamic Society of North America (ISNA)
        public static let MWL: Int = 3 // Muslim World League (MWL)
        public static let Makkah: Int = 4 // Umm al-Qura, Makkah
        public static let Egypt: Int = 5 // Egyptian General Authority of Survey
        public static let Custom: Int = 6 // Custom Setting
        public static let Tehran: Int = 7 // Institute of Geophysics, University of Tehran
    }
    // ------------------------------------------------------------
    // Juristic Methods
    public struct AsrJuristicMethods {
        public static let Shafii: Int = 0 // Shafii (standard)
        public static let Hanafi: Int = 1 // Hanafi
    }
    
    // ------------------------------------------------------------
    // Adjusting Methods for Higher Latitudes
    public struct AdjustingMethods {
        public static let None: Int = 0 // No adjustment
        public static let MidNight: Int = 1 // middle of night
        public static let OneSeventh: Int = 2 // 1/7th of night
        public static let AngleBased: Int = 3 // floating point number
    }
    
    // ------------------------------------------------------------
    // Time Formats
    public struct TimeForamts {
        public static let Time24: Int = 0 // 24-hour format
        public static let Time12: Int = 1 // 12-hour format
        public static let Time12NS: Int = 2 // 12-hour format with no suffix
        public static let Floating: Int = 3 // angle/60th of night
    }
    
    // ------------------------------------------------------------
    // Time Names
    let timeNames: [String] = ["Fajr","Sunrise","Dhuhr","Asr","Sunset","Maghrib","Isha"]
    let InvalidTime: String = "-----" // The string used for invalid times
    // ------------------------------------------------------------
    // Time Names
    let numIterations: Int = 1// number of iterations needed to compute times
    var methodParams: [Int: [Double]] = [
        0: [16,0,4,0,14],
        1: [18,1,0,0,18],
        2: [15,1,0,0,15],
        3: [18,1,0,0,17],
        4: [18.5,1,0,1,90],
        5: [18,1,0,0,17],
        6: [19.5,1,0,0,17.5],
        7: [17.7,0,4.5,0,14]
        
    ]
    
    // ------------------------------------------------------------
    // Init
    
    public init(Caculationmethod: Int, asrJuristic: Int, adjustHighLats:Int , timeFormat:Int){
        self.Caculationmethod = Caculationmethod
        self.asrJuristic = asrJuristic
        self.adjustHighLats = adjustHighLats
        self.timeFormat = timeFormat
        
    }
    public init(Caculationmethod: Int, asrJuristic: Int, adjustHighLats:Int , timeFormat:Int, offsets:[Double]){
        self.Caculationmethod = Caculationmethod
        self.asrJuristic = asrJuristic
        self.adjustHighLats = adjustHighLats
        self.timeFormat = timeFormat
        self.offsets = offsets
    }
    
    
    
    // ---------------------- Trigonometric Functions -----------------------
    // range reduce angle in degrees.
    internal func  fixangle(var a: Double) -> Double {
        
        a = a - (360 * (floor(a / 360.0)))
        
        a = a < 0 ? (a + 360) : a
        
        return a
    }
    
    // range reduce hours to 0..23
    internal func fixhour(var a: Double) -> Double {
        a = a - 24.0 * floor(a / 24.0)
        a = a < 0 ? (a + 24) : a
        return a
    }
    
    // radian to degree
    internal func radiansToDegrees(alpha: Double) -> Double {
        return ((alpha * 180.0) / M_PI)
    }
    
    // deree to radian
    internal func DegreesToRadians(alpha: Double) -> Double {
        return ((alpha * M_PI) / 180.0)
    }
    
    // degree sin
    internal func dsin(d: Double) -> Double {
        return (sin(DegreesToRadians(d)))
    }
    
    // degree cos
    internal func dcos(d: Double) -> Double {
        return (cos(DegreesToRadians(d)))
    }
    
    // degree tan
    internal func dtan(d:Double) -> Double {
        return (tan(DegreesToRadians(d)))
    }
    
    // degree arcsin
    internal func darcsin(x: Double) -> Double {
        return radiansToDegrees(asin(x))
    }
    
    // degree arccos
    internal func darccos(x: Double) -> Double {
        return radiansToDegrees(acos(x))
    }
    
    // degree arctan
    internal func darctan(x: Double) -> Double {
        return radiansToDegrees(atan(x))
    }
    
    // degree arctan2
    internal func darctan2(y: Double, x: Double) -> Double {
        return radiansToDegrees(atan2(y, x))
    }
    
    // degree arccot
    internal func darccot(x: Double) -> Double{
        return radiansToDegrees(atan2(1.0, x))
    }
    
    
    
    
    // ---------------------- Julian Date Functions -----------------------
    // calculate julian date from a calendar date
    internal func julianDate(var year: Int,var month: Int, day: Int) -> Double{
        
        if (month <= 2) {
            year = year - 1
            month = month + 12
        }
        let A = floor(Double(year) / 100.0)
        let B = 2 - A + floor(A / 4.0)
        let JD1 = floor(365.25 * Double(year + 4716))
        let JD2 = floor(30.6001 * Double(month + 1))
        let JD = JD1 + JD2 + Double(day) + B - 1524.5
        
        return JD
    }
    
    // convert a calendar date to julian date (second method)
    internal func calcJD(year: Int,month: Int,day: Int) ->Double {
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
    internal func sunPosition(jd: Double) -> [Double] {
        
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
    internal func equationOfTime(jd: Double) -> Double {
        return sunPosition(jd)[1]
    }
    
    // compute declination angle of sun
    internal func sunDeclination(jd: Double) -> Double {
        return sunPosition(jd)[0]
    }
    
    // compute mid-day (Dhuhr, Zawal) time
    internal func computeMidDay(t: Double) -> Double {
        let T = equationOfTime(JDate + t)
        let Z = fixhour(12 - T)
        return Z
    }
    
    // compute time for a given angle G
    internal func computeTime(G: Double, t: Double) -> Double {
        let D = sunDeclination(JDate + t)
        let Z = computeMidDay(t)
        let Beg = -dsin(G) - dsin(D) * dsin(lat)
        let Mid = dcos(D) * dcos(lat)
        let V = darccos(Beg/Mid)/15.0
        return Z + (G > 90 ? -V : V)
    }
    
    // compute the time of Asr
    // Shafii: step=1, Hanafi: step=2
    internal func computeAsr(step: Double, t: Double) -> Double {
        let D = sunDeclination(JDate + t)
        let G = -darccot(step + dtan(abs(lat - D)))
        return computeTime(G, t: t)
    }
    
    
    // ---------------------- Misc Functions -----------------------
    // compute the difference between two times
    internal func timeDiff(time1: Double, time2: Double) -> Double {
        return fixhour(time2 - time1)
    }
    
    // -------------------- Interface Functions --------------------
    // return prayer times for a given date
    internal func getDatePrayerTimes(year: Int, month: Int, day: Int, latitude: Double, longitude: Double, tZone: Double) -> Set<String>{
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
                let parm = methodParams[Caculationmethod]
                newCustomeParms.append(parm![i])
            } else {
                newCustomeParms.append(params[i])
            }
        }
        methodParams[CalculationMethods.Custom] = newCustomeParms
        Caculationmethod = CalculationMethods.Custom
    }
    
    // set the angle for calculating Fajr
    internal func setFajrAngle(angle: Double) {
        let params = [angle, -1, -1, -1, -1]
        setCustomParams(params)
    }
    
    // set the angle for calculating Maghrib
    internal func setMaghribAngle(angle: Double) {
        let params = [-1, 0, angle, -1, -1]
        setCustomParams(params)
        
    }
    
    // set the angle for calculating Isha
    internal func setIshaAngle(angle: Double) {
        let params = [-1, -1, -1, 0, angle]
        setCustomParams(params)
        
    }
    
    // convert double hours to 24h format
    internal func floatToTime24(var time: Double) -> String {
        
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
    internal func floatToTime12(var time: Double,noSuffix: Bool) ->String {
        
        if (time.isNaN){
            return InvalidTime
        }
        
        time = fixhour(time + 0.5 / 60) // add 0.5 minutes to round
        var hours: Int = Int(floor(time))
        let minutes = Int(floor((Double(time) - Double(hours)) * 60))
        let suffix: String, result: String
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
    internal func floatToTime12NS(time: Double) -> String{
        return floatToTime12(time, noSuffix: true)
    }
    
    // ---------------------- Compute Prayer Times -----------------------
    // compute prayer times at given julian date
    internal func computeTimes(times: [Double]) -> [Double] {
        
        let t = dayPortion(times)
        let parm: [Double] = methodParams[Caculationmethod]!
        let Fajr = computeTime(180 - parm[0], t: t[0])
        
        let Sunrise = computeTime(180 - 0.833, t: t[1])
        
        let Dhuhr = computeMidDay(t[2])
        let Asr = computeAsr(1.0 + Double(asrJuristic), t: t[3])
        let Sunset = computeTime(0.833, t: t[4])
        
        let Maghrib = computeTime(parm[2],t: t[5])
        let Isha = computeTime(parm[4], t: t[6])
        
        let CTimes: [Double] = [Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha]
        
        return CTimes
        
    }
    // compute prayer times at given julian date
    internal func computeDayTimes() -> Set<String> {
        var times: [Double] = [5, 6, 12, 13, 18, 18, 18] // default times
        for _ in 1...numIterations{
            times = computeTimes(times)
        }
        times = adjustTimes(times)
        times = tuneTimes(times)
        return adjustTimesFormat(times)
    }
    
    // adjust times in a prayer time array
    internal func adjustTimes(var times: [Double]) -> [Double] {
        for i in 0...times.count-1{
            times[i] += timeZone - lng / 15
        }
        let parm = methodParams[Caculationmethod]!
        
        times[2] = times[2] + Double(dhuhrMinutes) / 60 // Dhuhr
        if (parm[1] == 1) // Maghrib
        {
            times[5] = times[4] + parm[2]/60
        }
        if (parm[3] == 1) // Isha
        {
            times[6] = times[5] + parm[4]/60
        }
        
        if (adjustHighLats != AdjustingMethods.None) {
            times = adjustHighLatTimes(times)
        }
        
        return times
    }
    
    // convert times array to given time format
    internal func adjustTimesFormat(times: [Double]) -> Set<String> {
        
        var result = Set<String>()
        
        if (timeFormat == TimeForamts.Floating) {
            for time in times {
                result.insert(String(time))
            }
            return result
        }
        
        for i in 0 ... 6{
            if (timeFormat == TimeForamts.Time12) {
                result.insert(floatToTime12(times[i], noSuffix: false))
            } else if (timeFormat == TimeForamts.Time12NS) {
                result.insert(floatToTime12(times[i], noSuffix: true))
            } else {
                result.insert(floatToTime24(times[i]))
            }
        }
        return result
    }
    
    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    internal func adjustHighLatTimes(var times: [Double]) -> [Double]{
        let nightTime = timeDiff(times[4], time2: times[1]) // sunset to sunrise
        
        // Adjust Fajr
        let parm = methodParams[Caculationmethod]!
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
    internal func nightPortion(angle: Double) -> Double {
        var calc : Double = 0.0
        if (adjustHighLats == AdjustingMethods.AngleBased){
            calc = (angle)/60.0
        }else if (adjustHighLats == AdjustingMethods.MidNight){
            calc = 0.5
        }else if (adjustHighLats == AdjustingMethods.OneSeventh){
            calc = 0.14286
        }
        return calc
    }
    
    // convert hours to day portions
    internal func dayPortion(var times: [Double]) -> [Double] {
        for i in 0...6{
            times[i] /= 24
        }
        return times
    }
    
    // Tune timings for adjustments
    // Set time offsets
    internal func tune(offsetTimes: [Double]) {
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
