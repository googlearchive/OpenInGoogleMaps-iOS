//
//  OpenInGoogleMapsController.m
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

#import <CoreLocation/CoreLocation.h>
#import "OpenInGoogleMapsController.h"

// Constants for URL schemes and arguments defined by Google Maps and Chrome.
static NSString * const kGoogleMapsScheme = @"comgooglemaps://";
static NSString * const kGoogleMapsCallbackScheme = @"comgooglemaps-x-callback://";
static NSString* const kGoogleChromeOpenLink =
    @"googlechrome-x-callback://x-callback-url/open/?url=";

static NSString * const kGoogleMapsStringTraffic = @"traffic";
static NSString * const kGoogleMapsStringTransit = @"transit";
static NSString * const kGoogleMapsStringSatellite = @"satellite";

/*
 * Helper method that percent-escapes a string so it can safely be used in a URL.
 */
static NSString *encodeByAddingPercentEscapes(NSString *input) {
  NSString *encodedValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
      kCFAllocatorDefault, (CFStringRef) input, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]",
      kCFStringEncodingUTF8));
  return encodedValue;
}

/*
 * The GoogleMapsURLSchemable protocol states that any definition can be exported into an
 * array of URL arguments that can then be used to open Google Maps, Apple Maps, or a web page.
 * It's through these methods that the definitions do most of the "heavy lifting" required to
 * convert themselves into a URL that can be opened in the appropriate app.
 *
 * The first three methods return arrays of strings that represent URL arguments in the form of
 * "foo=bar". These can then by joined by ampersands (and prepended by a question mark) to create
 * a full URL.
 */
@protocol GoogleMapsURLSchemable
@required
- (NSArray *)URLArgumentsForGoogleMaps;
- (NSArray *)URLArgumentsForAppleMaps;
- (NSArray *)URLArgumentsForWeb;
- (BOOL)anythingToSearchFor;
@end

/*
 * GoogleMapDefinition - A definition for opening up a location in a map.
 */
@interface GoogleMapDefinition() <GoogleMapsURLSchemable>
@end


@implementation GoogleMapDefinition
- (instancetype)init {
  self = [super init];
  if (self) {
    _center = kCLLocationCoordinate2DInvalid;
  }
  return self;
}


- (BOOL)anythingToSearchFor {
  return (CLLocationCoordinate2DIsValid(self.center) || self.queryString);
}


- (NSArray *)URLArgumentsForGoogleMaps {
  NSMutableArray *urlArguments = [NSMutableArray array];
  if (self.queryString) {
    [urlArguments addObject:
            [NSString stringWithFormat:@"q=%@", encodeByAddingPercentEscapes(self.queryString)]];
  }

  if (CLLocationCoordinate2DIsValid(self.center)) {
    [urlArguments addObject:[NSString stringWithFormat:@"center=%f,%f",
        self.center.latitude, self.center.longitude]];
  }
  if (self.zoomLevel > 0) {
    [urlArguments addObject:[NSString stringWithFormat:@"zoom=%f", self.zoomLevel]];
  }
  if (self.viewOptions) {
    NSMutableArray *viewsToShow = [NSMutableArray arrayWithCapacity:3];
    if (self.viewOptions & kGoogleMapsViewOptionSatellite) {
      [viewsToShow addObject:kGoogleMapsStringSatellite];
    }
    if (self.viewOptions & kGoogleMapsViewOptionTraffic) {
      [viewsToShow addObject:kGoogleMapsStringTraffic];
    }
    if (self.viewOptions & kGoogleMapsViewOptionTransit) {
      [viewsToShow addObject:kGoogleMapsStringTransit];
    }
    [urlArguments addObject:
            [NSString stringWithFormat:@"views=%@", [viewsToShow componentsJoinedByString:@","]]];
  }
  return urlArguments;
}

- (NSArray *)URLArgumentsForAppleMaps {
  NSMutableArray *urlArguments = [NSMutableArray array];
  if (self.queryString) {
    [urlArguments addObject:
            [NSString stringWithFormat:@"q=%@", encodeByAddingPercentEscapes(self.queryString)]];
  }
  if (CLLocationCoordinate2DIsValid(self.center)) {
    [urlArguments addObject:[NSString stringWithFormat:@"ll=%f,%f",
        self.center.latitude, self.center.longitude]];
  }
  if (self.zoomLevel > 0) {
    [urlArguments addObject:[NSString stringWithFormat:@"z=%d", (int)self.zoomLevel]];
  }
  // Apple Map's "Hybrid" view is closest to what Google's "Satellite" view looks like
  if (self.viewOptions & kGoogleMapsViewOptionSatellite) {
    [urlArguments addObject:@"t=h"];
  }
  // TODO: Figure out what URL scheme argument enables traffic information.

  return urlArguments;
}

- (NSArray *)URLArgumentsForWeb {
  NSMutableArray *urlArguments = [NSMutableArray array];
  if (self.queryString) {
    [urlArguments addObject:
            [NSString stringWithFormat:@"q=%@", encodeByAddingPercentEscapes(self.queryString)]];
  }
  if (CLLocationCoordinate2DIsValid(self.center)) {
    [urlArguments addObject:[NSString stringWithFormat:@"ll=%f,%f",
        self.center.latitude, self.center.longitude]];
  }
  if (self.zoomLevel > 0) {
    [urlArguments addObject:[NSString stringWithFormat:@"z=%d", (int)self.zoomLevel]];
  }
  if (self.viewOptions & kGoogleMapsViewOptionSatellite) {
    [urlArguments addObject:@"t=h"];
  }
  if (self.viewOptions & kGoogleMapsViewOptionTraffic) {
    [urlArguments addObject:@"layer=t"];
  }

  if (self.viewOptions & kGoogleMapsViewOptionTransit) {
    [urlArguments addObject:@"lci=transit_comp"];
  }

  return urlArguments;
}

@end

/*
 * GoogleStreetViewDefinition - A definition for opening up a location in Street View.
 */

@interface GoogleStreetViewDefinition() <GoogleMapsURLSchemable>
@end

@implementation GoogleStreetViewDefinition
- (instancetype)init {
  self = [super init];
  if (self) {
    _center = kCLLocationCoordinate2DInvalid;
  }
  return self;
}

- (BOOL)anythingToSearchFor {
  return CLLocationCoordinate2DIsValid(self.center);
}

- (NSArray *)URLArgumentsForGoogleMaps {
  NSMutableArray *urlArguments = [NSMutableArray array];
  [urlArguments addObject:
          [NSString stringWithFormat:@"center=%f,%f", self.center.latitude, self.center.longitude]];
  [urlArguments addObject:@"mapmode=streetview"];
  return urlArguments;
}

/*
 * Apple Maps doesn't support Street View, but we can zoom in to the general location with
 * satellite view. That's pretty close.
 */
- (NSArray *)URLArgumentsForAppleMaps {
  NSMutableArray *urlArguments = [NSMutableArray array];


  [urlArguments addObject:
          [NSString stringWithFormat:@"ll=%f,%f", self.center.latitude, self.center.longitude]];
  [urlArguments addObject:@"z=19"];
  [urlArguments addObject:@"t=k"];
  return urlArguments;
}

/*
 * Currently, we are unable to open a link to Street View in our mobile web browser. But we
 * can zoom in with satellite view just like we do in Apple Maps
 */
- (NSArray *)URLArgumentsForWeb {
  return [self URLArgumentsForAppleMaps];
}


@end

/*
 * GoogleDirectionsWaypoint - A point defined by either a set of coordinates or a search string.
 * Used by the GoogleDirectionsDefinition classs.
 */
@interface GoogleDirectionsWaypoint()
@end

@implementation GoogleDirectionsWaypoint
- (instancetype)init {
  self = [super init];
  if (self) {
    _location = kCLLocationCoordinate2DInvalid;
  }
  return self;
}

/*
 * Since waypoints should contain a location or a query string (but not both),
 * these static helper methods can be quite handy.
 */
+ (instancetype)waypointWithLocation:(CLLocationCoordinate2D)location {
  GoogleDirectionsWaypoint *waypoint = [[GoogleDirectionsWaypoint alloc] init];
  waypoint.location = location;
  return waypoint;
}

+ (instancetype)waypointWithQuery:(NSString *)queryString {
  GoogleDirectionsWaypoint *waypoint = [[GoogleDirectionsWaypoint alloc] init];
  waypoint.queryString = queryString;
  return waypoint;
}

- (BOOL)anythingToSearchFor {
  return (CLLocationCoordinate2DIsValid(self.location) || self.queryString);
}

/*
 * Since a waypoint could be the start address ('saddr' in the URL) or the end address ('daddr'),
 * we need to pass in the proper key when retrieving the URL argument for this waypoint.
 */
- (NSString *)URLArgumentUsingKey:(NSString *)key {
  if (CLLocationCoordinate2DIsValid(self.location)) {
    return [NSString stringWithFormat:@"%@=%f,%f",
        key, self.location.latitude, self.location.longitude];
  } else if (self.queryString) {
    return [NSString stringWithFormat:@"%@=%@",
        key, encodeByAddingPercentEscapes(self.queryString)];
  } else {
    return @"";
  }
}

@end

/*
 * GoogleDirectionsWaypoint - A point defined by either a set of coordinates or a search string.
 * Used by the GoogleDirectionsDefinition classs.
 */
@interface GoogleDirectionsDefinition() <GoogleMapsURLSchemable>
@end

@implementation GoogleDirectionsDefinition

- (BOOL)anythingToSearchFor {
  return ([self.startingPoint anythingToSearchFor] || [self.destinationPoint anythingToSearchFor]);
}

/*
 * Retrieving the "travel mode" argument in Google Maps.
 */
- (NSString *)urlArgumentValueForTravelMode {
  switch (self.travelMode) {
    case kGoogleMapsTravelModeBiking:
      return @"bicycling";
    case kGoogleMapsTravelModeDriving:
      return @"driving";
    case kGoogleMapsTravelModeTransit:
      return @"transit";
    case kGoogleMapsTravelModeWalking:
      return @"walking";
  }
  return nil;
}

/*
 * Retrieving the "travel mode" argument for the web.
 */
- (NSString *)urlArgumentValueForTravelModeWeb {
  switch (self.travelMode) {
    case kGoogleMapsTravelModeBiking:
      return @"b";
    case kGoogleMapsTravelModeDriving:
      return @"c";
    case kGoogleMapsTravelModeTransit:
      return @"r";
    case kGoogleMapsTravelModeWalking:
      return @"w";
  }
  return nil;
}

/*
 * Retrieving the start and end waypoint arguments is the same in Google Maps, Apple Maps, and
 * the web.
 */
- (NSMutableArray *)waypointArguments {
  NSMutableArray *waypointArguments = [NSMutableArray array];
  if ([self.startingPoint anythingToSearchFor]) {
    [waypointArguments addObject:[self.startingPoint URLArgumentUsingKey:@"saddr"]];
  }
  if ([self.destinationPoint anythingToSearchFor]) {
    [waypointArguments addObject:[self.destinationPoint URLArgumentUsingKey:@"daddr"]];
  }
  return waypointArguments;
}

- (NSArray *)URLArgumentsForGoogleMaps {
  NSMutableArray *urlArguments = [self waypointArguments];

  NSString *travelMode = [self urlArgumentValueForTravelMode];
  if (travelMode) {
    [urlArguments addObject:[NSString stringWithFormat:@"directionsmode=%@", travelMode]];
  }
  return urlArguments;
}

- (NSArray *)URLArgumentsForAppleMaps {
  NSMutableArray *urlArguments = [self waypointArguments];

  if (self.travelMode == kGoogleMapsTravelModeDriving) {
    [urlArguments addObject:@"dirflg=d"];
  } else if (self.travelMode == kGoogleMapsTravelModeWalking) {
    [urlArguments addObject:@"dirflg=w"];
  }
  return urlArguments;
}

- (NSArray *)URLArgumentsForWeb {
  NSMutableArray *urlArguments = [self waypointArguments];

  NSString *travelMode = [self urlArgumentValueForTravelModeWeb];
  if (travelMode) {
    [urlArguments addObject:[NSString stringWithFormat:@"dirflg=%@", travelMode]];
  }
  return urlArguments;
}


@end

/*
 * OpenInGoogleMapsController - The main class that creates and opens a URL to display a particular
 * map in Google Maps (or an alternative application is a fallback strategy is specified).
 *
 * Most of the work required to take a definition and open it up in the proper application
 * is done by the definitions themselves. This class creates the "outer bits" of the URL (like
 * the base URL and any x-callback-url data at the end), and takes care of the logic for performing
 * the various fallback strategies.
 */

@implementation OpenInGoogleMapsController {
  UIApplication *_sharedApplication;
}

+ (OpenInGoogleMapsController *)sharedInstance {
  static OpenInGoogleMapsController *_sharedInstance;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
  });
  return _sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _sharedApplication = [UIApplication sharedApplication];
  }
  return self;
}


- (BOOL)isGoogleMapsInstalled {
  NSURL *simpleURL = [NSURL URLWithString:kGoogleMapsScheme];
  NSURL *callbackURL = [NSURL URLWithString:kGoogleMapsCallbackScheme];
  return ([_sharedApplication canOpenURL:simpleURL] ||
          [_sharedApplication canOpenURL:callbackURL]);
}



- (BOOL)fallBackToAppleMapsWithDefinition:(id<GoogleMapsURLSchemable>)definition {

  NSMutableString *mapURL = [@"https://maps.apple.com/" mutableCopy];
  [mapURL appendString:[NSString stringWithFormat:@"?%@",
      [[definition URLArgumentsForAppleMaps] componentsJoinedByString:@"&"]]];
#if DEBUG
  NSLog(@"Opening up URL: %@", mapURL);
#endif
  NSURL *URLToOpen = [NSURL URLWithString:mapURL];

  return [_sharedApplication openURL:URLToOpen];
}


- (BOOL)fallbackToChromeFirstWithDefinition:(id<GoogleMapsURLSchemable>)definition {
  NSMutableString *mapURL = [kGoogleChromeOpenLink mutableCopy];

  NSString *embedURL = @"https://maps.google.com/maps/";
  NSString *urlArgumentsAsString = [NSString stringWithFormat:@"?%@",
      [[definition URLArgumentsForWeb] componentsJoinedByString:@"&"]];

  NSString *fullEmbedURL = [embedURL stringByAppendingString:urlArgumentsAsString];
  [mapURL appendString:encodeByAddingPercentEscapes(fullEmbedURL)];
#if DEBUG
  NSLog(@"Opening up URL: %@", mapURL);
  NSLog(@"Embedded URL of: %@", fullEmbedURL);
#endif
  [self appendMapURLString:mapURL withCallbackArgumentsFromURL:self.callbackURL];

  NSURL *URLToOpen = [NSURL URLWithString:mapURL];
  if ([_sharedApplication openURL:URLToOpen]) {
    return YES;
  } else if (self.fallbackStrategy == kGoogleMapsFallbackChromeThenAppleMaps) {
    return [self fallBackToAppleMapsWithDefinition:definition];
  } else if (self.fallbackStrategy == kGoogleMapsFallbackChromeThenSafari) {
    return [self fallbackToSafariWithDefinition:definition];
  }
  return NO;
}


- (BOOL)fallbackToSafariWithDefinition:(id<GoogleMapsURLSchemable>)definition {
  NSMutableString *mapURL = [@"https://maps.google.com/maps" mutableCopy];

  [mapURL appendString:[NSString stringWithFormat:@"?%@",
      [[definition URLArgumentsForWeb] componentsJoinedByString:@"&"]]];
#if DEBUG
  NSLog(@"Opening up URL: %@", mapURL);
#endif
  NSURL *URLToOpen = [NSURL URLWithString:mapURL];
  return [_sharedApplication openURL:URLToOpen];
}


/*
 * Since the definitions themselves do most of the work required to generate the URL arguments
 * appropriate for their type of map request, the same method can be used to open up the correct
 * URL, no matter what definition gets passed in. We chose not to make this method public,
 * simply because the more explicit methods below eliminate potential confusion.
 */
- (BOOL)openInGoogleMapsWithDefinition:(id<GoogleMapsURLSchemable>)definition {
  // Did we define anything to search for in our map?
  if (![definition anythingToSearchFor]) {
    return NO;
  }

  // Can we open this in google maps?
  if (![self isGoogleMapsInstalled]) {
    switch (self.fallbackStrategy) {
      case kGoogleMapsFallbackNone:
        return NO;
      case kGoogleMapsFallbackAppleMaps:
        return [self fallBackToAppleMapsWithDefinition:definition];
      case kGoogleMapsFallbackChromeThenSafari:
      case kGoogleMapsFallbackChromeThenAppleMaps:
        return [self fallbackToChromeFirstWithDefinition:definition];
      case kGoogleMapsFallbackSafari:
        return [self fallbackToSafariWithDefinition:definition];
    }
  }

  NSMutableString *mapURL = [[self baseURLStringUsingCallback:self.callbackURL] mutableCopy];

  [mapURL appendString:[NSString stringWithFormat:@"?%@",
      [[definition URLArgumentsForGoogleMaps] componentsJoinedByString:@"&"]]];
  [self appendMapURLString:mapURL withCallbackArgumentsFromURL:self.callbackURL];
#if DEBUG
  NSLog(@"Opening up URL: %@", mapURL);
#endif
  NSURL *URLToOpen = [NSURL URLWithString:mapURL];

  return [_sharedApplication openURL:URLToOpen];
}


- (BOOL)openMap:(GoogleMapDefinition *)definition {
  return [self openInGoogleMapsWithDefinition:definition];
}

- (BOOL)openStreetView:(GoogleStreetViewDefinition *)definition {
  return [self openInGoogleMapsWithDefinition:definition];
}

- (BOOL)openDirections:(GoogleDirectionsDefinition *)definition {
  return [self openInGoogleMapsWithDefinition:definition];
}


# pragma mark - Map URL fragment methods

/*
 * Returns the correct URL scheme (comgooglemaps vs comgooglemaps-x-callback),
 * depending on whether or not the callback URL can be opened.
 */
- (NSString *)baseURLStringUsingCallback:(NSURL *)callbackURL {
  BOOL usingCallback = callbackURL && [_sharedApplication canOpenURL:callbackURL];
  return (usingCallback) ? kGoogleMapsCallbackScheme : kGoogleMapsScheme;
}

/*
 * Add the x-success and x-source arguments to the end of an URL string, if the callback URL
 * exists and is supported by the target app.
 */
- (void)appendMapURLString:(NSMutableString *)mapURL
    withCallbackArgumentsFromURL:(NSURL *)callbackURL {
  BOOL usingCallback = callbackURL && [_sharedApplication canOpenURL:callbackURL];
  if (usingCallback) {
    [mapURL appendFormat:@"&x-success=%@",
        encodeByAddingPercentEscapes([callbackURL absoluteString])];
    [mapURL appendFormat:@"&x-source=%@",
        encodeByAddingPercentEscapes(
            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"])];
  }
}


@end
