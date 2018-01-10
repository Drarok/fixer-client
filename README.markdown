# Fixer Currency Converter Client

This is an example iOS client for the [Fixer][fixer] currency conversion API.

## Quick Start

You will need [CocoaPods][cocoapods] installed and set up.

1. `git clone https://github.com/Drarok/fixer-client.git`
2. `cd fixer-client`
3. `pod install`
4. `open Fixer.xcworkspace`

You should now be able to compile and run the project.

## Features

When the app lauches, you are presented with an interface showing two currencies. Tapping the "Add" button in the top-right corner allows you to add more currencies to the list. Only items that aren't currently added are shown to the user.

When typing, all _other_ currencies displayed are updated in real-time.

Tapping the date row will present a new section containing a date picker (similar to how the built-in Calendar app presents date selections). Changing the date will make a request to the API for the currency rates for that date. If the API returns a different date (which is is known to to, presumably when it doesn't have data for a particular date), the picker is updated to reflect the data.

The app is built using AutoLayout, and functions in landscape mode.

## Known Issues

Whilst the user can only add currencies to the list that aren't already present, they _can_ change them to the same currency as another one in the list.

The hit targets in the currency cells make it a little hard to scroll in the simulator.

The number entered by the user is stored internally as EUR, so when the date is changed, all currencies (except for EUR) are updated.

The app has only been tested on iOS 11.2.

[fixer]: https://github.com/hakanensari/fixer
[cocoapods]: https://cocoapods.org
