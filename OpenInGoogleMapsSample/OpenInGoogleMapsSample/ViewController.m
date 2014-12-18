//
//  ViewController.m
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
#import "MapRequestModel.h"
#import "OpenInGoogleMapsController.h"
#import "PickLocationViewController.h"
#import "ViewController.h"

@interface ViewController () <PickLocationDelegate, UIActionSheetDelegate>
@property(weak, nonatomic) IBOutlet UILabel *startLabel;
@property(weak, nonatomic) IBOutlet UILabel *endLabel;
@property(weak, nonatomic) IBOutlet UISegmentedControl *pickMapTypeSC;
@property(weak, nonatomic) IBOutlet UISwitch *satelliteSwitch;
@property(weak, nonatomic) IBOutlet UISwitch *trafficSwitch;
@property(weak, nonatomic) IBOutlet UISwitch *transitSwitch;
@property(weak, nonatomic) IBOutlet UILabel *startLocationDescription;
@property(weak, nonatomic) IBOutlet UIView *endLocationView;
@property(weak, nonatomic) IBOutlet UILabel *endLocationDescription;
@property(weak, nonatomic) IBOutlet UIButton *endLocationButton;
@property(weak, nonatomic) IBOutlet UIView *mapFeaturesView;
@property(weak, nonatomic) IBOutlet UIView *travelModeView;
@property(weak, nonatomic) IBOutlet UIButton *travelMethodButton;
@property(nonatomic, strong) MapRequestModel *model;
@property(nonatomic, assign) LocationGroup pendingLocationGroup;
@property(nonatomic, strong) UIActionSheet *travelModeActionSheet;
@end

// Don't forget that, in your own application, you'll need to register your URL scheme by
// adding it in Info -> URL Types for your Xcode project.
static NSString * const kOpenInMapsSampleURLScheme = @"OpenInGoogleMapsSample://";

@implementation ViewController
#pragma mark - Relevant to openInMaps

- (void)openMapInGoogleMaps {
  GoogleMapDefinition *mapDefinition = [[GoogleMapDefinition alloc] init];
  mapDefinition.queryString = self.model.startQueryString;
  mapDefinition.center = self.model.startLocation;
  mapDefinition.viewOptions |= (self.satelliteSwitch.isOn) ? kGoogleMapsViewOptionSatellite : 0;
  mapDefinition.viewOptions |= (self.trafficSwitch.isOn) ? kGoogleMapsViewOptionTraffic : 0;
  mapDefinition.viewOptions |= (self.transitSwitch.isOn) ? kGoogleMapsViewOptionTransit : 0;
  if (mapDefinition.queryString && CLLocationCoordinate2DIsValid(mapDefinition.center)) {
    // Sets some reasonable bounds for the "Pizza near Times Square" types of maps
    mapDefinition.zoomLevel = 15.0f;
  }
  [[OpenInGoogleMapsController sharedInstance] openMap:mapDefinition];

}

- (void)openDirectionsInGoogleMaps {
  GoogleDirectionsDefinition *directionsDefinition = [[GoogleDirectionsDefinition alloc] init];
  if (self.model.startCurrentLocation) {
    directionsDefinition.startingPoint = nil;
  } else {
    GoogleDirectionsWaypoint *startingPoint = [[GoogleDirectionsWaypoint alloc] init];
    startingPoint.queryString = self.model.startQueryString;
    startingPoint.location = self.model.startLocation;
    directionsDefinition.startingPoint = startingPoint;
  }
  if (self.model.destinationCurrentLocation) {
    directionsDefinition.destinationPoint = nil;
  } else {
    GoogleDirectionsWaypoint *destination = [[GoogleDirectionsWaypoint alloc] init];
    destination.queryString = self.model.destinationQueryString;
    destination.location = self.model.desstinationLocation;
    directionsDefinition.destinationPoint = destination;
  }
  directionsDefinition.travelMode = [self travelModeAsGoogleMapsEnum:self.model.travelMode];
  [[OpenInGoogleMapsController sharedInstance] openDirections:directionsDefinition];
}

- (void)openStreetViewInGoogleMaps {
  GoogleStreetViewDefinition *streetViewDefinition = [[GoogleStreetViewDefinition alloc] init];
  if (CLLocationCoordinate2DIsValid(self.model.startLocation)) {
    streetViewDefinition.center = self.model.startLocation;
    [[OpenInGoogleMapsController sharedInstance] openStreetView:streetViewDefinition];
  } else {
    [self showSimpleAlertWithTitle:@"Please select a lat/long"
                       description:@"To display a Street View location, you must define it by a "
                                    "lat / long"];
  }
}

- (IBAction)openInMapsWasClicked:(id)sender {
  if (![[OpenInGoogleMapsController sharedInstance] isGoogleMapsInstalled]) {
    NSLog(@"Google Maps not installed, but using our fallback strategy");
  }

  if (self.pickMapTypeSC.selectedSegmentIndex == 0) {
    [self openMapInGoogleMaps];
  } else if (self.pickMapTypeSC.selectedSegmentIndex == 1) {
    [self openDirectionsInGoogleMaps];
  } else if (self.pickMapTypeSC.selectedSegmentIndex == 2) {
    [self openStreetViewInGoogleMaps];
  }
}


# pragma mark - Handle input and set locations



- (IBAction)typeOfMapChanged:(UISegmentedControl *)sender {
  if (sender.selectedSegmentIndex == 0) {
    // We are displaying a map!
    self.startLabel.text = @"Location";
    self.endLocationView.hidden = YES;
    self.mapFeaturesView.hidden = NO;
    self.travelModeView.hidden = YES;
  } else if (sender.selectedSegmentIndex == 1) {
    // We are asking for directions!
    self.startLabel.text = @"Start location";
    self.endLocationView.hidden = NO;
    self.mapFeaturesView.hidden = YES;
    self.travelModeView.hidden = NO;
  } else if (sender.selectedSegmentIndex == 2) {
    // We are displaying street view!
    self.startLabel.text = @"Location";
    self.endLocationView.hidden = YES;
    self.mapFeaturesView.hidden = YES;
    self.travelModeView.hidden = YES;
  }
}

- (void)updateTextStrings {
  self.startLocationDescription.text = [self.model descriptionForGroup:kLocationGroupStart];
  self.endLocationDescription.text = [self.model descriptionForGroup:kLocationGroupEnd];
  [self.travelMethodButton setTitle:[self.model travelModeDescription]
                           forState:UIControlStateNormal];
}

- (IBAction)editLocationWaspressed:(id)sender {
  self.pendingLocationGroup = ((UIButton *)sender).tag;
  [self performSegueWithIdentifier:@"segueToPickLocation" sender:self];
}

- (IBAction)travelMethodButtonWasPressed:(id)sender {
  self.travelModeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select travel mode"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  NSArray *travelModeStrings = [self.model sortedTravelModeDescriptions];
  for (NSString *buttonLabel in travelModeStrings) {
    [self.travelModeActionSheet addButtonWithTitle:buttonLabel];
  }
  [self.travelModeActionSheet showInView:self.view];
}


# pragma mark - PickLocationDelegate

- (void)pickLocationController:(PickLocationViewController *)controller
             pickedQueryString:(NSString *)query
                      location:(CLLocationCoordinate2D)location
                      forGroup:(LocationGroup)group {
  [self.model setQueryString:query center:location forGroup:group];
  [self updateTextStrings];
}

- (void)pickLocationController:(PickLocationViewController *)controller
                pickedLocation:(CLLocationCoordinate2D)location
                      forGroup:(LocationGroup)group {
  [self.model setQueryString:nil center:location forGroup:group];
  [self updateTextStrings];
}

- (void)pickLocationController:(PickLocationViewController *)controller
             pickedQueryString:(NSString *)query
                      forGroup:(LocationGroup)group {
  [self.model setQueryString:query forGroup:group];
  [self updateTextStrings];
}

- (void)pickLocationController:(PickLocationViewController *)controller
    pickedCurrentLocationForGroup:(LocationGroup)group {
  [self.model useCurrentLocationForGroup:group];
  [self updateTextStrings];
}

- (void)noLocationPickedByPickLocationController:(PickLocationViewController *)controller {
  // Leave everything unchanged
}

# pragma ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) { // Cancel
    return;
  }
  self.model.travelMode = buttonIndex - 1;
  [self updateTextStrings];
}


# pragma mark - Miscellaneous helper methods

// Our fancy new way of showing an alert!
- (void)showSimpleAlertWithTitle:(NSString *)title description:(NSString *)description {
  if (NSClassFromString(@"UIAlertController")) {
    UIAlertAction *okay =
        [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:description
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
  } else {
    [[[UIAlertView alloc] initWithTitle:title
                                message:description
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
  }
}

// Hide the keyboard when touching outside the textfields
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [[self view] endEditing:YES];
}

// Convert our app's "travel mode" to the official Google Enum
- (GoogleMapsTravelMode)travelModeAsGoogleMapsEnum:(TravelMode)appTravelMode {
  switch (appTravelMode) {
    case kTravelModeBicycling:
      return kGoogleMapsTravelModeBiking;
    case kTravelModeDriving:
      return kGoogleMapsTravelModeDriving;
    case kTravelModePublicTransit:
      return kGoogleMapsTravelModeTransit;
    case kTravelModeWalking:
      return kGoogleMapsTravelModeWalking;
    case kTravelModeNotSpecified:
      return 0;
  }
}

# pragma mark - Life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue destinationViewController] class] == [PickLocationViewController class]) {
    PickLocationViewController *destVC = [segue destinationViewController];
    // Only let players set their current location if we're looking for directions
    destVC.allowCurrentLocation = (self.pickMapTypeSC.selectedSegmentIndex == 1);
    destVC.group = self.pendingLocationGroup;
    destVC.delegate = self;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.model = [[MapRequestModel alloc] init];
  // Add some default values
  [self pickLocationController:nil
             pickedQueryString:@"1600 Amphitheatre Parkway, Mountain View, CA 94043"
                      forGroup:kLocationGroupStart];
  [self typeOfMapChanged:self.pickMapTypeSC];

  // And let's set our callback URL right away!
  [OpenInGoogleMapsController sharedInstance].callbackURL =
      [NSURL URLWithString:kOpenInMapsSampleURLScheme];

  // If the user doesn't have Google Maps installed, let's try Chrome. And if they don't
  // have Chrome installed, let's use Apple Maps. This gives us the best chance of having an
  // x-callback-url that points back to our application.
  [OpenInGoogleMapsController sharedInstance].fallbackStrategy =
      kGoogleMapsFallbackChromeThenAppleMaps;
}

@end

