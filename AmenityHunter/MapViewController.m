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

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

#pragma mark - ACCESSORS

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }

    return _locationManager;
}

- (void)setMapView:(MKMapView *)mapView
{
    // Configure the map view upon setting it.

    _mapView = mapView;

    [self askForLocationPermission];

    _mapView.showsUserLocation = YES;
    _mapView.showsPointsOfInterest = NO;
    _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
}

#pragma mark - LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFetchedOverpassData:)
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

#pragma mark - UTILITY METHODS

- (void)askForLocationPermission
{
    // iOS 7 doesn't have this selector, let's check.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        // From Apple docs: this method runs asynchronously and prompts the user to grant permission
        // to the app to use location services. The user prompt contains the text from the
        // NSLocationWhenInUseUsageDescription key in your app’s Info.plist file, and the presence
        // of that key is required when calling this method.

        // iOS 8.0 and later ONLY.

        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)handleFetchedOverpassData:(NSNotification *)notification
{
    NSLog(@"%s NOT IMPLEMENTED", __PRETTY_FUNCTION__);
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
