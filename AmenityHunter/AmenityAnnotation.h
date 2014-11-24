//
//  Amenity.h
//  AmenityHunter
//
//  Created by emi on 22/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

@import Foundation;
@import MapKit;

extern NSString *const gAmenityAnnotationViewReuseIdentifier;

@interface AmenityAnnotation : NSObject <MKAnnotation>

#pragma mark - MKAnnotation protocol

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property(nonatomic, readonly, copy) NSString *title;
@property(nonatomic, readonly, copy) NSString *subtitle;

#pragma mark - Public properties

@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

@property(nonatomic) NSString *name;
@property(nonatomic) NSString *type;

#pragma mark - Designated init

- (instancetype)initWithLatitude:(double)latitude Longitude:(double)longitude;

@end
