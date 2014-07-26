//
//  MGPNetworkRequestHandler.m
//  Committed
//
//  Created by Saul Mora on 5/16/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPRequestHandler+Private.h"
#import "MGPHTTPImageCommand.h"
#import "MGPHTTPImageRequestHandler.h"
#import "MGPHTTPDataRequestHandler.h"

NSString *mgp_applicationBuildNumber(void);
NSString *mgp_applicationDisplayName(void);
NSString *mgp_applicationVersionString(void);
NSString *mgp_operatingSystemVersionString(void);

Class mgp_request_handler_type_for_command(MGPHTTPCommand *command)
{
    Class type = [MGPHTTPDataRequestHandler class];
    if ([command isKindOfClass:[MGPHTTPImageCommand class]])
    {
        type = [MGPHTTPImageRequestHandler class];
    }
    return type;
}

@implementation MGPHTTPRequestHandler

- (NSString *) description;
{
    return [NSString stringWithFormat:@"<%@: %p| %@, %zd>", NSStringFromClass([self class]), self, [self.task originalRequest], [self.task state]];
}

- (instancetype) initWithSession:(NSURLSession *)session command:(MGPHTTPCommand *)command;
{
    NSParameterAssert(session);
    NSParameterAssert(command);

    Class handlerType = mgp_request_handler_type_for_command(command);
    self = [[handlerType alloc] init];
    if (self)
    {
        self.session = session;
        self.command = command;
    }
    return self;
}

- (BOOL) isEqual:(id)object;
{
    return [object isKindOfClass:[self class]] && [object respondsToSelector:@selector(command)] && [[object command] isEqual:self.command];
}

- (void) sendRequestCompletion:(void(^)(BOOL,NSError *))completion;
{
    [self willBeginRequest];
    
    BOOL shouldSendRequest = YES;
    MGPHTTPCommand *command = self.command;

    if ([self.delegate respondsToSelector:@selector(handler:shouldBegin:)])
    {
        shouldSendRequest = [self.delegate handler:self shouldBegin:command];
    }
    if (shouldSendRequest)
    {
        [self.task resume];
        self.completion = completion;
        NSLog(@"Sent Request for Command: %@", command);
    }
    else if (completion)
    {
        NSLog(@"Not sending request %@", [self requestFromCommand:command]);
        completion(YES, nil);
    }
}

- (void) willBeginRequest;
{
    if ([self.delegate respondsToSelector:@selector(handler:willBeginCommand:)])
    {
        [self.delegate handler:self willBeginCommand:self.command];
    }
}

- (void) didCompleteRequest:(BOOL)success error:(NSError *)error;
{
    NSLog(@"Request Complete (%@) command: %@", success ? @"Success" : @"FAILED", self.command);
    if (self.completion)
    {
        self.completion(success, error);
    }

    if ([self.delegate respondsToSelector:@selector(handler:didCompleteCommand:error:)])
    {
        [self.delegate handler:self didCompleteCommand:self.command error:error];
    }
}

- (NSURLSessionTask *) task;
{
    if (_task == nil)
    {
        _task = [self createTaskForCommand:self.command];
    }
    return _task;
}

- (NSURLSessionTask *) createTaskForCommand:(MGPHTTPCommand *)command;
{
    return nil;
}

- (NSURLRequest *) requestFromCommand:(MGPHTTPCommand *)command;
{
    NSMutableURLRequest *signedRequest = [[command signedRequest] mutableCopy];

    NSString *userAgent = [signedRequest valueForHTTPHeaderField:@"User-Agent"];
    if ([userAgent length] == 0)
    {
        [signedRequest setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    }
    [signedRequest setValue:mgp_applicationBuildNumber() forHTTPHeaderField:@"X-App-Version"];

    return signedRequest;
}

- (id) deserializeResponse:(NSData *)response forCommand:(MGPHTTPCommand *)command;
{
    return [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
}

- (NSString *) userAgent;
{
    static dispatch_once_t onceToken;
    static NSString *userAgent = nil;
    dispatch_once(&onceToken, ^{
        NSString *applicationName = mgp_applicationDisplayName();
        NSString *applicationVersion = mgp_applicationVersionString();
        NSString *operatingSystemVersion = mgp_operatingSystemVersionString();

        userAgent = [NSString stringWithFormat:@"%@/%@ (%@)", applicationName, applicationVersion, operatingSystemVersion];
    });
    
    return userAgent;
}

@end

NSString *mgp_applicationBuildNumber(void)
{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    return [appInfo valueForKey:(id)kCFBundleVersionKey];
}

NSString *mgp_applicationDisplayName(void)
{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    return [appInfo valueForKey:(id)kCFBundleExecutableKey] ?:
    [appInfo valueForKey:(id)kCFBundleIdentifierKey];
}

NSString *mgp_applicationVersionString(void)
{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    return [appInfo valueForKey:@"CFBundleShortVersionString"];
}

NSString *mgp_operatingSystemVersionString(void)
{
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *osVersion = [processInfo operatingSystemVersionString];
#if TARGET_OS_IPHONE || TARGET_IOS_SIMULATOR
    NSString *osName = @"iOS";
#else
    NSString *osName = @"Mac OS X;
#endif

    return [NSString stringWithFormat:@"%@ %@", osName, osVersion];
}
