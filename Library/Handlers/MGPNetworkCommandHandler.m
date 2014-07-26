//
//  OPNetworkCommandHandler.m
//  Committed
//
//  Created by Saul Mora on 4/24/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPNetworkCommandHandler+Private.h"
#import "KSReachability.h"
#import "MGPHTTPCommand.h"

static void const * MGPNetworkCommandHandlerObservingContext = &MGPNetworkCommandHandlerObservingContext;

@interface MGPNetworkCommandHandler ()

@property (nonatomic, strong) KSReachability *reachability;
@property (nonatomic, strong) NSOperationQueue *processingQueue;

@end

@implementation MGPNetworkCommandHandler

- (instancetype) init;
{
    return [self initWithReachability:[KSReachability reachabilityToHost:@"www.apple.com"]];
}

- (instancetype) initWithReachability:(KSReachability *)reachability;
{
    self = [super init];
    if (self)
    {
        self.reachability = reachability;
    }
    return self;
}

- (void) setReachability:(KSReachability *)reachability;
{
    [_reachability removeObserver:self
                       forKeyPath:@"reachable"
                          context:&MGPNetworkCommandHandlerObservingContext];
    _reachability = reachability;
    [_reachability addObserver:self
                    forKeyPath:@"reachable"
                       options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                       context:&MGPNetworkCommandHandlerObservingContext];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (context == MGPNetworkCommandHandlerObservingContext)
    {
        id newReachabilityValue = [change valueForKey:NSKeyValueChangeNewKey];

        if (![[NSNull null] isEqual:newReachabilityValue])
        {
            [self reachabilityDidChangeTo:[newReachabilityValue boolValue]];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) reachabilityDidChangeTo:(BOOL)isReachable;
{
    self.enabled = isReachable;
}

- (NSOperationQueue *) processingQueue;
{
    if (_processingQueue == nil)
    {
        _processingQueue = [[NSOperationQueue alloc] init];
    }
    return _processingQueue;
}

- (NSURLSession *) session;
{
    if (_session == nil)
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPShouldSetCookies = NO;
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:nil
                                            delegateQueue:[self processingQueue]];
    }
    return _session;
}

- (NSString *) userAgent;
{
    return @"MGPCommandHandler (NSURLSession)";
}

- (NSString *) appVersion;
{
    return @"No Version Specified";
}

- (BOOL) canHandleCommand:(id<MGPCommand>)command;
{
    NSString *message = [NSString stringWithFormat:@"Must Implement %@ in Subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"Method Not Implemented" reason:message userInfo:nil];
    return NO;
}

@end


