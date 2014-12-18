//
//  MapRequestModel.m
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

#import "MapRequestModel.h"

@implementation MapRequestModel {
  NSDictionary *_travelModeDescriptions;
}

- (instancetype)init {
  if (self = [super init]) {
    _travelModeDescriptions = @{
      @(kTravelModeNotSpecified): @"(Unspecified)",
      @(kTravelModeDriving): @"Driving",
      @(kTravelModePublicTransit): @"Transit",
      @(kTravelModeBicycling): @"Biking",
      @(kTravelModeWalking): @"Walking"
    };
    _travelMode = kTravelModeNotSpecified;
    _startLocation = kCLLocationCoordinate2DInvalid;
    _desstinationLocation = kCLLocationCoordinate2DInvalid;
  }
  return self;
}

- (void)setQueryString:(NSString *)query
                center:(CLLocationCoordinate2D)center
              forGroup:(LocationGroup)group {
  if (group == kLocationGroupStart) {
    _startCurrentLocation = NO;
    _startQueryString = [query copy];
    _startLocation = center;
  } else if (group == kLocationGroupEnd) {
    _destinationCurrentLocation = NO;
    _destinationQueryString = [query copy];
    _desstinationLocation = center;
  }
}

- (void)setQueryString:(NSString *)query forGroup:(LocationGroup)group {
  [self setQueryString:query center:kCLLocationCoordinate2DInvalid forGroup:group];
}


- (void)useCurrentLocationForGroup:(LocationGroup)group {
  // Nil out everything else and just use our current location
  if (group == kLocationGroupStart) {
    _startQueryString = nil;
    _startLocation = kCLLocationCoordinate2DInvalid;
    _startCurrentLocation = YES;
  } else if (group == kLocationGroupEnd) {
    _destinationQueryString = nil;
    _desstinationLocation = kCLLocationCoordinate2DInvalid;
    _destinationCurrentLocation = YES;
  }
}

- (NSString *)descriptionForGroup:(LocationGroup)group {
  if (group == kLocationGroupStart) {
    return [self makeDescriptionForSearch:_startQueryString
                             withLocation:_startLocation
                     usingCurrentLocation:_startCurrentLocation];
  } else {
    return [self makeDescriptionForSearch:_destinationQueryString
                             withLocation:_desstinationLocation
                     usingCurrentLocation:_destinationCurrentLocation];
  }
}

- (NSArray *)sortedTravelModeDescriptions {
  NSArray *sortedKeys =
      [[_travelModeDescriptions allKeys] sortedArrayUsingSelector:@selector(compare:)];
  NSArray *valuesFromSortedKeys =
      [_travelModeDescriptions objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
  return valuesFromSortedKeys;
}

- (NSString *)makeDescriptionForSearch:(NSString *)searchString
                          withLocation:(CLLocationCoordinate2D)location
                  usingCurrentLocation:(BOOL)currentLocation {
  BOOL isLocationValid = CLLocationCoordinate2DIsValid(location);
  if (searchString == nil && !isLocationValid && currentLocation == NO) {
    return @"-- Location not set --";
  } else if (currentLocation) {
    return @"(Current Location)";
  } else if (searchString != nil && !isLocationValid) {
    return searchString;
  } else if (searchString == nil && isLocationValid) {
    return [NSString stringWithFormat:@"Lat: %.4f, Long: %.4f",
        location.latitude, location.longitude];
  } else {
    return [NSString stringWithFormat:@"%@ near (%.2f, %.2f)",
        searchString, location.latitude, location.longitude];
  }
}

- (NSString *)travelModeDescription {
  return [_travelModeDescriptions objectForKey:@(self.travelMode)];
}


@end

