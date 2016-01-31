# PrayerTimesSwift

[![CI Status](http://img.shields.io/travis/alhazmy13/PrayerTimesSwift.svg?style=flat)](https://travis-ci.org/alhazmy13/PrayerTimesSwift)
[![Version](https://img.shields.io/cocoapods/v/PrayerTimesSwift.svg?style=flat)](http://cocoapods.org/pods/PrayerTimesSwift)
[![License](https://img.shields.io/cocoapods/l/PrayerTimesSwift.svg?style=flat)](http://cocoapods.org/pods/PrayerTimesSwift)
[![Platform](https://img.shields.io/cocoapods/p/PrayerTimesSwift.svg?style=flat)](http://cocoapods.org/pods/PrayerTimesSwift)

Prayer Times provides a set of handy functions to calculate prayer times for any location around the world, based on a variety of calculation methods currently used in Muslim communities.

You can report any issue on issues page. **Note: If you speak Arabic, you can submit issues with Arabic language and I will check them. :)**

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Create an `PrayerTime`
You will need to create a new instance of `PrayerTime`. Once the instance are configured, you can call `getPrayerTimes()`.

```swift
let myPrayerTime = PrayerTimes(Caculationmethod: PrayerTimes.CalculationMethods.Makkah, asrJuristic: PrayerTimes.AsrJuristicMethods.Hanafi, adjustHighLats: PrayerTimes.AdjustingMethods.None, timeFormat: PrayerTimes.TimeForamts.Time24)
let prayerTimes = myPrayerTime.getPrayerTimes(NSCalendar.currentCalendar(), latitude: 24.7993689, longitude: 46.6176563, tZone: 3)
```


### Configurations
* `TimeFormat` To change the time format to:
	* `Time24`  24-hour format
	* `Time12`  12-hour format
	* `Time12NS`  12-hour format with no suffix
	* `Floating`  floating point number
```swift
myPrayerTime.timeFormat = PrayerTimes.TimeForamts.Time24
```
* `Caculationmethod` To change the Calculation Methods.
	* `Karachi`  University of Islamic Sciences, Karachi
	* `ISNA`  Islamic Society of North America (ISNA)
	* `MWL`  Muslim World League (MWL)
	* `Makkah`  Umm al-Qura, Makkah
	* `Egypt`  Egyptian General Authority of Survey
	* `Jafari`  Ithna Ashari
	* `Tehran`  Institute of Geophysics, University of Tehran
	* `Custom`  Custom Setting
```swift
 myPrayerTime.Caculationmethod = PrayerTimes.CalculationMethods.Makkah
```
* `AsrJuristic` To change Juristic Method for Asr
	* `Shafii`  Shafii (standard)
	* `Hanafi`  Hanafi
```swift
myPrayerTime.asrJuristic = PrayerTimes.AsrJuristicMethods.Shafii
```
* `AdjustHighLats` Adjusting Methods for Higher Latitudes
	* `None`  No adjustment
	* `MidNight`  middle of night
	* `OneSeventh`  1/7th of night
	* `AngleBased`  angle/60th of night
```swift
myPrayerTime.adjustHighLats = PrayerTimes.AdjustingMethods.None
```
* `tuneTimes` Tune timings for adjustments
```swift
        myPrayerTime.tuneTimes([0,0,0,0,0,0,0])
```


## Requirements

## Installation

PrayerTimesSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PrayerTimesSwift"
```

## Author

Abdullah Alhazmy, me@alhazmy13.net

## License

PrayerTimesSwift is available under the MIT license. See the LICENSE file for more info.
