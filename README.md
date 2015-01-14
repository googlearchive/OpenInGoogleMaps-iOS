#OpenInGoogleMapsController

The `OpenInGoogleMapsController` class is designed to make it easy for an iOS developer to open a map, show a Street View location, or show a set of directions directly in Google Maps. The class supports using the `x-callback-URL` standard so that you can add a "Back to _my app_" button directly within Google Maps, and supports a number of fallback strategies, so that you can automatically open the map in another application if the user does not have Google Maps installed.

##About the Google Maps URL Scheme
The `OpenInGoogleMapsController` class makes use of the Google Maps URL Scheme. If you want to understand how the class works under the hood, we highly recommend reading the [URL Scheme documentation](https://developers.google.com/maps/documentation/ios/urlscheme) first.

##Installing OpenInGoogleMapsController 
You can download the `OpenInGoogleMapsController` class, along with a sample app demonstrating its use, from the OpenInGoogleMaps [Github page](http:`OpenInGoogleMapsController`//TODO). 

To add the class to your Xcode project, simply drag the `OpenInGoogleMapsController` .m and .h files into Xcode. Make sure you call `#import OpenInGoogleMapsController.h` where necessary.

###Running the Sample Application
If you would like to try out the sample application, open `OpenInGoogleMapsSample.xcodeproj` in Xcode. You will probably want to run this on a real device, as the simulator does not have Google Maps installed. 

##Using OpenInGoogleMapsController
`OpenInGoogleMapsController` is a singleton class, which you can reference by calling the `sharedInstance` class method.

	[[OpenInGoogleMapsController sharedInstance] <make calls here>]

##Adding a Callback URL

Google Maps and Google Chrome both support the [x-callback-URL](http://x-callback-url.com/) specification, which allows you to easily add a "Back to _my app_" button in Google Maps. To add a callback url:

1. Within your Xcode project, select your target, and then select *Info -> URL Types* 
2. Add a URLType for your application. This string should be unique for your app. Many developers choose to use their bundle identifier, without the periods (`comgooglemyapp`, for instance).
3. Set the `callbackURL` property in your `OpenInGoogleMapsController` class.

 		NSString myURLScheme = @"comexamplemyapp://";
		NSURL myCallbackURL = [NSURL URLWithString:myURLScheme];
		[OpenInGoogleMapsController sharedInstance].callbackURL = myCallbackURL;

When you open your maps now in Google Maps (or Google Chrome), you should see a button that redirects users back to your app when they're done viewing the map.	

You only need to set the callback URL once during the lifetime of your application and it will be used in all future `OpenInGoogleMapsController` requests.

##Fallback Strategies

If the user does not have Google Maps installed, you can specify a number of fallback strategies for `OpenInGoogleMapsController` to try by setting the `fallbackStrategy` property.

	[OpenInGoogleMapsController sharedInstance].fallbackStrategy =
    	kGoogleMapsFallbackChromeThenAppleMaps;

The fallback strategies you can try are as follows:

* `kGoogleMapsFallbackNone` = Do nothing and return `NO` if the user does not have Google Maps installed. This is the default.
* `kGoogleMapsFallbackAppleMaps` = Open the map with Apple's Maps app instead.
* `kGoogleMapsFallbackChromeThenSafari` = Open the map with Google Chrome if installed, otherwise
  open the map using Google Maps in Safari.
* `kGoogleMapsFallbackChromeThenAppleMaps` = Open the map with Google Chrome if installed, otherwise
  use Apple's Maps app. 
* `kGoogleMapsFallbackSafari` = Open the map with Google Maps in Safari instead.

If you have specified a callback URL, it will also be passed to Google Chrome.

You only need to set the fallback strategy once during the lifetime of your application and it will be used in all future `OpenInGoogleMapsController` requests.

###Detecting if Google Maps is installed###

If you want to manually detect if Google Maps is installed, you can use the `isGoogleMapsInstalled` property.

	BOOL isGoogleMapsInstalled = [OpenInGoogleMapsController sharedInstance].isGoogleMapsInstalled;

##Opening a map##

Opening a map requires first creating a `GoogleMapDefinition` object to define the map you want opened. You can then pass the definition object to the `openMap` method. This method will return `YES` if it was able to open the map in some application, and `NO` if it was unable to open a map, either because you didn't define anything to search for, or your user does not have Google Maps installed and you did not specify a fallback strategy.

	GoogleMapDefinition *definition = [[GoogleMapDefinition alloc] init];
  	// Steps to define the definition.
  	[[OpenInGoogleMapsController sharedInstance] openMap:definition];
  

###GoogleMapDefinition##

The `GoogleMapDefinition` class includes several properties, some of which may be set to `nil`:

* `(NSString *)queryString`: A query string which, if set, will be used to search for a place by name.
* `(CLLocationCoordinate2D) center`: Defines the center of the map, in lat/long. If both this and the query string are specified, this will be used as a center for the search. To clear this value, set it to `kCLLocationCoordinate2DInvalid`. (Setting it to nil will specify a center of 0,0.)
* `(GoogleMapsViewOptions) viewOptions`: A set of bitwise-ORed options that can be set on your map:
	* `kGoogleMapsViewOptionSatellite`: Shows a satellite view.
	* `kGoogleMapsViewOptionTraffic`: Shows traffic information.
	* `kGoogleMapsViewOptionTransit`: Shows transit information.
* `float zoomLevel`: Defines the zoom level of the map. This can currently be any value from 0 to 21.0.

Here's an example that opens up a map for "123 Main Street, Anytown, CA" with the "traffic" and "satellite" map layers turned on.

 	GoogleMapDefinition *definition = [[GoogleMapDefinition alloc] init];
	definition.queryString = @"123 Main Street, Anytown, CA";
	definition.viewOptions = kGoogleMapsViewOptionSatellite | kGoogleMapsViewOptionTraffic;
	[[OpenInGoogleMapsController sharedInstance] openMap:definition];

##Opening a street view location##

Opening a Street View location requires creating a `GoogleStreetViewDefinition` class to define the location you want to open. You can then pass this definition to the `openStreetView` method.  This method will return `YES` if it was able to open the Street View request in some application, and `NO` if it was not, either because you didn't define a set of coordinates, or your user does not have Google Maps installed and you did not specify a fallback strategy.

Note that a `YES` value does not actually guarantee the coordinates you specified were a valid Street View location.

If your fallback strategy involves an app that does not support Street View, the `OpenInGoogleMapsController` class will open a zoomed-in satellite view on a map instead. 

Here's an example that opens up a Street View location near the Taj Mahal.

	GoogleStreetViewDefinition *definition = [[GoogleStreetViewDefinition alloc] init];
	definition.center = CLLocationCoordinate2DMake(27.1724439,78.0420174);
	[[OpenInGoogleMapsController sharedInstance] openStreetView:definition];

	
###GoogleStreetViewDefinition##

The `GoogleStreetViewDefinition` class includes one property:

* `(CLLocationCoordinate2D) center`: Defines the Street View location, in lat/long. To clear this value, set it to `kCLLocationCoordinate2DInvalid`. (Setting it to nil will specify a center of 0,0.)

##Opening directions##

Opening a set of directions in Google Maps requires creating a `GoogleDirectionsDefinition` class to define the set of points you want to travel between. You can then pass this definition to the `openStreetView` method.  This method will return `YES` if it was able to open the set of directions in some application, and `NO` if it was unable to, either because both your start and end point were empty, or your user does not have Google Maps installed and you did not specify a fallback strategy.

Note that a `YES` value does not guarantee that Google Maps (or the fallback application) was able to find a set of directions between these two points:

###GoogleDirectionsWaypoint###
The `GoogleDirectionsDefinition` class uses the `GoogleDirectionsWaypoint` class to define its start and end points for a direction request. This class includes these properties:

* `CLLocationCoordinate2D location`: Defines the location as a set of coordinates
* `NSString *queryString`: Defines the location as a query string (such as an address)

If both of these values are set, the location takes precedence over the query string.

The `GoogleDirectionsWaypoint` class also has two class helper methods: `+ waypointWithQuery:(NSString *)queryString` and `+ waypointWithLocation:(CLLocationCoordinate2D)location` to easily construct waypoints.

###GoogleDirectionsDefinition###

The `GoogleDirectionsDefinition` class includes these properties:

* `GoogleDirectionsWaypoint *startingPoint`: Defines the starting point. If this is set to `nil`, the directions will start at the user's current location.
* `GoogleDirectionsWaypoint *destinationPoint`: Defines the destination. If this is set to `nil`, the directions will end at the user's current location.
* `GoogleMapsTravelMode travelMode`: Defines how the user will get from the `startingPoint` to the `destinationPoint`. Current options are:
	* `kGoogleMapsTravelModeDriving` for driving.
  	* `kGoogleMapsTravelModeTransit` for taking public transportation.
  	* `kGoogleMapsTravelModeBiking` for biking.
  	* `kGoogleMapsTravelModeWalking` for walking.


The following example will help you plan your next burrito-centric road trip:

	GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
	definition.startingPoint = [GoogleDirectionsWaypoint
	    waypointWithQuery:@"La Taqueria, 2889 Mission St San Francisco, CA 94110"];
	definition.destinationPoint = [GoogleDirectionsWaypoint
	    waypointWithQuery:@"Delicious Mexican Eatery, 3314 Fort Blvd, El Paso, TX 79930"];
	definition.travelMode = kGoogleMapsTravelModeDriving;
	[[OpenInGoogleMapsController sharedInstance] openDirections:definition];

The following example will give you biking directions from MI6 headquarters to Sherlock Holmes' address:

	GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
	definition.startingPoint = [GoogleDirectionsWaypoint
	                            waypointWithLocation:CLLocationCoordinate2DMake(51.487242,-0.124402)];
	definition.destinationPoint = [GoogleDirectionsWaypoint
	                               waypointWithQuery:@"221B Baker Street, London"];
	definition.travelMode = kGoogleMapsTravelModeBiking;
	[[OpenInGoogleMapsController sharedInstance] openDirections:definition];

The following example will give you walking directions from your current location to the North American International Auto Show:

	GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
	definition.startingPoint = nil;
	GoogleDirectionsWaypoint *destination = [[GoogleDirectionsWaypoint alloc] init];
	destination.queryString = @"1 Washington Blvd, Detroit, MI 48226";
	definition.destinationPoint = destination;
	definition.travelMode = kGoogleMapsTravelModeWalking;
	[[OpenInGoogleMapsController sharedInstance] openDirections:definition];


##Reference Documentation
You can find the reference documentation in the `Docs/html/` folder or 
[online](http://googlemaps.github.io/OpenInGoogleMaps-iOS/index.html). It makes for some
thrilling late-night reading.

# Special Thanks #

Special thanks go out to Ian Barber, Leo Hourvitz, and [Sam Thorogood](https://github.com/samthor), for thoroughly reviewing this code. Any remaining mistakes are the author's.

Safari is a registered trademark of Apple Inc.

Reference documentation was generated by [appledoc](http://gentlebytes.com/appledoc/).

