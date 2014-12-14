//
//  NetworIndicatorSharedController.h
//  AmenityHunter
//
//  Created by emi on 11/12/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkIndicatorSharedController : NSObject

#pragma mark - PUBLIC PROPERTIES

@property(nonatomic) NSInteger networkActivitiesCount;

#pragma mark - PUBLIC METHODS

- (void)networkActivityDidStart;

- (void)networkActivityDidStop;

+ (instancetype)sharedInstance;

@end
