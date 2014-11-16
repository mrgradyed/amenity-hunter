//
//  MapViewController.m
//  AmenityHunter
//
//  Created by emi on 14/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "MapViewController.h"

@import MapKit;

@interface MapViewController () <MKMapViewDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

#pragma mark - ACCESSORS

- (void)setMapView:(MKMapView *)mapView
{
    // Configure the map view upon setting it.

    _mapView = mapView;

    _mapView.showsUserLocation = YES;
    _mapView.showsPointsOfInterest = NO;
    _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
