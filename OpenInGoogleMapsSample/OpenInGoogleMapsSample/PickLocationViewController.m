//
//  PickLocationViewController.m
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

#import "PickLocationViewController.h"

@interface PickLocationViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property(weak, nonatomic) IBOutlet UITextField *searchStringTextField;
@property(weak, nonatomic) IBOutlet UITextField *latTextField;
@property(weak, nonatomic) IBOutlet UITextField *longTextField;
@property(weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property(weak, nonatomic) IBOutlet UIPickerView *locationPicker;
@property(weak, nonatomic) IBOutlet UISwitch *currentLocationSwitch;
@property(weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
@end



@implementation PickLocationViewController {
  NSArray *_someNiceDefaults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)doneButtonPressed:(id)sender {
  // Let's pass the information back to our delegate.
  NSString *searchStringText = self.searchStringTextField.text;
  float latValue = [self.latTextField.text floatValue];
  float longValue = [self.longTextField.text floatValue];
  if (latValue < -90 || latValue > 90)
    latValue = 0;
  if (longValue < -180 || longValue > 180)
    longValue = 0;

  // TODO: Explicitly writing a lat,long of 0,0 (or 0.0, 0.0) will
  // count as not setting it at all. Let's fix that
  CLLocationCoordinate2D location;
  if (latValue == 0 && longValue == 0) {
    location = kCLLocationCoordinate2DInvalid;
  } else {
    location = CLLocationCoordinate2DMake(latValue, longValue);
  }
  BOOL validLocaton = CLLocationCoordinate2DIsValid(location);

  if (self.currentLocationSwitch.isOn) {
    NSLog(@"Current location is on!!");
    [self.delegate pickLocationController:self pickedCurrentLocationForGroup:self.group];
  } else if ([searchStringText isEqualToString:@""]) {
    if (validLocaton) {
      [self.delegate pickLocationController:self
                             pickedLocation:location
                                   forGroup:self.group];
    } else {
      [self.delegate noLocationPickedByPickLocationController:self];
    }
  } else {
    if (validLocaton) {
      [self.delegate pickLocationController:self
                          pickedQueryString:searchStringText
                                   location:location
                                   forGroup:self.group];
    } else {
      [self.delegate pickLocationController:self
                          pickedQueryString:searchStringText
                                   forGroup:self.group];
    }
  }
  [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)useCurrentLocationSwitchChanged:(UISwitch *)sender {
  self.searchStringTextField.enabled = !sender.isOn;
  self.latTextField.enabled = !sender.isOn;
  self.longTextField.enabled = !sender.isOn;
  self.locationPicker.hidden = sender.isOn;
}

// Hide the keyboard when touching outside the textfields
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [[self view] endEditing:YES];
}


#pragma mark - Picker View DataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return _someNiceDefaults.count;
}

#pragma mark - Picker View Delegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  NSDictionary *entry = _someNiceDefaults[row];
  return entry[@"description"];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  NSDictionary *entry = _someNiceDefaults[row];
  if (entry[@"search"] != [NSNull null]) {
    self.searchStringTextField.text = entry[@"search"];
  } else {
    self.searchStringTextField.text = @"";
  }

  if (entry[@"loc"] != [NSNull null]) {
    NSArray *location = entry[@"loc"];
    self.latTextField.text = [(NSNumber *)location[0] stringValue];
    self.longTextField.text = [(NSNumber *)location[1] stringValue];
  } else {
    self.latTextField.text = @"";
    self.longTextField.text = @"";
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _someNiceDefaults = @[@{@"search": @"1600 Amphitheatre Parkway, Mountain View, CA",
      @"loc": [NSNull null],
      @"description": @"1600 Amphitheatre Parkway"},
    @{@"search": @"345 Spear Street, San Francisco, CA",
      @"loc": [NSNull null],
      @"description": @"345 Spear Street, SF"},
    @{@"search": [NSNull null],
      @"loc": @[@48.8536629,@2.3479513],
      @"description": @"(48.854, 2.347) -- Notre Dame" },
    @{@"search": @"pizza",
      @"loc": @[@40.758895,@-73.985131],
      @"description": @"Pizza near Times Square"},
    @{@"search": @"ramen",
      @"loc": @[@35.680066,@139.767813],
      @"description": @"Ramen near Tokyo Station"},
    @{@"search": @"ice cream",
      @"loc": @[@37.7579691,@-122.3880665],
      @"description": @"Ice cream in Dogpatch"},
    @{@"search": [NSNull null],
      @"loc": @[@1.2792354,@103.8517178],
      @"description": @"(1.279, 103.852) - Singapore towers"},
    @{@"search": @"Roppongi Hills Mori Tower Tokyo Japan",
      @"loc": [NSNull null],
      @"description": @"Mori Tower, Tokyo Japan"}];

  self.locationPicker.dataSource = self;
  self.locationPicker.delegate = self;
  if (self.group == kLocationGroupStart) {
    self.instructionLabel.text = @"Pick a starting location";
  } else {
    self.instructionLabel.text = @"Pick a destination";
  }
  self.currentLocationSwitch.on = NO;
  self.currentLocationSwitch.hidden = !self.allowCurrentLocation;
  self.currentLocationLabel.hidden = !self.allowCurrentLocation;

}



@end

