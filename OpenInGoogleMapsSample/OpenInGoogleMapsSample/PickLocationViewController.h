//
//  PickLocationViewController.h
//  OpenInGoogleMapsSample
//
//  Copyright 2014 Google Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "Enums.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@class PickLocationViewController;

// The PickLocationDelegate is used to tell the ViewController what location the user ended
// up searching for.
@protocol PickLocationDelegate<NSObject>
// The user specified only a search string. (e.g. "425 Main Street")
- (void)pickLocationController:(PickLocationViewController *)controller
             pickedQueryString:(NSString *)query
                      forGroup:(LocationGroup)group;
// The user specified only a set of coordinates.
- (void)pickLocationController:(PickLocationViewController *)controller
                pickedLocation:(CLLocationCoordinate2D)location
                      forGroup:(LocationGroup)group;
// The user specified a search string and set of coordinates. (e.g. "Ice cream near
// 37.7579691, -122.3880665")
- (void)pickLocationController:(PickLocationViewController *)controller
             pickedQueryString:(NSString *)query
                      location:(CLLocationCoordinate2D)location
                      forGroup:(LocationGroup)group;
// The user turned on the "Use current location" switch.
- (void)pickLocationController:(PickLocationViewController *)controller
    pickedCurrentLocationForGroup:(LocationGroup)group;
// The user didn't pick anything, so leave the current values unchanged.
- (void)noLocationPickedByPickLocationController:(PickLocationViewController *)controller;
@end

@interface PickLocationViewController : UIViewController
// The location group we are specifying a location for.
@property(nonatomic, assign) LocationGroup group;
@property(nonatomic, weak) id<PickLocationDelegate> delegate;
// Should we allow the "use current location" switch? Currently used only when searching for
// directions.
@property(nonatomic, assign) BOOL allowCurrentLocation;
@end

