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

/**
 *  Options for some of the views you can toggle in Google Maps.
 */
typedef NS_OPTIONS(NSInteger, GoogleMapsViewOptions){
  /**
   *  Satellite view.
   */
  kGoogleMapsViewOptionSatellite = 1 << 0,
  /**
   *  Show traffic information.
   */
  kGoogleMapsViewOptionTraffic = 1 << 1,
  /**
   *  Show public transit routes.
   */
  kGoogleMapsViewOptionTransit = 1 << 2
};

/**
 *  Defines the  method by which the user would like to travel when creating directions.
 */
typedef NS_ENUM(NSInteger, GoogleMapsTravelMode){
  /**
   *  Driving
   */
  kGoogleMapsTravelModeDriving = 1,
  /**
   *  Public transit
   */
  kGoogleMapsTravelModeTransit,
  /**
   *  Biking
   */
  kGoogleMapsTravelModeBiking,
  /**
   *  Walking
   */
  kGoogleMapsTravelModeWalking
};

/**
 *  Fallback strategies for what to show if the user doesn't have Google Maps installed.
 */
typedef NS_ENUM(NSInteger, GoogleMapsFallback){
  /**
   *  Do nothing else, and return NO. This is the default option.
   */
  kGoogleMapsFallbackNone,
  /**
   *  Show the map in Apple's Maps app instead. Choose this option if you'd prefer to use a native
   *  app at all times.
   */
  kGoogleMapsFallbackAppleMaps,
  /**
   *  Show the map in Chrome, if available. Otherwise display the map in Google Maps within Safari.
   *  Choose this option if it's important that the map you view is based on Google's map data.
   */
  kGoogleMapsFallbackChromeThenSafari,
  /**
   *  Show the map in Chrome, if available. Otherwise display the map in Apple's Maps app. Choose
   *  this option if you'd prefer apps that can point back to your application using the 
   *  `x-callback-url` standard.
   */
  kGoogleMapsFallbackChromeThenAppleMaps,
  /**
   *  Show the map in Google Maps in the Safari browser.
   */
  kGoogleMapsFallbackSafari
};

/**
 * Helper class used to define a map to be opened in Google Maps. Note that there's a good chance
 * some of these properties will be nil, but either the `queryString` or the `center` property 
 * should be set.
 */
@interface GoogleMapDefinition : NSObject

/**
 *  A query string which, if set, will be used to search for a place by name.
 */
@property(nonatomic, copy) NSString *queryString;

/**
 *  Location in lat/long. If both this and the `queryString` are specified, this will be used as a
 *  center for the search.
 *  To clear this value, set it to `kCLLocationCoordinate2DInvalid`.
 */
@property(nonatomic, assign) CLLocationCoordinate2D center;

/**
 *  Bitwise ORs of different viewing options to display in the Google Maps application.
 *
 *  @see GoogleMapsViewOptions
 */
@property(nonatomic, assign) GoogleMapsViewOptions viewOptions;

/**
 *  Zoom level. Currently, Google Maps clamps this value from 0.0 (to show the whole Earth) to 21.0.
 */
@property(nonatomic, assign) float zoomLevel;

@end

/**
 *  Helper class used to define a Street View location to be opened in Google Maps,
 *  Currently, this class is a subset of GoogleMapDefinition, but we're keeping these two classes
 *  separate in case they diverge in the future.
 */
@interface GoogleStreetViewDefinition : NSObject

/**
 *  Location in lat/long. This is currently the only way you can define a Street View location.
 */
@property(nonatomic, assign) CLLocationCoordinate2D center;

@end


/**
 *  A class used to define a waypoint for directions.
 */
@interface GoogleDirectionsWaypoint: NSObject

/**
 *  Class helper method to create a waypoint with a search query.
 *
 *  @param queryString Query string for the waypoint.
 *
 *  @return A waypoint to be used in a GoogleDirectionsDefinition object.
 */
+ (instancetype)waypointWithQuery:(NSString *)queryString;

/**
 *  Class helper method to create a waypoint with a coordinate location.
 *
 *  @param location A coodinate in lat/long for the waypoint.
 *
 *  @return A waypoint to be used in a GoogleDirectionsDefinition object.
 */
+ (instancetype)waypointWithLocation:(CLLocationCoordinate2D)location;

/**
 *  Lat/long of start or end location. If this is set and not equal to
 *  `kCLLocationCoordinate2DInvalid`, it takes precedence over `queryString`.
 */
@property(nonatomic, assign) CLLocationCoordinate2D location;

/**
 *  Query string to use to determine this waypoint. For best results, use unambiguous strings 
 *  such as addresses ("355 Main Street, Cambridge, MA") or business search queries with unique
 *  results ("The Exploratorium, San Francisco CA").
 */
@property(nonatomic, copy) NSString *queryString;

@end


/**
 *  Helper class used to define two waypoints from which to create a set of directions in Google
 *  Maps. Either the starting point or the destination must be non-nil in order to produce a
 *  valid request.
 */
@interface GoogleDirectionsDefinition : NSObject

/**
 *  Starting point. If this is set to `nil`, we will start at the user's current location.
 * 
 *  @see GoogleDirectionsWaypoint
 */
@property(nonatomic, strong) GoogleDirectionsWaypoint *startingPoint;

/**
 *  Destination. If this is set to `nil`, we will end at the user's current location.
 *
 *  @see GoogleDirectionsWaypoint
 */
@property(nonatomic, strong) GoogleDirectionsWaypoint *destinationPoint;

/**
 *  Method of transportation for which to provide directions. If the application opened does not
 *  support this travel type, it will fall back to providing driving directions.
 *
 * @see GoogleMapsTravelMode
 */
@property(nonatomic, assign) GoogleMapsTravelMode travelMode;

@end

/**

 The `OpenInGoogleMapsController` class is designed to make it easy for an iOS developer to open a
 map, show a Street View location, or show a set of directions directly in Google Maps. The class
 supports using the `x-callback-URL` standard so that you can add a "Back to _my app_" button
 directly within Google Maps, and supports a number of fallback strategies, so that you can
 automatically open the map in another application if the user does not have Google Maps installed.
 */
@interface OpenInGoogleMapsController : NSObject

/**
 *  Singleton method. Use this for making any calls against the `OpenInGoogleMapsController` class.
 *
 *  @return Returns the shared singleton instance.
 */
+ (OpenInGoogleMapsController *)sharedInstance;

/**
 *  The callback URL that you want Google maps (or Google Chrome) to use to redirect back to your 
 *  application. If `x-callback-url` is not supported, this will not be used and Google Maps will
 *  be opened with a simple `comgooglemaps:` call instead.
 *  See the Google Maps URL scheme documentation for more information about `x-callback-url` 
 *  support.
 */
@property(nonatomic, strong) NSURL *callbackURL;

/**
 *  Determines what to do if the user does not have Google Maps. You only need to set the
 *  fallback strategy once during the lifetime of your application and it will be used in all future
 *  `OpenInGoogleMapsController` requests.
 *  @see GoogleMapsFallback
 */
@property(nonatomic, assign) GoogleMapsFallback fallbackStrategy;

/**
 *  Evaluates to `YES` if Google Mpas is installed, `NO` otherwise.
 */
@property(nonatomic, readonly, getter=isGoogleMapsInstalled) BOOL googleMapsInstalled;

/**
 *  Opens a map with the characteristics specified in the `GoogleMapDefinition `in Google Maps.
 *
 *  @param definition A `GoogleMapDefinition` for the map you would like to open.
 *
 *  @return Returns `YES` if it was succesfully able to open the map in Google Maps or one of the
 *  fallback options as specified in `fallbackStrategy`. Returns `NO` otherwise.
 */
- (BOOL)openMap:(GoogleMapDefinition *)definition;

/**
 *  Shows Street View location in Google maps.
 *
 *  @param definition A GoogleStreetViewDefinition for the location you would like to view.
 *
 *  @return Returns `YES` if it was successfully able to open the Google Maps app or one of the
 *  fallback options as specified in `fallbackStrategy`. Does _not_ guarantee that the address
 *  entered is a valid street view location.
 */
- (BOOL)openStreetView:(GoogleStreetViewDefinition *)definition;

/**
 * Show point-to-point directions in Google Maps.
 *
 * @param definition A GoogleDirectionsDefinition for the location you would like to view.
 *
 * @return Returns `YES` if it was successfully able to open the Google Maps app or one of the
 * fallback options as specified in `fallbackStrategy`. Does _not_ guarantee that the directions
 * request is a valid one, or that directions were found.
 */
- (BOOL)openDirections:(GoogleDirectionsDefinition *)definition;


@end

