//
//  OverpassAPI.h
//  AmenityHunter
//
//  Created by emi on 07/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Amenity;
@class OverpassBBox;

extern NSString *const gDataFetchedNotification;

@interface OverpassAPI : NSObject

@property(nonatomic, strong) NSString *amenityType;
@property(nonatomic, strong) OverpassBBox *boundingBox;

+ (instancetype)sharedInstance;

- (void)startFetching;

@end
