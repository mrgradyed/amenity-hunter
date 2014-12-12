//
//  MapViewController.m
//  AmenityHunter
//
//  Created by emi on 14/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "AmenityMapViewController.h"
#import "SharedOverpassAPI.h"
#import "OverpassBBox.h"
#import "AmenityAnnotation.h"

@import MapKit;
@import CoreLocation;

@interface AmenityMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate,
                                        UIAlertViewDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) UIAlertView *locationDeniedAlertView;
@property(strong, nonatomic) UIAlertController *locationDeniedAlertController;
@property(strong, nonatomic) NSMutableArray *mapAmenityAnnotations;
@property(strong, nonatomic) SharedOverpassAPI *overpassAPIsharedInstance;
@property(nonatomic) MKMapRect visibleMapArea;

@end

@implementation AmenityMapViewController

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

- (SharedOverpassAPI *)overpassAPIsharedInstance
{
    return _overpassAPIsharedInstance = [SharedOverpassAPI sharedInstance];
}

- (MKMapRect)visibleMapArea { return _visibleMapArea = self.mapView.visibleMapRect; }

- (void)setMapView:(MKMapView *)mapView
{
    // Configure the map view upon setting it.

    _mapView = mapView;

    [self askForLocationPermission];

    _mapView.showsPointsOfInterest = NO;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
}

#pragma mark - ACCESSORS FOR PUBLIC PROPERTIES

- (void)setSelectedAmenityType:(NSString *)selectedAmenityType
{
    if ([_selectedAmenityType isEqualToString:selectedAmenityType])
    {
        return;
    }

    _selectedAmenityType = selectedAmenityType;

    [self fetchOverpassData];
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self fetchOverpassData];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView =
        [mapView dequeueReusableAnnotationViewWithIdentifier:gAmenityAnnotationViewReuseIdentifier];

    if (!annotationView)
    {
        annotationView =
            [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                            reuseIdentifier:gAmenityAnnotationViewReuseIdentifier];

        ((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorPurple;
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
        NSLog(@"kCLAuthorizationStatusAuthorizedAlways\n\n");
        break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
        NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse\n\n");
        break;
    case kCLAuthorizationStatusDenied:
        NSLog(@"kCLAuthorizationStatusDenied\n\n");
        break;
    case kCLAuthorizationStatusRestricted:
        NSLog(@"kCLAuthorizationStatusRestricted\n\n");
        break;
    default:
        break;
    }
#endif
}

#pragma mark - UIAlertViewDelegate

- (void)alertViewCancel:(UIAlertView *)alertView
{
#warning INCOMPLETE IMPLEMENTATION.
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

- (void)fetchOverpassData
{
    self.overpassAPIsharedInstance.boundingBox = [self overpassBBoxFromVisibleMapArea];

    self.overpassAPIsharedInstance.amenityType = self.selectedAmenityType;

    [self.overpassAPIsharedInstance startFetchingAmenitiesData];
}

- (void)handleOverpassData:(NSNotification *)notification
{
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

        annotation.title = elementName;
        annotation.subtitle = elementType;

        [self.mapAmenityAnnotations addObject:annotation];
    }

    [self refreshMapAnnotations];
}

- (void)refreshMapAnnotations
{
    NSArray *currentAnnotations = [self.mapView.annotations copy];

    // This code causes UI operations to be executed, so it must be run on the
    // main queue to avoid
    // conflicts accessing the annotations, and thus the error: "Collection was
    // mutated while being
    // enumerated".
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.mapView removeAnnotations:currentAnnotations];

        [self.mapView addAnnotations:self.mapAmenityAnnotations];

    });
}

- (void)removeOffMapAnnotations
{
    NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:self.visibleMapArea];

    NSMutableArray *allAnnotations = [self.mapView.annotations copy];

    for (id<MKAnnotation> annotation in allAnnotations)
    {
        if (![visibleAnnotations containsObject:annotation])
        {
            [self.mapView removeAnnotation:annotation];
        }
    }

#if DEBUG
    NSLog(@"VISIBLE ANNOTATIONS: %d\n\n", [visibleAnnotations count]);
#endif

#if DEBUG
    NSLog(@"ALL ANNOTATIONS: %d\n\n", [visibleAnnotations count]);
#endif
}

- (OverpassBBox *)overpassBBoxFromVisibleMapArea
{
    MKMapPoint bottomLeftCorner = MKMapPointMake(MKMapRectGetMinX(self.visibleMapArea),
                                                 MKMapRectGetMaxY(self.visibleMapArea));

    MKMapPoint topRightCorner = MKMapPointMake(MKMapRectGetMaxX(self.visibleMapArea),
                                               MKMapRectGetMinY(self.visibleMapArea));

    CLLocationCoordinate2D bottomLeftCornerCoordinates = MKCoordinateForMapPoint(bottomLeftCorner);
    CLLocationCoordinate2D topRightCornerCoordinates = MKCoordinateForMapPoint(topRightCorner);

    // Rounding to tolerate very small map pannings.
    double lowestLatitude = floor(bottomLeftCornerCoordinates.latitude * 1000) / 1000;
    double lowestLongitude = floor(bottomLeftCornerCoordinates.longitude * 1000) / 1000;
    double highestLatitude = ceil(topRightCornerCoordinates.latitude * 1000) / 1000;
    double highestLongitude = ceil(topRightCornerCoordinates.longitude * 1000) / 1000;

    return [[OverpassBBox alloc] initWithLowestLatitude:lowestLatitude
                                        lowestLongitude:lowestLongitude
                                        highestLatitude:highestLatitude
                                       highestLongitude:highestLongitude];
}

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
