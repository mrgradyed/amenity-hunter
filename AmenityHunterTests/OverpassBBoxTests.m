//
//  AmenityHunterTests.m
//  AmenityHunterTests
//
//  Created by emi on 30/10/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OverpassBBox.h"

@interface OverpassBBoxTests : XCTestCase

@end

@implementation OverpassBBoxTests

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

- (void)testOverpassBBoxCoordinates
{
    OverpassBBox *bbox = [[OverpassBBox alloc] initWithLowestLatitude:50.745
                                                      lowestLongitude:7.17
                                                      highestLatitude:50.75
                                                     highestLongitude:7.18];

    // Test if the coordinates are the ones set during init.
    XCTAssertEqual(bbox.lowestLatitude, 50.745);
    XCTAssertEqual(bbox.lowestLongitude, 7.17);
    XCTAssertEqual(bbox.highestLatitude, 50.75);
    XCTAssertEqual(bbox.highestLongitude, 7.18);
}

- (void)testOverpassBBoxString
{
    OverpassBBox *bbox = [[OverpassBBox alloc] initWithLowestLatitude:50.745
                                                      lowestLongitude:7.17
                                                      highestLatitude:50.75
                                                     highestLongitude:7.18];

    // Test if the bbox is properly converted to a string for use in OverpassQL
    // queries.
    XCTAssertEqualObjects([bbox overpassString], @"(50.745000,7.170000,50.750000,7.180000)");
}

- (void)testOverpassBBoxInit
{
    // Test if exception is thrown when initialising bbox with lowest latitude
    // greater than highest latitude.
    XCTAssertThrows([[OverpassBBox alloc] initWithLowestLatitude:2.0
                                                 lowestLongitude:1.0
                                                 highestLatitude:1.0
                                                highestLongitude:1.0]);

    // Test if exception is thrown when initialising bbox with lowest longitude
    // greater than highest longitude.
    XCTAssertThrows([[OverpassBBox alloc] initWithLowestLatitude:1.0
                                                 lowestLongitude:2.0
                                                 highestLatitude:1.0
                                                highestLongitude:1.0]);

    // Test if exception is thrown when initialising bbox with invalid latitude
    // value.
    XCTAssertThrows([[OverpassBBox alloc] initWithLowestLatitude:91.0
                                                 lowestLongitude:1.0
                                                 highestLatitude:1.0
                                                highestLongitude:1.0]);

    // Test if exception is thrown when initialising bbox with invalid longitude
    // value.
    XCTAssertThrows([[OverpassBBox alloc] initWithLowestLatitude:1.0
                                                 lowestLongitude:181.0
                                                 highestLatitude:1.0
                                                highestLongitude:1.0]);

    // Test if exception is NOT thrown when initialising bbox with extreme values.
    XCTAssertNoThrow([[OverpassBBox alloc] initWithLowestLatitude:-90.0
                                                  lowestLongitude:-180.0
                                                  highestLatitude:90.0
                                                 highestLongitude:180.0]);

    // Test if exception is NOT thrown when initialising bbox with equal values.
    XCTAssertNoThrow([[OverpassBBox alloc] initWithLowestLatitude:0
                                                  lowestLongitude:0
                                                  highestLatitude:0
                                                 highestLongitude:0]);
}

@end
