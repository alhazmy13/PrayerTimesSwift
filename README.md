<p align="center">
  <img src="https://cloud.githubusercontent.com/assets/4659608/12704381/cc10b62a-c86a-11e5-9624-6cdb12ea1e74.png">
</p>
# PrayerTimesSwift
[![Version](https://img.shields.io/cocoapods/v/PrayerTimesSwift.svg?style=flat)](http://cocoapods.org/pods/PrayerTimesSwift)
[![License](https://img.shields.io/cocoapods/l/PrayerTimesSwift.svg?style=flat)](http://cocoapods.org/pods/PrayerTimesSwift)
[![Platform](https://img.shields.io/cocoapods/p/PrayerTimesSwift.svg?style=flat)](http://cocoapods.org/pods/PrayerTimesSwift)

Prayer Times provides a set of handy functions to calculate prayer times for any location around the world, based on a variety of calculation methods currently used in Muslim communities.

You can report any issue on issues page. **Note: If you speak Arabic, you can submit issues with Arabic language and I will check them. :)**

## Requirements

## Installation


Just add `pod 'PrayerTimesSwift'` to your Podfile and go!
PrayerTimesSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PrayerTimesSwift"
```

Then run `pod install`


### Create an `PrayerTime`
You will need to create a new instance of `PrayerTime`. Once the instance are configured, you can call `getPrayerTimes()`.

```swift
let myPrayerTime = PrayerTimes(caculationmethod: .Makkah, asrJuristic: .Shafii, adjustHighLats: .None, timeFormat: .Time12)
let prayerTimes = myPrayerTime.getPrayerTimes(NSCalendar.currentCalendar(), latitude: 24.7993689, longitude: 
```


### Configurations
* `TimeFormat` To change the time format to:
	* `Time24`  24-hour format
	* `Time12`  12-hour format
	* `Time12NS`  12-hour format with no suffix
	* `Floating`  floating point number
```swift
myPrayerTime.timeFormat = .time24
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
 myPrayerTime.Caculationmethod = .makkah
```
* `AsrJuristic` To change Juristic Method for Asr
	* `Shafii`  Shafii (standard)
	* `Hanafi`  Hanafi
```swift
myPrayerTime.asrJuristic = .shafii
```
* `AdjustHighLats` Adjusting Methods for Higher Latitudes
	* `None`  No adjustment
	* `MidNight`  middle of night
	* `OneSeventh`  1/7th of night
	* `AngleBased`  angle/60th of night
```swift
myPrayerTime.adjustHighLats = .none
```
* `tuneTimes` Tune timings for adjustments
```swift
        myPrayerTime.tuneTimes([0,0,0,0,0,0,0])
```



## Author

Abdullah Alhazmy

## Credits
[Praytimes](http://praytimes.org)


## License

PrayerTimesSwift is available under the MIT license. See the LICENSE file for more info.
