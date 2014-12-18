//
//  MapRequestModel.h
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
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// This is an object that represents our request for a map, directions, or Street View location. We
// intentionally chose not to re-use the definitions or enums in the OpenInGoogleMapsController to
// keep things not quite as tighly coupled.
@interface MapRequestModel : NSObject
@property(nonatomic, copy, readonly) NSString *startQueryString;
@property(nonatomic, assign, readonly) CLLocationCoordinate2D startLocation;
// Whether to use the "user's current location" as the start location.
@property(nonatomic, assign, readonly, getter=isStartCurrentLocation) BOOL startCurrentLocation;
@property(nonatomic, copy, readonly) NSString *destinationQueryString;
@property(nonatomic, assign, readonly) CLLocationCoordinate2D desstinationLocation;
@property(nonatomic, assign, readonly, getter=isDestinationCurrentLocation)
    BOOL destinationCurrentLocation;
@property(nonatomic, assign) TravelMode travelMode;

// Set only the text search for a beginning or end location group. For example, "4 Main Street,
// Anytown USA".
// |group| in these methods is a LocationGroup enum to specify whether we're setting our start
// location or destination. The destination group is only used when getting directions.
- (void)setQueryString:(NSString *)query forGroup:(LocationGroup)group;

// Set a text search for a location group along with a latitude and longitude. Text group
// can be nil (when specifying a specific coordinate, useful for Street View) or they can be
// combined, as in "Ice cream near 37.7579691, -122.3880665"
- (void)setQueryString:(NSString *)query
                center:(CLLocationCoordinate2D)center
              forGroup:(LocationGroup)group;

// Set the beginning or end location to be "The user's current location". Used only in directions.
- (void)useCurrentLocationForGroup:(LocationGroup)group;

// Retrieves a text description of the search currently set for the location group.
- (NSString *)descriptionForGroup:(LocationGroup)group;

// Get string descriptions of the different travel modes, sorted by the enum values they
// represent.
- (NSArray *)sortedTravelModeDescriptions;

// Get a text version of the "travelMode" property.
- (NSString *)travelModeDescription;
@end

