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

extern NSString *const gOverpassDataFetchedNotification;

@interface OverpassAPI : NSObject

@property(nonatomic, strong) NSString *amenityType;
@property(nonatomic, strong) OverpassBBox *boundingBox;

// This method creates an instance of this class once and only once
// for the entire lifetime of the application.
// Do NOT use the init method to create an instance, it will just return an exception.
+ (instancetype)sharedInstance;

- (void)startFetchingAmenitiesData;

@end
