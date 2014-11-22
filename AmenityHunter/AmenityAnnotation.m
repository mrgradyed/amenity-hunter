//
//  Amenity.m
//  AmenityHunter
//
//  Created by emi on 22/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "AmenityAnnotation.h"

@interface AmenityAnnotation ()

@property(nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation AmenityAnnotation

- (CLLocationCoordinate2D)coordinate
{
    _coordinate.latitude = self.latitude;
    _coordinate.longitude = self.longitude;

    return _coordinate;
}

- (void)setLatitude:(double)lowestLatitude
{
    // We need to check that latitude is in the valid range before setting it.
    if (-90.0 <= lowestLatitude <= 90.0)
    {
        _latitude = lowestLatitude;
    }
    else
    {
        // Invalid latitude value, raise an exception.
        @throw [NSException exceptionWithName:@"InvalidCoordinatesException"
                                       reason:@"lowestLatitude MUST be between [-90.0, 90.0]"
                                     userInfo:nil];
    }
}

- (void)setLongitude:(double)lowestLongitude
{
    // We need to check that longitude is in the valid range before setting it.
    if (-180.0 <= lowestLongitude <= 180.0)
    {
        _longitude = lowestLongitude;
    }
    else
    {
        // Invalid longitude value, raise an exception.
        @throw [NSException exceptionWithName:@"InvalidCoordinatesException"
                                       reason:@"lowestLongitude MUST be between [-180.0, 180.0]"
                                     userInfo:nil];
    }
}

// Designated init
- (instancetype)initWithLatitude:(double)latitude Longitude:(double)longitude
{
    self = [super init];

    if (self)
    {
        self.latitude = latitude;
        self.latitude = longitude;
    }

    return self;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self = [self initWithLatitude:0.0 Longitude:0.0];
    }

    return self;
}

@end
