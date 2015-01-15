//
//  AmenityAnnotation.m
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
//  Created by emi on 24/11/14.
//
//

#import "AmenityAnnotation.h"

NSString *const gAmenityAnnotationViewReuseIdentifier = @"AmenityAnnotationViewReuseIdentifier";

@implementation AmenityAnnotation

#pragma mark - DESIGNATED INIT

- (instancetype)initWithLatitude:(double)latitude Longitude:(double)longitude
{
    self = [super init];

    if (self)
    {
        CLLocationCoordinate2D amenityPosition = CLLocationCoordinate2DMake(latitude, longitude);

        self.coordinate = amenityPosition;
    }

    return self;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [self initWithLatitude:0.0 Longitude:0.0];
    }

    return self;
}

@end
