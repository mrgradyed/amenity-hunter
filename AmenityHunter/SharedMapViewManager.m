//
//  MapViewSharedController.m
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
//  Created by emi on 28/01/15.
//

@import MapKit;

#import "OverpassBBox.h"
#import "SharedLocationManager.h"
#import "SharedMapViewManager.h"

@interface SharedMapViewManager ()

@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic) MKMapRect visibleMapArea;

@end

@implementation SharedMapViewManager

#pragma mark - ACCESSORS

- (MKMapRect)visibleMapArea
{
    return _visibleMapArea = self.mapView.visibleMapRect;
}

#pragma mark - CLASS METHODS

+ (instancetype)sharedInstance
{
    // The class method which actually creates the singleton.

    // The static variable which will hold the single and only instance of this
    // class.

    static SharedMapViewManager *sharedMapView;

    static dispatch_once_t blockHasCompleted;

    // Create an instance of this class once and only once for the lifetime of the
    // application.

    dispatch_once(&blockHasCompleted, ^{ sharedMapView = [[self alloc] initActually]; });

    return sharedMapView;
}

#pragma mark - INIT

- (instancetype)init
{
    // Return an exception if someone try to use the default init
    // instead of creating a singleton by using the class method.
    NSString *exceptionString =
        [NSString stringWithFormat:@"Please use: [%@ sharedInstance] instead.", NSStringFromClass([self class])];

    @throw [NSException exceptionWithName:@"SingletonException" reason:exceptionString userInfo:nil];

    return nil;
}

- (instancetype)initActually
{
    // The actual (private) init method used by the class method to create a
    // singleton.

    self = [super init];

    if (self)
    {
        _mapView = [[MKMapView alloc] init];
        _mapView.showsPointsOfInterest = NO;
        _mapView.showsBuildings = YES;

        [[SharedLocationManager sharedInstance] requestLocationPermissionOnIOS8];

        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
    }

    return self;
}

#pragma mark - PUBLIC UTLITY METHODS

- (void)refreshMapWithNewAnnotations:(NSArray *)newAnnotations
{
    NSArray *currentAnnotations = [self.mapView.annotations copy];

    // The following code causes UI operations to be executed, so it must be run on the
    // main queue to avoid conflicts while displaying annotations,
    // (error: "Collection was mutated while being enumerated").
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.mapView removeAnnotations:currentAnnotations];

        [self.mapView addAnnotations:newAnnotations];

    });
}

- (void)removeAllMapAnnotations
{
    NSArray *currentAnnotations = [self.mapView.annotations copy];

    // The following code causes UI operations to be executed, so it must be run on the
    // main queue to avoid conflicts while displaying annotations,
    // (error: "Collection was mutated while being enumerated").
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.mapView removeAnnotations:currentAnnotations];

    });
}

- (OverpassBBox *)overpassBBoxFromVisibleMapArea
{
    MKMapPoint bottomLeftCorner =
        MKMapPointMake(MKMapRectGetMinX(self.visibleMapArea), MKMapRectGetMaxY(self.visibleMapArea));

    MKMapPoint topRightCorner =
        MKMapPointMake(MKMapRectGetMaxX(self.visibleMapArea), MKMapRectGetMinY(self.visibleMapArea));

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

- (void)reduceRegionIfBiggerThanMaxRegion
{
    OverpassBBox *currentBBOX = [self overpassBBoxFromVisibleMapArea];

    if ([currentBBOX compare:[OverpassBBox maxBoundingBox]] == NSOrderedDescending)
    {
        MKCoordinateRegion maxRegion =
            MKCoordinateRegionMake(self.mapView.centerCoordinate, [OverpassBBox maxBoundingBox].span);

        [self.mapView setRegion:maxRegion animated:YES];
    }
}

@end
