//
//  OverpassAPITests.m
//  AmenityHunter
//
//  Created by emi on 27/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
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
