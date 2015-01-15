//
//  NetworIndicatorSharedController.m
//  AmenityHunter
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by emi on 11/12/14.
//
//

#import "NetworkIndicatorSharedController.h"

@import UIKit;

@implementation NetworkIndicatorSharedController

#pragma mark - ACCESSORS

- (void)setNetworkActivitiesCount:(NSInteger)networkActivitiesCount
{
    _networkActivitiesCount = networkActivitiesCount;

    if (_networkActivitiesCount > 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    else
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

#pragma mark - UTILITY METHODS

- (void)networkActivityDidStart { self.networkActivitiesCount++; }

- (void)networkActivityDidStop { self.networkActivitiesCount--; }

#pragma mark - CLASS METHODS

+ (instancetype)sharedInstance
{
    // The class method which actually creates the singleton.

    // The static variable which will hold the single and only instance of this
    // class.

    static NetworkIndicatorSharedController *sharedNetworkIndicatorController;

    static dispatch_once_t blockHasCompleted;

    // Create an instance of this class once and only once for the lifetime of the
    // application.

    dispatch_once(&blockHasCompleted,
                  ^{ sharedNetworkIndicatorController = [[self alloc] initActually]; });

    return sharedNetworkIndicatorController;
}

#pragma mark - INIT

- (instancetype)init
{
    // Return an exception if someone try to use the default init
    // instead of creating a singleton by using the class method.

    @throw [NSException exceptionWithName:@"SingletonException"
                                   reason:@"Please use: [NetworkIndicatorSharedController "
                                   @"sharedInstance] instead."
                                 userInfo:nil];

    return nil;
}

- (instancetype)initActually
{
    // The actual (private) init method used by the class method to create a
    // singleton.

    self = [super init];

    if (self)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }

    return self;
}

@end
