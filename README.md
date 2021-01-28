# CLAPMStatusMenu

[![CI Status](https://img.shields.io/travis/lixiang/CLAPMStatusMenu.svg?style=flat)](https://travis-ci.org/lixiang/CLAPMStatusMenu)
[![Version](https://img.shields.io/cocoapods/v/CLAPMStatusMenu.svg?style=flat)](https://cocoapods.org/pods/CLAPMStatusMenu)
[![License](https://img.shields.io/cocoapods/l/CLAPMStatusMenu.svg?style=flat)](https://cocoapods.org/pods/CLAPMStatusMenu)
[![Platform](https://img.shields.io/cocoapods/p/CLAPMStatusMenu.svg?style=flat)](https://cocoapods.org/pods/CLAPMStatusMenu)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CLAPMStatusMenu is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CLAPMStatusMenu'
```

## Usage

#### Objective-C
```
[CLAPMMonitor startMonitoring];
[CLAPMStatusMenu showInWindow: UIApplication.sharedApplication.keyWindow];
```

#### Swift
```
CLAPMMonitor.startMonitoring()
CLAPMStatusMenu.show(in: UIApplication.shared.keyWindow!)
```

## Author

cleexiang, cleexiang@126.com

## License

CLAPMStatusMenu is available under the MIT license. See the LICENSE file for more info.
