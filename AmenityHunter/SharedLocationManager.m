//
//  SharedLocationManager.m
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
//  Created by emi on 10/02/15.
//

@import CoreLocation;

#import "SharedLocationManager.h"

@interface SharedLocationManager () <CLLocationManagerDelegate, UIAlertViewDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation SharedLocationManager

#pragma mark - ACCESSORS

+ (instancetype)sharedInstance
{
    // The class method which actually creates the singleton.

    // The static variable which will hold the single and only instance of this
    // class.

    static SharedLocationManager *sharedLocationManager;

    static dispatch_once_t blockHasCompleted;

    // Create an instance of this class once and only once for the lifetime of the
    // application.

    dispatch_once(&blockHasCompleted, ^{ sharedLocationManager = [[self alloc] initActually]; });

    return sharedLocationManager;
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
        self.locationManager = [[CLLocationManager alloc] init];
    }

    return self;
}

#pragma mark - LOCATION ALERTS

- (UIAlertView *)locationDeniedAlertViewForIOS7
{
    // UIAlertView is deprecated in iOS 8.
    // We should use UIAlertController instead.

    UIAlertView *locationDeniedAlertViewForIOS7 =
        [[UIAlertView alloc] initWithTitle:@"Location Settings"
                                   message:@"Amenity Hunter cannot access your location."
                                   @"Your location is needed to show amenities near you."
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];

    return locationDeniedAlertViewForIOS7;
}

- (UIAlertController *)locationDeniedAlertControllerForIOS8
{
    // UIAlertView is deprecated in iOS 8.
    // We use UIAlertController instead.

    UIAlertController *locationDeniedAlertControllerForIOS8 =
        [UIAlertController alertControllerWithTitle:@"Location Settings"
                                            message:@"Amenity Hunter cannot access your location."
                                            @"Your location is needed to show amenities near you."
                                     preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *canceButton =
        [UIAlertAction actionWithTitle:@"Continue anyway" style:UIAlertActionStyleCancel handler:nil];

    UIAlertAction *settingsButton =
        [UIAlertAction actionWithTitle:@"Change location settings"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {

                                   // UIApplicationOpenSettingsURLString is iOS 8.0 and later
                                   // ONLY.
                                   NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

                                   [[UIApplication sharedApplication] openURL:settingsURL];
                               }];

    [locationDeniedAlertControllerForIOS8 addAction:canceButton];
    [locationDeniedAlertControllerForIOS8 addAction:settingsButton];

    return locationDeniedAlertControllerForIOS8;
}

- (void)requestLocationPermissionOnIOS8
{
    // Requests permission to use location services while the app is in the foreground.
    // iOS 8.0 and later ONLY.

    // Are we on iOS8? Let's check.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        // requestWhenInUseAuthorization: this method runs asynchronously and prompts the user to grant
        // permission to the app to use location services. The user prompt contains the text
        // from the NSLocationWhenInUseUsageDescription key in your app’s Info.plist file,
        // and the presence of that key is required when calling this method.
        // If the current authorization status is anything other than
        // kCLAuthorizationStatusNotDetermined, this method does nothing and does
        // not call the locationManager:didChangeAuthorizationStatus: method.

        [self.locationManager requestWhenInUseAuthorization];
    }
}

@end
