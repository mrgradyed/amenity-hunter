//
//  AmenityAnnotation.m
//  AmenityHunter
//
//  Created by emi on 24/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "AmenityAnnotation.h"

NSString *const gAmenityAnnotationViewReuseIdentifier = @"AmenityAnnotationViewReuseIdentifier";

@implementation AmenityAnnotation

#pragma mark - DESIGNATED INIT

- (instancetype)initWithLatitude:(double)latitude Longitude:(double)longitude
{
    self = [super init];

    if (self)
    {
        CLLocationCoordinate2D amenityPosition = CLLocationCoordinate2DMake(latitude, longitude);

        self.coordinate = amenityPosition;
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
