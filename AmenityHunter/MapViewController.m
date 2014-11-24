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
#import "AmenityAnnotation.h"

@import MapKit;
@import CoreLocation;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) UIAlertView *locationDeniedAlertView;
@property(strong, nonatomic) UIAlertController *locationDeniedAlertController;
@property(strong, nonatomic) NSMutableArray *mapAmenityAnnotations;

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

- (NSMutableArray *)mapAmenityAnnotations
{
    if (!_mapAmenityAnnotations)
    {
        _mapAmenityAnnotations = [[NSMutableArray alloc] init];
    }

    return _mapAmenityAnnotations;
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
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil]; }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    OverpassAPI *overpassAPIsharedInstance = [OverpassAPI sharedInstance];

    OverpassBBox *currentBBox = [self overpassBBoxFromVisibleMapArea];

    overpassAPIsharedInstance.boundingBox = currentBBox;

#warning This is just an example. The amenity type should be chosen by the user via the UI.
    overpassAPIsharedInstance.amenityType = @"bar";

    [overpassAPIsharedInstance startFetchingAmenitiesData];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView =
        [mapView dequeueReusableAnnotationViewWithIdentifier:gAmenityAnnotationViewReuseIdentifier];

    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                         reuseIdentifier:@"AmenityAnnotationID"];
    }

    return annotationView;
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
    NSLog(@"%@", notification.userInfo);

    [self.mapView removeAnnotations:self.mapAmenityAnnotations];

    self.mapAmenityAnnotations = nil;

    id elements = [notification.userInfo valueForKey:@"elements"];

    id elementLatitude;
    id elementLongitude;
    id elementName;
    id elementType;

    AmenityAnnotation *annotation;

    for (id element in elements)
    {
        elementLatitude = [element valueForKey:@"lat"];
        elementLongitude = [element valueForKey:@"lon"];

        elementName = [element valueForKeyPath:@"tags.name"];
        elementType = [element valueForKeyPath:@"tags.amenity"];

        annotation = [[AmenityAnnotation alloc] initWithLatitude:[elementLatitude doubleValue]
                                                       Longitude:[elementLongitude doubleValue]];

        annotation.name = elementName;
        annotation.type = elementType;

        [self.mapAmenityAnnotations addObject:annotation];
    }

    [self.mapView addAnnotations:self.mapAmenityAnnotations];
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
