//
//  OpenInGoogleMapsController.h
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
//
//  For more information on using the OpenInGoogleMapsController, please refer to the README.md
//  file included with this project, or to the Google Maps URL Scheme documentation at
//  https://developers.google.com/maps/documentation/ios/urlscheme
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, GoogleMapsViewOptions) {
  kGoogleMapsViewOptionSatellite = 1 << 0,
  kGoogleMapsViewOptionTraffic = 1 << 1,
  kGoogleMapsViewOptionTransit = 1 << 2
};

typedef NS_ENUM(NSInteger, GoogleMapsTravelMode) {
  kGoogleMapsTravelModeDriving = 1,
  kGoogleMapsTravelModeTransit,
  kGoogleMapsTravelModeBiking,
  kGoogleMapsTravelModeWalking
};

typedef NS_ENUM(NSInteger, GoogleMapsFallback) {
  kGoogleMapsFallbackNone,
  kGoogleMapsFallbackAppleMaps,
  kGoogleMapsFallbackChromeThenSafari,
  kGoogleMapsFallbackChromeThenAppleMaps,
  kGoogleMapsFallbackSafari
};


// Helper class used to define a map when we open it in Google Maps, similar to a GMSCameraPosition.
// Note that there's a good chance some of these properties will be nil, but either the queryString
// or the center property should be set.
@interface GoogleMapDefinition : NSObject

// A query string which, if set, will be used to search for a place by name.
@property(nonatomic, copy) NSString *queryString;

// Location in lat/long. If both this and the query string are specified, this will be used as a
// center for the search.
// To clear this value, set it to kCLLocationCoordinate2DInvalid.
@property(nonatomic, assign) CLLocationCoordinate2D center;

// Bitwise ORs of different viewing options, as seen above.
@property(nonatomic, assign) GoogleMapsViewOptions viewOptions;

// Zoom level. Currently, Google Maps clamps this value from 0.0 (to show the whole Earth) to 21.0.
@property(nonatomic, assign) float zoomLevel;

@end

// Helper class used to define a Street View location when we open it in Google Maps,
// Currently, a subset of GoogleMapDefinition, but we're keeping them separate in case
// they diverge in the future.
@interface GoogleStreetViewDefinition : NSObject

// Location in lat/long. This is currently the only way you can display a Street View.
@property(nonatomic, assign) CLLocationCoordinate2D center;

@end


// A class used to define a waypoint for directions.
@interface GoogleDirectionsWaypoint: NSObject

// Class helper method to create a waypoint with a search query.
+ (instancetype)waypointWithQuery:(NSString *)queryString;

// Class helper method to create a waypoint with a coordinate location.
+ (instancetype)waypointWithLocation:(CLLocationCoordinate2D)location;

// Lat/long of start location. If this is set and not equal to kCLLocationCoordinate2DInvalid,
// it takes precedence over |queryString|.
@property(nonatomic, assign) CLLocationCoordinate2D location;

// String of place to search for as our start location.
@property(nonatomic, copy) NSString *queryString;

@end

// Helper class used to define two waypoints from which to create a set of directions in Google
// Maps. Either the starting point or the destination must be non-nil in order to produce a
// valid request.
@interface GoogleDirectionsDefinition : NSObject

// Starting point. If this is set to nil, we will start at the user's current location.
@property(nonatomic, strong) GoogleDirectionsWaypoint *startingPoint;

// Destination. If this is set to nil, we will end at the user's current location.
@property(nonatomic, strong) GoogleDirectionsWaypoint *destinationPoint;

// Method of transportation.
@property(nonatomic, assign) GoogleMapsTravelMode travelMode;

@end


@interface OpenInGoogleMapsController : NSObject

// Returns the shared singleton instance.
+ (OpenInGoogleMapsController *)sharedInstance;

// Set the callback URL that we'll want to use from within Google maps. If x-callback-url is not
// supported, we will default back to a plain comgooglemaps: call. See the Google Maps URL scheme
// documentation for more information about x-callback-url support.
@property(nonatomic, strong) NSURL *callbackURL;

// If the user does not have Google Maps installed, what should we do?
//  kGoogleMapsFallbackNone = Do nothing, return NO. (Default behavior)
//  kGoogleMapsFallbackAppleMaps = Open the map with Apple Maps.
//  kGoogleMapsFallbackChromeThenSafari = Open the map with Google Chrome if installed, otherwise
//    use Safari.
//  kGoogleMapsFallbackChromeThenAppleMaps = Open the map with Google Chrome if installed, otherwise
//    use Apple Maps.
//  kGoogleMapsFallbackSafari = Open the map with Safari.
@property(nonatomic, assign) GoogleMapsFallback fallbackStrategy;

// Returns YES if Google Maps is installed.
@property(nonatomic, readonly, getter=isGoogleMapsInstalled) BOOL googleMapsInstalled;

// Opens a map with the characteristics specified in the GoogleMapDefinition in Google Maps.
// Returns YES if it was succesfully able to open the map in Google Maps or one of the fallback
// options as specified in |fallbackStrategy|. Returns NO otherwise.
- (BOOL)openMap:(GoogleMapDefinition *)definition;

// Shows Street View location in Google maps.
// Returns YES if it was successfully able to open the Google Maps app or one of the fallback
// options as specified in |fallbackStrategy|. Does _not_ guarantee that the address entered is a
// valid street view location.
- (BOOL)openStreetView:(GoogleStreetViewDefinition *)definition;

// Shows Directions in Google maps.
// Returns YES if it was successfully able to open the Google Maps app or one of the fallback
// options as specified in |fallbackStrategy|. Does _not_ guarantee that the directions request
// is a valid one, or that directions were found.
- (BOOL)openDirections:(GoogleDirectionsDefinition *)definition;


@end

