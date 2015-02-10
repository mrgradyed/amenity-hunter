//
//  OverpassBBox.m
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
//  Created by emi on 30/10/14.
//
//

#import "OverpassBBox.h"

@interface OverpassBBox ()

#pragma mark - COORDINATES

// Latitude is a decimal number between -90.0 and 90.0.
// Longitude is a decimal number between -180.0 and 180.0.

// lowest latitude, measured along a meridian from the nearest point on the Equator, negative in the
// Southern Hemisphere

@property(nonatomic) double lowestLatitude;

// lowest longitude, measured along a parallel from the nearest point on the Greenwich meridian,
// negative in the Western Hemisphere

@property(nonatomic) double lowestLongitude;

// highest latitude, measured along a meridian from the nearest point on the Equator, positive in
// the Northern Hemisphere

@property(nonatomic) double highestLatitude;

// highest longitude, measured along a parallel from the nearest point on the Greenwich meridian,
// positive in the Eastern Hemisphere

@property(nonatomic) double highestLongitude;

@end

@implementation OverpassBBox

- (void)setLowestLatitude:(double)lowestLatitude
{
    // We need to check that latitude is in the valid range before setting it.
    if (-90.0 <= lowestLatitude <= 90.0)
    {
        _lowestLatitude = lowestLatitude;
    }
    else
    {
        // Invalid latitude value, raise an exception.
        @throw [NSException exceptionWithName:@"InvalidCoordinatesException"
                                       reason:@"lowestLatitude MUST be between [-90.0, +90.0]"
                                     userInfo:nil];
    }
}

- (void)setLowestLongitude:(double)lowestLongitude
{
    // We need to check that longitude is in the valid range before setting it.
    if (-180.0 <= lowestLongitude <= 180.0)
    {
        _lowestLongitude = lowestLongitude;
    }
    else
    {
        // Invalid longitude value, raise an exception.
        @throw [NSException exceptionWithName:@"InvalidCoordinatesException"
                                       reason:@"lowestLongitude MUST be between [-180.0, +180.0]"
                                     userInfo:nil];
    }
}

- (void)setHighestLatitude:(double)highestLatitude
{
    // We need to check that latitude is in the valid range before setting it.
    if (-90.0 <= highestLatitude <= 90.0)
    {
        _highestLatitude = highestLatitude;
    }
    else
    {
        // Invalid latitude value, raise an exception.
        @throw [NSException exceptionWithName:@"InvalidCoordinatesException"
                                       reason:@"highestLatitude MUST be between [-90.0, +90.0]"
                                     userInfo:nil];
    }
}

- (void)setHighestLongitude:(double)highestLongitude
{
    // We need to check that longitude is in the valid range before setting it.
    if (-180.0 <= highestLongitude <= 180.0)
    {
        _highestLongitude = highestLongitude;
    }
    else
    {
        // Invalid longitude value, raise an exception.
        @throw [NSException exceptionWithName:@"InvalidCoordinatesException"
                                       reason:@"highestLongitude MUST be between [-180.0, +180.0]"
                                     userInfo:nil];
    }
}

#pragma mark - INIT

// Designated init
- (instancetype)initWithLowestLatitude:(double)lowestLatitude
                       lowestLongitude:(double)lowestLongitude
                       highestLatitude:(double)highestLatitude
                      highestLongitude:(double)highestLongitude
{
    if ((lowestLatitude > highestLatitude) || (lowestLongitude > highestLongitude))
    {
        @throw [NSException exceptionWithName:@"InvalidCoordinatesException"
                                       reason:@"lowestLatitude must be lower than highestLatitude and "
                                       @"lowestLongitude must be lower than highestLongitude"
                                     userInfo:nil];
    }

    self = [super init];

    if (self)
    {
        self.lowestLatitude = lowestLatitude;
        self.lowestLongitude = lowestLongitude;
        self.highestLatitude = highestLatitude;
        self.highestLongitude = highestLongitude;
    }

    return self;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [self initWithLowestLatitude:-0.1 lowestLongitude:-0.1 highestLatitude:0.1 highestLongitude:0.1];
    }

    return self;
}

#pragma mark - Utility

- (MKCoordinateSpan)span
{
    double latitudeDelta = fabs(self.highestLatitude - self.lowestLatitude);
    double longitudedDelta = fabs(self.highestLongitude - self.lowestLongitude);

    return MKCoordinateSpanMake(latitudeDelta, longitudedDelta);
}

- (NSString *)overpassString
{
    // This method converts the BBox to a string usable in the OverpassQL queries.

    NSString *overpassString = [NSString stringWithFormat:@"(%f,%f,%f,%f)", self.lowestLatitude, self.lowestLongitude,
                                                          self.highestLatitude, self.highestLongitude];

    return overpassString;
}

+ (OverpassBBox *)maxBoundingBox
{
    return
        [[OverpassBBox alloc] initWithLowestLatitude:0.0 lowestLongitude:0.0 highestLatitude:0.5 highestLongitude:0.5];
}

#pragma mark - Equality and Comparison

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }

    OverpassBBox *otherBBOX = (OverpassBBox *)object;

    BOOL isLatitudeEqual =
        (self.lowestLatitude == otherBBOX.lowestLatitude) && (self.highestLatitude == otherBBOX.highestLatitude);

    BOOL isLongitudeEqual =
        (self.lowestLongitude == otherBBOX.lowestLongitude) && (self.highestLongitude == otherBBOX.highestLongitude);

    return isLatitudeEqual && isLongitudeEqual;
}

- (NSComparisonResult)compare:(OverpassBBox *)otherBBOX
{
    double thisArea = [self span].latitudeDelta * [self span].longitudeDelta;
    double otherArea = [otherBBOX span].latitudeDelta * [otherBBOX span].longitudeDelta;

    if (thisArea > otherArea)
    {
        return NSOrderedDescending;
    }

    if (thisArea < otherArea)
    {
        return NSOrderedAscending;
    }

    return NSOrderedSame;
}

@end
