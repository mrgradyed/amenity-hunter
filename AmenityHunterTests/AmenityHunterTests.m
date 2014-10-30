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

@interface AmenityHunterTests : XCTestCase

@end

@implementation AmenityHunterTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the
    // class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
    [super tearDown];
}

- (void)testOverpassBBoxCoordinates
{
    OverpassBBox *bbox = [[OverpassBBox alloc] initWithLowestLatitude:50.745
                                                      lowestLongitude:7.17
                                                      highestLatitude:50.75
                                                     highestLongitude:7.18];

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

    XCTAssertEqualObjects([bbox overpassString], @"(50.745, 7.17, 50.75, 7.18)");
}



@end
