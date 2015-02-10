//
//  OverpassBBox.h
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

@import Foundation;
@import MapKit;

@interface OverpassBBox : NSObject

#pragma mark - COORDINATES

// Latitude is a decimal number between -90.0 and 90.0.
// Longitude is a decimal number between -180.0 and 180.0.

// lowest latitude, measured along a meridian from the nearest point
// on the Equator, negative in the
// Southern Hemisphere

@property(nonatomic, readonly) double lowestLatitude;

// lowest longitude, measured along a parallel from the nearest point on the Greenwich meridian,
// negative in the Western Hemisphere

@property(nonatomic, readonly) double lowestLongitude;

// highest latitude, measured along a meridian from the nearest point on the Equator, positive in
// the Northern Hemisphere

@property(nonatomic, readonly) double highestLatitude;

// highest longitude, measured along a parallel from the nearest point on the Greenwich meridian,
// positive in the Eastern Hemisphere

@property(nonatomic, readonly) MKCoordinateSpan span;

@property(nonatomic, readonly) double highestLongitude;

#pragma mark - DESIGNATED INIT

// This init raises InvalidCoordinatesException if the coordinates are not valid.
// Valid coordinates respect the following constraints:
// - Latitude must be a number between -90.0 and 90.0.
// - Longitude must be a number between -180.0 and 180.0.
// - lowestLatitude < highestLatitude
// - lowestLongitude < highestLongitude
- (instancetype)initWithLowestLatitude:(double)lowestLatitude
                       lowestLongitude:(double)lowestLongitude
                       highestLatitude:(double)highestLatitude
                      highestLongitude:(double)highestLongitude;

#pragma mark - PUBLIC METHODS

// This method converts the BBox to a string usable in the OverpassQL queries.
- (NSString *)overpassString;

- (NSComparisonResult)compare:(OverpassBBox *)otherBBOX;

+ (OverpassBBox *)maxBoundingBox;

@end
