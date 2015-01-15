//
//  OverpassAPITests.m
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
//  Created by emi on 27/11/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "SharedOverpassAPI.h"

@interface OverpassAPITests : XCTestCase

@end

@implementation OverpassAPITests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each
    // test method in the
    // class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each
    // test method in the
    // class.
    [super tearDown];
}

- (void)testSingleton
{
    // Singleton class should return an exception when receiving init message.
    XCTAssertThrows([[SharedOverpassAPI alloc] init]);

    // Singleton class must have only one instance.
    // Thus, shareInstance must return always the same object.
    XCTAssertTrue([SharedOverpassAPI sharedInstance] == [SharedOverpassAPI sharedInstance]);
}

@end
