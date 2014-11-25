//
//  OverpassAPI.m
//  AmenityHunter
//
//  Created by emi on 07/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "OverpassAPI.h"

NSString *const gOverpassDataFetchedNotification = @"OverpassDataFetchedNotification";

static NSString *const overpassEndpoint = @"http://overpass-api.de/api/interpreter?data=";
static NSString *const overpassFormat = @"json";

// This parameter indicates the maximum allowed runtime for the query in seconds, as expected by the
// user. If the query runs longer than this time, the server may abort the query with a timeout. The
// second effect is, the higher this value, the more probably the server rejects the query before
// executing it.
static int const overpassServerTimeout = 5;

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
        postNotification:[NSNotification notificationWithName:gOverpassDataFetchedNotification
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
        NSURLSessionConfiguration *sessionConfiguration =
            [NSURLSessionConfiguration ephemeralSessionConfiguration];

        sessionConfiguration.timeoutIntervalForResource = overpassServerTimeout + 2;

        _ephemeralSession = [NSURLSession
            sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    }

    return self;
}

#pragma mark - INSTANCE METHODS

- (void)startFetchingAmenitiesData
{
    NSString *requestString =
        [NSString stringWithFormat:@"%@[out:%@][timeout:%d];node[\"amenity\"=\"%@\"]%@;out body;",
                                   overpassEndpoint, overpassFormat, overpassServerTimeout,
                                   self.amenityType, [self.boundingBox overpassString]];

#if DEBUG
    NSLog(@"START FETCHING REQUEST:%@", requestString);
#endif

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
                  else
                  {
                      #if DEBUG
                      NSLog(@"ERROR while fetching with request %@", requestString);
                      NSLog(@"%@", error.userInfo);
                      #endif
                  }
              }] resume];
}

@end
