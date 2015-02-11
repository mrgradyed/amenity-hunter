//
//  SharedLocationManager.h
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

@import UIKit;

@interface SharedLocationManager : NSObject

#pragma mark - PROPERTIES

@property(nonatomic, strong, readonly) CLLocationManager *locationManager;
@property(nonatomic, strong, readonly) CLGeocoder *geocoder;

#pragma mark - CLASS METHODS

+ (instancetype)sharedInstance;

#pragma mark - INSTANCE METHODS

- (UIAlertView *)locationDeniedAlertViewForIOS7;

- (UIAlertController *)locationDeniedAlertControllerForIOS8;

- (void)requestLocationPermissionOnIOS8;

@end
