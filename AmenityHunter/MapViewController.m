//
//  MapViewController.m
//  AmenityHunter
//
//  Created by emi on 14/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "MapViewController.h"
#import "OverpassAPI.h"
#import "OverpassBBox.h"

@import MapKit;
@import CoreLocation;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) UIAlertView *locationDeniedAlertView;
@property(strong, nonatomic) UIAlertController *locationDeniedAlertController;

@end

@implementation MapViewController

#pragma mark - ACCESSORS

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];

        _locationManager.delegate = self;
    }

    return _locationManager;
}

- (UIAlertView *)locationDeniedAlertView
{
    if (!_locationDeniedAlertView)
    {
        // UIAlertView is deprecated in iOS 8. We should use UIAlertController.
        _locationDeniedAlertView =
            [[UIAlertView alloc] initWithTitle:@"Location Settings"
                                       message:@"Amenity Hunter cannot access your location."
                                       @"Your location is needed to show amenities near you."
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    }

    return _locationDeniedAlertView;
}

- (UIAlertController *)locationDeniedAlertController
{
    if (!_locationDeniedAlertController)
    {
        _locationDeniedAlertController = [UIAlertController
            alertControllerWithTitle:@"Location Settings"
                             message:@"Amenity Hunter cannot access your location."
                             @"Your location is needed to show amenities near you."
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *canceButton = [UIAlertAction actionWithTitle:@"Continue anyway"
                                                              style:UIAlertActionStyleCancel
                                                            handler:nil];

        UIAlertAction *settingsButton =
            [UIAlertAction actionWithTitle:@"Change location settings"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {

                                       // UIApplicationOpenSettingsURLString is iOS 8.0 and later
                                       // ONLY.
                                       NSURL *settingsURL =
                                           [NSURL URLWithString:UIApplicationOpenSettingsURLString];

                                       [[UIApplication sharedApplication] openURL:settingsURL];
                                   }];

        [_locationDeniedAlertController addAction:canceButton];
        [_locationDeniedAlertController addAction:settingsButton];
    }

    return _locationDeniedAlertController;
}

- (void)setMapView:(MKMapView *)mapView
{
    // Configure the map view upon setting it.

    _mapView = mapView;
    _mapView.showsPointsOfInterest = NO;

    [self askForLocationPermission];

    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
}

#pragma mark - LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOverpassData:)
                                                 name:gOverpassDataFetchedNotification
                                               object:nil];

    [self requestAmenitiesDataFetch];
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil]; }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        if ([UIAlertController class])
        {
            // iOS 8 and higher.
            [self presentViewController:self.locationDeniedAlertController
                               animated:YES
                             completion:nil];
        }
        else
        {
            // iOS 7 and lower.
            [self.locationDeniedAlertView show];
        }
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [self askForLocationPermission];
    }

#if DEBUG
    switch (status)
    {
    case kCLAuthorizationStatusAuthorizedAlways:
        NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
        break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
        NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
        break;
    case kCLAuthorizationStatusDenied:
        NSLog(@"kCLAuthorizationStatusDenied");
        break;
    case kCLAuthorizationStatusRestricted:
        NSLog(@"kCLAuthorizationStatusRestricted");
        break;
    default:
        break;
    }
#endif
}

#pragma mark - UIAlertViewDelegate

- (void)alertViewCancel:(UIAlertView *)alertView { NSLog(@"%s TO DO", __PRETTY_FUNCTION__); }

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%s TO DO", __PRETTY_FUNCTION__);
}

#pragma mark - UTILITY METHODS

- (void)askForLocationPermission
{
    // iOS 7 doesn't have this selector, let's check.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        // Apple docs: this method runs asynchronously and prompts the user to grant
        // permission
        // to the app to use location services. The user prompt contains the text
        // from the
        // NSLocationWhenInUseUsageDescription key in your app’s Info.plist file,
        // and the presence
        // of that key is required when calling this method.
        // If the current authorization status is anything other than
        // kCLAuthorizationStatusNotDetermined, this method does nothing and does
        // not call the
        // locationManager:didChangeAuthorizationStatus: method.

        // iOS 8.0 and later ONLY.
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)handleOverpassData:(NSNotification *)notification
{
    NSLog(@"%s TO DO", __PRETTY_FUNCTION__);
}

- (OverpassBBox *)overpassBBoxFromVisibleMapArea
{
    MKMapRect visibleMapArea = self.mapView.visibleMapRect;

    MKMapPoint bottomLeftCorner =
        MKMapPointMake(MKMapRectGetMinX(visibleMapArea), MKMapRectGetMaxY(visibleMapArea));

    MKMapPoint topRightCorner =
        MKMapPointMake(MKMapRectGetMaxX(visibleMapArea), MKMapRectGetMinY(visibleMapArea));

    CLLocationCoordinate2D bottomLeftCornerCoordinates = MKCoordinateForMapPoint(bottomLeftCorner);

    CLLocationCoordinate2D topRightCornerCoordinates = MKCoordinateForMapPoint(topRightCorner);

    return [[OverpassBBox alloc] initWithLowestLatitude:bottomLeftCornerCoordinates.latitude
                                        lowestLongitude:bottomLeftCornerCoordinates.longitude
                                        highestLatitude:topRightCornerCoordinates.latitude
                                       highestLongitude:topRightCornerCoordinates.longitude];
}

- (void)requestAmenitiesDataFetch { [[OverpassAPI sharedInstance] startFetchingAmenitiesData]; }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
