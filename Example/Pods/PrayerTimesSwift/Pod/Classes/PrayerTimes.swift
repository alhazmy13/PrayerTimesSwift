//
//  main.swift
//  PrayerTimes
//
//  Created by Abdullah Alhazmy on 1/26/16.
//  Copyright © 2016 Abdullah Alhazmy. All rights reserved.
//

import Foundation

public class PrayerTimes {
    
    // MARK:- Global public variables
    
    /// CalculationMethods(rawValue:  4)! // caculation methodq
    public var caculationMethod: CalculationMethods = .makkah
    /// Juristic method for Asr
    public var asrJuristic : AsrJuristicMethods = .shafii
    /// adjusting method for higher latitudes
    public var adjustHighLats : AdjustingMethods = .none
    /// time format
    public var timeFormat: TimeForamts = .time24
    
    
    // MARK:- Global private variables
    
    /// minutes after mid-day for Dhuhr
    private var dhuhrMinutes: Int = 0
    private var prayerTimesCurrent: [Double] = []
    private var offsets: [Double] = [Double](repeating: 0.0, count: 7)
    /// latitude
    private var lat: Double = Double()
    /// longitude
    private var lng: Double = Double()
    /// time-zone
    private var timeZone: Double = Double()
    /// Julian date
    private var JDate: Double = Double() //0.0
    
    
    // MARK:- PrayerName
    
    internal enum PrayerName: String, CaseIterable {
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case sunset = "Sunset"
        case maghrib = "Maghrib"
        case isha = "Isha"
        case invalidTime =  " ---- "
        
        static var all: [PrayerName] {
            [.fajr, .sunrise, .dhuhr, .asr , .sunset, .maghrib, .isha]
        }
    }
    
    
    // MARK:- Calculation Methods
    
    public enum CalculationMethods: Int {
        /// Ithna Ashari
        case jafari = 0
        /// University of Islamic Sciences, Karachi
        case karachi
        /// Islamic Society of North America (ISNA)
        case isna
        /// Muslim World League (MWL)
        case mwl
        /// Umm al-Qura, Makkah
        case makkah
        /// Egyptian General Authority of Survey
        case egypt
        /// Custom Setting
        case custom
        // Institute of Geophysics, University of Tehran
        case tehran
    }
    
    
    // MARK:- Juristic Methods
    
    public enum AsrJuristicMethods: Int {
        case shafii // Shafii (standard)
        case hanafi // Hanafi
    }
    
    
    // MARK:- Adjusting Methods for Higher Latitudes
    
    public enum AdjustingMethods: Int {
        /// No adjustment
        case none
        /// middle of night
        case midNight
        /// 1/7th of night
        case oneSeventh
        /// floating point number
        case angleBased
    }
    
    
    // MARK:- Time Formats
    
    public enum TimeForamts: Int {
        /// 24-hour format
        case time24
        /// 12-hour format
        case time12
        /// 12-hour format with no suffix
        case time12NS
        /// angle/60th of night
        case floating
    }
    
    /// number of iterations needed to compute times
    let numIterations: Int = 1
    
    // MARK:- Method Params
    
    var methodParams: [CalculationMethods: [Double]] = [
        .jafari: [16,0,4,0,14],
        .karachi: [18,1,0,0,18],
        .isna: [15,1,0,0,15],
        .mwl: [18,1,0,0,17],
        .makkah: [18.5,1,0,1,90],
        .egypt: [18,1,0,0,17],
        .custom: [19.5,1,0,0,17.5],
        .tehran: [17.7,0,4.5,0,14]
    ]
    
    
    // MARK:- init
    
    public init(
        caculationMethod: CalculationMethods,
        asrJuristic: AsrJuristicMethods,
        adjustHighLats: AdjustingMethods,
        timeFormat: TimeForamts
    ){
        
        self.caculationMethod = caculationMethod
        self.asrJuristic = asrJuristic
        self.adjustHighLats = adjustHighLats
        self.timeFormat = timeFormat
        
    }
    
    /// init with offsets
    public init(
        caculationMethod: CalculationMethods,
        asrJuristic: AsrJuristicMethods,
        adjustHighLats: AdjustingMethods ,
        timeFormat: TimeForamts,
        offsets: [Double]
    ){
        
        self.caculationMethod = caculationMethod
        self.asrJuristic = asrJuristic
        self.adjustHighLats = adjustHighLats
        self.timeFormat = timeFormat
        self.offsets = offsets
    }
    
    
    // MARK:- Julian Date Functions
    
    /// Calculate julian date from a calendar date
    func julianDate(_ year: Int, month: Int, day: Int) -> Double {
        
        var adujestedYear = year
        var adujestedMonth = month
        
        if (adujestedMonth <= 2) {
            adujestedYear = adujestedYear - 1
            adujestedMonth = adujestedMonth + 12
        }
        
        let a = floor(Double(adujestedYear) / 100.0)
        let b = 2 - a + floor(a / 4.0)
        let jd1 = floor(365.25 * Double(adujestedYear + 4716))
        let jd2 = floor(30.6001 * Double(adujestedMonth + 1))
        let jd = jd1 + jd2 + Double(day) + b - 1524.5
        
        return jd
    }
    
    /// Convert a calendar date to julian date (second method)
    func calcJD(year: Int, month: Int, day: Int) -> Double {
        let J1970 = 2440588.0
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        guard let calendar = Calendar.current.date(from: dateComponents) else { return J1970 }
        // # of milliseconds since midnight Jan 1, 1970
        let ms = calendar.timeIntervalSince1970 * 1000
        let days = floor(ms / (1000.0 * 60.0 * 60.0 * 24.0))
        return J1970 + days - 0.5
    }
    
    
    //MARK:- Calculation Functions
    
    /// Compute declination angle of sun and equation of time
    /// 
    /// References:
    /// http://www.ummah.net/astronomy/saltime
    /// http://aa.usno.navy.mil/faq/docs/SunApprox.html
    func sunPosition(jd: Double) -> [Double] {
        
        let D = jd - 2451545
        let g = Double.fixAngle(357.529 + 0.98560028 * D)
        let q = Double.fixAngle(280.459 + 0.98564736 * D)
        let L = Double.fixAngle(q + (1.915 * Double.dSin(g)) + (0.020 * Double.dSin(2 * g)))
        
        // double R = 1.00014 - 0.01671 * [self dCos:g] - 0.00014 * [self dCos:
        // (2*g)]
        let e = 23.439 - (0.00000036 * D)
        let d = Double.dArcSin(Double.dSin(e) * Double.dSin(L))
        var RA = Double.dArcTan2((Double.dCos(e) * Double.dSin(L)), x: Double.dCos(L))/15.0
        RA = Double.fixHour(RA)
        let EqT = q/15.0 - RA
        let sPosition: [Double] = [d,EqT]
        return sPosition
    }
    
    /// Compute equation of time
    func equationOfTime(_ jd: Double) -> Double {
        return sunPosition(jd: jd)[1]
    }
    
    /// Compute declination angle of sun
    func sunDeclination(_ jd: Double) -> Double {
        return sunPosition(jd: jd)[0]
    }
    
    /// Compute mid-day (Dhuhr, Zawal) time
    func computeMidDay(_ t: Double) -> Double {
        let T = equationOfTime(JDate + t)
        let Z = Double.fixHour(12 - T)
        return Z
    }
    
    /// Compute time for a given angle G
    func computeTime(_ G: Double, t: Double) -> Double {
        let D = sunDeclination(JDate + t)
        let Z = computeMidDay(t)
        let Beg = -Double.dSin(G) - Double.dSin(D) * Double.dSin(lat)
        let Mid = Double.dCos(D) * Double.dCos(lat)
        let V = Double.dArcCos(Beg/Mid)/15.0
        return Z + (G > 90 ? -V : V)
    }
    
    /// Compute the time of Asr
    ///
    /// Shafii: step=1, Hanafi: step=2
    func computeAsr(_ step: Double, t: Double) -> Double {
        let D = sunDeclination(JDate + t)
        let G = -Double.dArcCot(step + Double.dTan(abs(lat - D)))
        return computeTime(G, t: t)
    }
    
    
    // MARK:- Misc Functions
    
    /// Compute the difference between two times
    func timeDiff(time1: Double, time2: Double) -> Double {
        return Double.fixHour(time2 - time1)
    }
    
    
    // MARK:- Interface Functions
    
    /// Getting prayer time date
    ///
    /// - Returns: prayer times for a given date
    func getDatePrayerTimes(year: Int, month: Int, day: Int, latitude: Double, longitude: Double, tZone: Double) -> Set<String> {
        lat = latitude
        lng = longitude
        timeZone = tZone
        JDate = julianDate(year, month: month, day: day)
        let lonDiff = longitude / (15.0 * 24.0)
        JDate = JDate - lonDiff
        return computeDayTimes()
    }
    
    // return prayer times for a given date
    
    /// Getting prayer times
    ///
    /// - Returns: prayer times
    public func getPrayerTimes(date: Calendar, latitude: Double, longitude: Double, tZone: Double) -> Set<String> {
        
        let currentDate = Date()
        let year = date.component(.year, from: currentDate)
        let month = date.component(.month, from: currentDate)
        let day = date.component(.day, from: currentDate)
        
        return getDatePrayerTimes(year: year, month: month, day: day, latitude: latitude, longitude: longitude, tZone: tZone)
    }
    
    /// Set custom values for calculation parameters
    public func setCustomParams(with params: [Double]) {
        
        var newCustomeParms: [Double] = []
        for i in 1...5 {
            if (params[i] == -1) {
                let parm = methodParams[caculationMethod]
                newCustomeParms.append(parm![i])
            } else {
                newCustomeParms.append(params[i])
            }
        }
        methodParams[.custom] = newCustomeParms
        caculationMethod = .custom
    }
    
    /// Set the angle for calculating Fajr
    func setFajrAngle(angle: Double) {
        let params = [angle, -1, -1, -1, -1]
        setCustomParams(with: params)
    }
    
    /// Set the angle for calculating Maghrib
    func setMaghribAngle(angle: Double) {
        let params = [-1, 0, angle, -1, -1]
        setCustomParams(with: params)
        
    }
    
    /// Set the angle for calculating Isha
    func setIshaAngle(angle: Double) {
        let params = [-1, -1, -1, 0, angle]
        setCustomParams(with: params)
        
    }
    
    /// Convert double hours to 24h format
    func floatToTime24(_ time: Double) -> String {
        
        var result: String
        
        if (time.isNaN) {
            return PrayerName.invalidTime.rawValue
        }
        
        let fixedTime = Double.fixHour(time + 0.5 / 60.0) // add 0.5 minutes to round
        let hours = Int(floor(fixedTime))
        let minutes = Int(floor((Double(fixedTime) - Double(hours)) * 60.0))
        
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
    
    /// Convert double hours to 12h format
    func floatToTime12(_ time: Double, noSuffix: Bool) -> String {
        
        var adujestedTime = time
        
        if (adujestedTime.isNaN){
            return PrayerName.invalidTime.rawValue
        }
        
        adujestedTime = Double.fixHour(adujestedTime + 0.5 / 60) // add 0.5 minutes to round
        
        var hours: Int = Int(floor(adujestedTime))
        let minutes = Int(floor( (Double(adujestedTime) - Double(hours)) * 60))
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
    
    /// Convert double hours to 12h format with no suffix
    func floatToTime12NS(_  time: Double) -> String{
        floatToTime12(time, noSuffix: true)
    }
    
    
    // MARK:- Compute Prayer Times
    
    /// Compute prayer times at given julian date
    func computeTimes(_ times: [Double]) -> [Double] {
        
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
    
    /// Compute prayer times at given julian date
    func computeDayTimes() -> Set<String> {
        var times: [Double] = [5, 6, 12, 13, 18, 18, 18] // default times
        for _ in 1...numIterations{
            times = computeTimes(times)
        }
        times = adjustTimes(times)
        times = tuneTimes(times)
        return adjustTimesFormat(times)
    }
    
    /// Adjust times in a prayer time array
    func adjustTimes(_ times: [Double]) -> [Double] {
        
        var aTime : [Double] = []
        for i in 0..<times.count {
            let element = times[i] + timeZone - lng / 15
            aTime.append(element)
        }
        
        let parm = methodParams[caculationMethod]!
        
        aTime[2] = aTime[2] + Double(dhuhrMinutes) / 60 // Dhuhr
        
         // Maghrib
        if parm[1] == 1 {
            aTime[5] = aTime[4] + parm[2] / 60
        }
        
        // Isha
        if parm[3] == 1 {
            aTime[6] = aTime[5] + parm[4] / 60
        }
        
        if adjustHighLats != .none {
            aTime = adjustHighLatTimes(aTime)
        }
        
        return aTime
    }
    
    /// Convert times array to given time format
    func adjustTimesFormat(_ times: [Double]) -> Set<String> {
        
        var result = Set<String>()
        
        if (timeFormat == .floating) {
            for time in times {
                result.insert(String(time))
            }
            return result
        }
        
        for i in 0 ... 6{
            if (timeFormat == .time12) {
                result.insert(floatToTime12(times[i], noSuffix: false))
            } else if (timeFormat == .time12NS) {
                result.insert(floatToTime12(times[i], noSuffix: true))
            } else {
                result.insert(floatToTime24(times[i]))
            }
        }
        return result
    }
    
    /// Adjust Fajr, Isha and Maghrib for locations in higher latitudes
    func adjustHighLatTimes(_ timesParamter: [Double]) -> [Double]{
        var times = timesParamter;
        let nightTime = timeDiff(time1: times[4], time2: times[1]) // sunset to sunrise
        
        // Adjust Fajr
        let parm = methodParams[caculationMethod]!
        let FajrDiff = nightPortion(parm[0]) * nightTime
        
        if times[0].isNaN || timeDiff(time1: times[0], time2: times[1]) > FajrDiff {
            times[0] = times[1] - FajrDiff
        }
        
        // Adjust Isha
        let IshaAngle = (parm[3] == 0) ? parm[4] : 18
        let IshaDiff = nightPortion(IshaAngle) * nightTime
        if times[6].isNaN || timeDiff(time1: times[4], time2: times[6]) > IshaDiff {
            times[6] = times[4] + IshaDiff
        }
        
        // Adjust Maghrib
        let MaghribAngle = (parm[1] == 0) ? parm[2] : 4
        let MaghribDiff = nightPortion(MaghribAngle) * nightTime
        if times[5].isNaN || timeDiff(time1: times[4], time2: times[5]) > MaghribDiff {
            times[5] = times[4] + MaghribDiff
        }
        
        return times
    }
    
    /// The night portion used for adjusting times in higher latitudes
    func nightPortion(_ angle: Double) -> Double {
        var calc : Double = 0.0
        if (adjustHighLats == .angleBased){
            calc = (angle)/60.0
        } else if (adjustHighLats == .midNight){
            calc = 0.5
        } else if (adjustHighLats == .oneSeventh){
            calc = 0.14286
        }
        return calc
    }
    
    /// Convert hours to day portions
    func dayPortion(_ times: [Double]) -> [Double] {
        
        var timeAdjesment : [Double] = []
        for i in 0..<times.count {
            timeAdjesment.append(times[i] / 24)
        }
        return timeAdjesment
    }
    
    
    // MARK:- Tune timings for adjustments
    
    /// Set time offsets
    func tune(_ offsetTimes: [Double]) {
        for i in 0...offsets.count { // offsetTimes length
            // should be 7 in order
            // of Fajr, Sunrise,
            // Dhuhr, Asr, Sunset,
            // Maghrib, Isha
            offsets[i] = offsetTimes[i]
        }
    }
    
    public func tuneTimes(_ times: [Double]) -> [Double] {
        var aTimes : [Double] = []
        for i in 0..<times.count {
            aTimes.append(times[i]+offsets[i]/60.0)
        }
        return aTimes
    }
}


extension Double {
    
    // MARK:- Trigonometric Functions
    
    // range reduce angle in degrees.
    static func fixAngle(_ a: Double) -> Double {
        let reduceAngle = a - (360 * (floor(a / 360.0)))
        let angle = reduceAngle < 0 ? (reduceAngle + 360) : reduceAngle
        return angle
    }
    
    // range reduce hours to 0..23
    static func fixHour(_ a: Double) -> Double {
        
        let reduceHour = a - 24.0 * floor(a / 24.0)
        let fixHour = reduceHour < 0 ? (reduceHour + 24) : reduceHour
        
        return fixHour
    }
    
    // radian to degree
    static func radiansToDegrees(_ alpha: Double) -> Double {
        (alpha * 180.0) / Double.pi
    }
    
    // deree to radian
    static func degreesToRadians(_ alpha: Double) -> Double {
        (alpha * Double.pi) / 180.0
    }
    
    // degree sin
    static func dSin(_ d: Double) -> Double {
        sin(degreesToRadians(d))
    }
    
    // degree cos
    static func dCos(_ d: Double) -> Double {
        cos(degreesToRadians(d))
    }
    
    // degree tan
    static func dTan(_ d:Double) -> Double {
        tan(degreesToRadians(d))
    }
    
    // degree arcsin
    static func dArcSin(_ x: Double) -> Double {
        radiansToDegrees(asin(x))
    }
    
    // degree arccos
    static func dArcCos(_ x: Double) -> Double {
        radiansToDegrees(acos(x))
    }
    
    // degree arctan
    static func dArcTan(_ x: Double) -> Double {
        radiansToDegrees(atan(x))
    }
    
    // degree arctan2
    static func dArcTan2(_ y: Double, x: Double) -> Double {
        radiansToDegrees(atan2(y, x))
    }
    
    // degree arccot
    static func dArcCot(_ x: Double) -> Double{
        radiansToDegrees(atan2(1.0, x))
    }
}
