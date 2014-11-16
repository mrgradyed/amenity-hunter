//
//  OverpassAPI.m
//  AmenityHunter
//
//  Created by emi on 07/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "OverpassAPI.h"
#import "OverpassBBox.h"

static NSString *overpassEndpoint = @"http://overpass-api.de/api/interpreter?data=";
static NSString *overpassFormat = @"json";
static int overpassTimeout = 25;

@interface OverpassAPI ()

@property(nonatomic, strong) NSURLSession *ephemeralSession;
@property(nonatomic, strong) NSDictionary *lastFetchedData;
@property(nonatomic, strong) NSString *lastRequest;

@end

@implementation OverpassAPI

#pragma mark - ACCESSORS

- (void)setLastFetchedData:(NSDictionary *)lastFetchedData
{
    _lastFetchedData = lastFetchedData;

    [[NSNotificationCenter defaultCenter]
        postNotification:[NSNotification notificationWithName:@"OverpassDataReady"
                                                       object:self
                                                     userInfo:_lastFetchedData]];
}

#pragma mark - CLASS METHODS

+ (instancetype)sharedInstance
{
    // The class method which actually creates the singleton.

    // The static variable which will hold the single and only instance of this
    // class.

    static OverpassAPI *sharedOverpassAPI;

    static dispatch_once_t blockHasCompleted;

    // Create an instance of this class once and only once for the lifetime of the
    // application.

    dispatch_once(&blockHasCompleted, ^{ sharedOverpassAPI = [[self alloc] initActually]; });

    return sharedOverpassAPI;
}

#pragma mark - INIT

- (instancetype)init
{
    // Return an exception if someone try to use the default init
    // instead of creating a singleton by using the class method.

    @throw [NSException exceptionWithName:@"SingletonException"
                                   reason:@"Please use: [OverpassAPI sharedInstance] instead."
                                 userInfo:nil];

    return nil;
}

- (instancetype)initActually
{
    // The actual (private) init method used by the class method to create a
    // singleton.

    self = [super init];

    if (self)
    {
        _ephemeralSession = [NSURLSession
            sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];

        _boundingBox = [[OverpassBBox alloc] initWithLowestLatitude:-2.0
                                                    lowestLongitude:-2.0
                                                    highestLatitude:2.0
                                                   highestLongitude:2.0];
    }

    return self;
}

#pragma mark - INSTANCE METHODS

- (void)startFetching
{
    NSString *requestString =
        [NSString stringWithFormat:@"%@[out:%@][timeout:%d];node[\"amenity\"=\"%@\"]%@;out body;",
                                   overpassEndpoint, overpassFormat, overpassTimeout,
                                   self.amenityType, [self.boundingBox overpassString]];

    if ([self.lastRequest isEqualToString:requestString])
    {
        self.lastFetchedData = self.lastFetchedData;
    }

    NSURL *requestURL =
        [NSURL URLWithString:[requestString
                                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];

    [[self.ephemeralSession
        downloadTaskWithRequest:request
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {

                  if (!error)
                  {
                      self.lastFetchedData = [NSJSONSerialization
                          JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                     options:0
                                       error:nil];
                  }

              }] resume];
}

@end
