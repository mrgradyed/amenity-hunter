//
//  OverpassAPI.h
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
//  Created by emi on 07/11/14.
//
//

#import <Foundation/Foundation.h>
#import "OverpassBBox.h"

extern NSString *const gOverpassDataFetchedNotification;
extern NSString *const gOverpassFetchingFailedNotification;

@interface SharedOverpassAPI : NSObject

@property(nonatomic, strong) NSString *amenityType;
@property(nonatomic, strong) OverpassBBox *boundingBox;

// This method creates an instance of this class once and only once
// for the entire lifetime of the application.
// Do NOT use the init method to create an instance, it will just return an
// exception.
+ (instancetype)sharedInstance;

- (void)startFetchingAmenitiesData;

@end
