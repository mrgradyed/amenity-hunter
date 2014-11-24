//
//  AmenityAnnotation.h
//  AmenityHunter
//
//  Created by emi on 24/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import <MapKit/MapKit.h>

extern NSString *const gAmenityAnnotationViewReuseIdentifier;

@interface AmenityAnnotation : MKPointAnnotation

#pragma mark - DESIGNATED INIT

- (instancetype)initWithLatitude:(double)latitude Longitude:(double)longitude;

@end
