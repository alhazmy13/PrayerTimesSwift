<p align="center">
  <img src="https://cloud.githubusercontent.com/assets/4659608/12704381/cc10b62a-c86a-11e5-9624-6cdb12ea1e74.png">
</p>

# PrayerTimesSwift

[![Version](https://img.shields.io/cocoapods/v/PrayerTimesSwift.svg?style=flat)](https://cocoapods.org/pods/PrayerTimesSwift)
[![License](https://img.shields.io/cocoapods/l/PrayerTimesSwift.svg?style=flat)](https://cocoapods.org/pods/PrayerTimesSwift)
[![Platform](https://img.shields.io/cocoapods/p/PrayerTimesSwift.svg?style=flat)](https://cocoapods.org/pods/PrayerTimesSwift)

Prayer Times provides a set of handy functions to calculate prayer times for any location around the world, based on a variety of calculation methods currently used in Muslim communities.

You can report any issue on issues page. **Note: If you speak Arabic, you can submit issues with Arabic language and I will check them. :)**

## Requirements

## Installation

Just add this line to your Podfile 

```ruby
pod 'PrayerTimesSwift'
```
Now  run `pod install`

### Create an `PrayerTime`
You will need to create a new instance of `PrayerTime`. Once the instance are configured, you can call `getPrayerTimes()`.

```swift
let myPrayerTime = PrayerTimes(caculationMethod: .makkah, asrJuristic: .shafii, adjustHighLats: .none, timeFormat: .time12)
let prayerTimes = myPrayerTime.getPrayerTimes(date: .current, latitude: 24.7136, longitude: 46.6753, tZone: 3) 
```

### Configurations
* `TimeFormat` To change the time format to:
	* `time24`  24-hour format
	* `time12`  12-hour format
	* `time12NS`  12-hour format with no suffix
	* `floating`  floating point number
```swift
myPrayerTime.timeFormat = .time24
```
* `Caculationmethod` To change the Calculation Methods.
	* `karachi`  University of Islamic Sciences, Karachi
	* `isna`  Islamic Society of North America (ISNA)
	* `mwl`  Muslim World League (MWL)
	* `makkah`  Umm al-Qura, Makkah
	* `egypt`  Egyptian General Authority of Survey
	* `jafari`  Ithna Ashari
	* `tehran`  Institute of Geophysics, University of Tehran
	* `custom`  Custom Setting
```swift
 myPrayerTime.caculationMethod = .makkah
```
* `AsrJuristic` To change Juristic Method for Asr
	* `shafii`  Shafii (standard)
	* `hanafi`  Hanafi
```swift
myPrayerTime.asrJuristic = .shafii
```
* `AdjustHighLats` Adjusting Methods for Higher Latitudes
	* `none`  No adjustment
	* `midNight`  middle of night
	* `oneSeventh`  1/7th of night
	* `angleBased`  angle/60th of night
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
