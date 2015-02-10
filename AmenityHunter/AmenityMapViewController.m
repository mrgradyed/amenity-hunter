//
//  MapViewController.m
//  AmenityHunter
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE
//  SOFTWARE.
//
//  Created by emi on 14/11/14.
//
//

#import "AmenityMapViewController.h"
#import "SharedOverpassAPI.h"
#import "OverpassBBox.h"
#import "AmenityAnnotation.h"
#import "SharedMapViewManager.h"
#import "SharedLocationManager.h"

@import MapKit;
@import CoreLocation;

@interface AmenityMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property(strong, nonatomic) SharedMapViewManager *sharedMapViewManager;
@property(strong, nonatomic) SharedLocationManager *sharedLocationManager;
@property(strong, nonatomic) NSMutableArray *mapAmenityAnnotations;
@property(strong, nonatomic) SharedOverpassAPI *overpassAPIsharedInstance;
@property(nonatomic) NSInteger refetches;

@end

@implementation AmenityMapViewController

#pragma mark - ACCESSORS

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

- (SharedMapViewManager *)sharedMapViewManager
{
    return _sharedMapViewManager = [SharedMapViewManager sharedInstance];
}

- (SharedLocationManager *)sharedLocationManager
{
    return _sharedLocationManager = [SharedLocationManager sharedInstance];
}

#pragma mark - ACCESSORS FOR PUBLIC PROPERTIES

- (void)setSelectedAmenityType:(NSString *)selectedAmenityType
{
    if ([_selectedAmenityType isEqualToString:selectedAmenityType])
    {
        return;
    }

    _selectedAmenityType = selectedAmenityType;

    [self.sharedMapViewManager reduceRegionIfBiggerThanMaxRegion];

    [self fetchOverpassData];
}

#pragma mark - LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.sharedMapViewManager.mapView.delegate = self;
    [self.view addSubview:self.sharedMapViewManager.mapView];
    self.sharedMapViewManager.mapView.frame = self.view.bounds;

    self.navigationController.navigationBarHidden = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOverpassData:)
                                                 name:gOverpassDataFetchedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFetchingFailure)
                                                 name:gOverpassFetchingFailedNotification
                                               object:nil];
}

- (void)dealloc
{
    // Remove this controller object from all notifications listening.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    // User has moved the map, remove the "old" annotations to improve
    // performance.
    [self.sharedMapViewManager removeAllMapAnnotations];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.selectedAmenityType)
    {
        [self.sharedMapViewManager reduceRegionIfBiggerThanMaxRegion];

        [self fetchOverpassData];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isEqual:mapView.userLocation])
    {
        return nil;
    }

    MKAnnotationView *annotationView =
        [mapView dequeueReusableAnnotationViewWithIdentifier:gAmenityAnnotationViewReuseIdentifier];

    if (!annotationView)
    {
        MKPinAnnotationView *pinAnnotationView =
            [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                            reuseIdentifier:gAmenityAnnotationViewReuseIdentifier];

        pinAnnotationView.pinColor = MKPinAnnotationColorPurple;
        pinAnnotationView.canShowCallout = YES;
        pinAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

        return pinAnnotationView;
    }

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView
                   annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"toAmenityInfo" sender:self];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        if ([UIAlertController class])
        {
            // iOS 8 and higher.
            [self presentViewController:[self.sharedLocationManager locationDeniedAlertControllerForIOS8]
                               animated:YES
                             completion:nil];
        }
        else
        {
            // iOS 7 and lower.
            UIAlertView *locationDeniedAlertViewForIOS7 = [self.sharedLocationManager locationDeniedAlertViewForIOS7];

            locationDeniedAlertViewForIOS7.delegate = self;
            [locationDeniedAlertViewForIOS7 show];
        }
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [self.sharedLocationManager requestLocationPermissionOnIOS8];
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

- (void)fetchOverpassData
{
    // User has set a new amenity type or has moved the map,
    // we're going to fetch new data, remove the "old" annotations to improve performance.
    [self.sharedMapViewManager removeAllMapAnnotations];

    self.overpassAPIsharedInstance.boundingBox = [self.sharedMapViewManager overpassBBoxFromVisibleMapArea];
    self.overpassAPIsharedInstance.amenityType = self.selectedAmenityType;

    [self.overpassAPIsharedInstance startFetchingAmenitiesData];
}

- (void)handleOverpassData:(NSNotification *)notification
{
    NSLog(@"%@", notification.userInfo);

    // New valid data acquired. Reset refetches counter.
    self.refetches = 0;

    // Remove old annotations references.
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

        if (!elementName)
        {
            annotation.title = elementType;
            annotation.subtitle = nil;
        }

        [self.mapAmenityAnnotations addObject:annotation];
    }

    [self.sharedMapViewManager refreshMapWithNewAnnotations:self.mapAmenityAnnotations];
}

- (void)handleFetchingFailure
{
    // Let's limit refetches.
    if (self.refetches < 3)
    {
        // Try refetching...
        [self fetchOverpassData];

        self.refetches++;

#if DEBUG
        NSLog(@"Fetching failed. Refetch n.%ld", (long)self.refetches);
#endif
    }
}

@end
