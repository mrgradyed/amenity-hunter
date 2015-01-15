//
//  AmenityAnnotation.h
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

#import <MapKit/MapKit.h>

extern NSString *const gAmenityAnnotationViewReuseIdentifier;

@interface AmenityAnnotation : MKPointAnnotation

#pragma mark - DESIGNATED INIT

- (instancetype)initWithLatitude:(double)latitude Longitude:(double)longitude;

@end
