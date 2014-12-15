//
//  OverpassAPI.m
//  AmenityHunter
//
//  Created by emi on 07/11/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "SharedOverpassAPI.h"
#import "NetworkIndicatorSharedController.h"

NSString *const gOverpassDataFetchedNotification = @"OverpassDataFetchedNotification";
NSString *const gOverpassFetchingFailedNotification = @"OverpassFetchingFailedNotification";

static NSString *const overpassEndpoint = @"http://overpass-api.de/api/interpreter?data=";
static NSString *const overpassFormat = @"json";

// This parameter indicates the maximum allowed runtime for the query in
// seconds, as expected by the
// user. If the query runs longer than this time, the server may abort the query
// with a timeout. The
// second effect is, the higher this value, the more probably the server rejects
// the query before
// executing it.
static int const overpassServerTimeout = 5;

@interface SharedOverpassAPI ()

@property(nonatomic, strong) NSURLSession *ephemeralSession;
@property(nonatomic, strong) NSDictionary *lastFetchedData;

// This dictionary is used as a small in-memory cache for a (very) limited
// number of recently
// fetched data. This should avoid requesting same data multiple times when the
// map does small
// region changes.
@property(nonatomic, strong) NSMutableDictionary *recentDataCache;

@end

@implementation SharedOverpassAPI

#pragma mark - ACCESSORS

- (NSDictionary *)recentDataCache
{
    if (!_recentDataCache)
    {
        _recentDataCache = [[NSMutableDictionary alloc] init];
    }
    return _recentDataCache;
}

- (void)setLastFetchedData:(NSMutableDictionary *)lastFetchedData
{
    _lastFetchedData = lastFetchedData;

    // Send a notification upon setting the latest retrieved data dictionary.
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

    static SharedOverpassAPI *sharedOverpassAPI;

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
                                   reason:@"Please use: [SharedOverpassAPI sharedInstance] instead."
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

        // Client timeout will be a little bit more than the server's one.
        sessionConfiguration.timeoutIntervalForResource = overpassServerTimeout + 2;

        _ephemeralSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }

    return self;
}

#pragma mark - INSTANCE METHODS

- (void)startFetchingAmenitiesData
{
    if (!self.amenityType || !self.boundingBox)
    {
        return;
    }

    // The request for fetching data via the Overpass API.
    NSString *requestString =
        [NSString stringWithFormat:@"%@[out:%@][timeout:%d];node[\"amenity\"=\"%@\"]%@;out body;",
                                   overpassEndpoint, overpassFormat, overpassServerTimeout,
                                   self.amenityType, [self.boundingBox overpassString]];

#if DEBUG
    NSLog(@"REQUEST URL:%@\n\n", requestString);
#endif

    // Check if request has been performed recently.
    NSDictionary *recentlyFetchedData = self.recentDataCache[requestString];

    if (recentlyFetchedData)
    {
        // Request has been already performed recently.
        // So use the recently fetched data without requesting again.
        self.lastFetchedData = recentlyFetchedData;

#if DEBUG
        NSLog(@"USING PREVIOUSLY FETCHED DATA.\n\n");
#endif

        return;
    }

    // Get the currently running (not completed) tasks and cancel them. The map
    // has changed region
    // and we are interested in getting the data just for the new current region.
    // The not completed
    // tasks for retrieving old regions' data can be cancelled.
    [self.ephemeralSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks,
                                                           NSArray *downloadTasks) {

        for (NSURLSessionDownloadTask *task in downloadTasks)
        {
            // Check if the old task is running (or is suspended).
            if (task.state != NSURLSessionTaskStateCompleted &&
                task.state != NSURLSessionTaskStateCanceling)
            {
                // Cancel the old task.
                [task cancel];

                #if DEBUG
                NSLog(@"CANCELING %@!\n\n", task.originalRequest.URL);
                #endif
            }
        }
    }];

    // The request URL for the new task.
    NSURL *requestURL =
        [NSURL URLWithString:[requestString
                                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];

    // A new task
    NSURLSessionDownloadTask *downloadTask = [self.ephemeralSession
        downloadTaskWithRequest:request
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {

                  [[NetworkIndicatorSharedController sharedInstance] networkActivityDidStop];

                  if (!error)
                  {
                      // Task completed!

                      // We want the recent requests and data cache small.
                      if ([self.recentDataCache count] > 20)
                      {
                          // If the recent requests dictionary has grown too much,
                          // reset it.
                          self.recentDataCache = nil;

                          #if DEBUG
                          NSLog(@"CACHE RESET.\n\n");
                          #endif
                      }

                      if (self.lastFetchedData)
                      {
                          // Put the retrieved JSON data in a dictionary.
                          self.lastFetchedData = [NSJSONSerialization
                              JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                         options:0
                                           error:nil];

                          // Adding response data to recent requests data cache.
                          self.recentDataCache[requestString] = self.lastFetchedData;

                      #if DEBUG
                          NSLog(@"NEW DATA HAS BEEN FETCHED!\n\n");
                      #endif
                      }
                      else
                      {
                          // Request succesful but no data returned. Wrong query syntax?
                          // Task failed. Let's notify this.
                          [[NSNotificationCenter defaultCenter]
                              postNotification:
                                  [NSNotification
                                      notificationWithName:gOverpassFetchingFailedNotification
                                                    object:self
                                                  userInfo:nil]];

                          #if DEBUG
                          NSLog(@"NULL DATA RECEIVED: %@\n\n", requestString);
                          #endif
                      }
                  }
                  else
                  {
                      // Task's code -999 stays for "cancelled".
                      if (error.code == -999)
                      {
                          // Task cancelled.
                          #if DEBUG
                          NSLog(@"REQUEST CANCELLED: %@\n\n", requestString);
                          #endif
                      }
                      else
                      {
                          // Task failed. Let's notify this.
                          [[NSNotificationCenter defaultCenter]
                              postNotification:
                                  [NSNotification
                                      notificationWithName:gOverpassFetchingFailedNotification
                                                    object:self
                                                  userInfo:nil]];
                      #if DEBUG
                          NSLog(@"REQUEST FAILED: %@\n\n", requestString);
                      #endif
                      }
                  }
              }];

    [downloadTask resume];

    [[NetworkIndicatorSharedController sharedInstance] networkActivityDidStart];
}

@end
