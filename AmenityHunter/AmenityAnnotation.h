//
//  Amenity.h
//  AmenityHunter
//
//  Created by emi on 22/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface AmenityAnnotation : NSObject <MKAnnotation>

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

// Designated init
- (instancetype)initWithLatitude:(double)latitude Longitude:(double)longitude;

@end
