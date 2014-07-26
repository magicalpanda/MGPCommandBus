//
//  MGPHTTPCommandHandler.m
//  Committed
//
//  Created by Saul Mora on 5/16/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPCommandHandler+Private.h"
#import "MGPHTTPCommand.h"
#import "MGPHTTPRequestHandler.h"

@interface MGPHTTPCommandHandler ()

@property (nonatomic, strong) NSMutableSet *executingRequests;
@property (nonatomic, strong) NSMutableSet *commandTypesToHandle;

@end

@implementation MGPHTTPCommandHandler

- (id) init;
{
    self = [super init];
    if (self)
    {
        self.executingRequests = [NSMutableSet set];
    }
    return self;
}

- (NSMutableSet *) commandTypesToHandle;
{
    if (_commandTypesToHandle == nil)
    {
        _commandTypesToHandle = [NSMutableSet set];
        [_commandTypesToHandle addObject:[MGPHTTPCommand class]];
    }
    return _commandTypesToHandle;
}

- (void) registerCommandType:(Class)commandType;
{
    [[self commandTypesToHandle] addObject:[commandType class]];
}

- (BOOL) canHandleCommand:(id<MGPCommand>)command;
{
    return [[self commandTypesToHandle] containsObject:[command class]];
}

- (void) executeCommand:(MGPHTTPCommand *)command completion:(void (^)(BOOL,NSError *))completion;
{
    MGPHTTPRequestHandler *requestHandler = [[MGPHTTPRequestHandler alloc] initWithSession:self.session command:command];
    requestHandler.delegate = self;

    static dispatch_queue_t sendQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sendQueue = dispatch_queue_create("com.magicalpanda.http_request_queue", DISPATCH_QUEUE_SERIAL);
    });
//    @synchronized(self.executingRequests)
    dispatch_async(sendQueue, ^{
        {
            if ([self.executingRequests containsObject:requestHandler])
            {
                NSLog(@"!!! Request pending for command %@", command);
                if (completion) completion(YES, nil);
            }
            else
            {
                [self.executingRequests addObject:requestHandler];
                [requestHandler sendRequestCompletion:completion];
            }
        }
    });
}

- (void) handler:(MGPHTTPRequestHandler *)handler didCompleteCommand:(MGPHTTPCommand *)command error:(NSError *)error;
{
    [self.executingRequests removeObject:handler];
    if ([self.executingRequests count] == 0)
    {
        [self commandQueueDidEmpty];
    }
}

- (void) commandQueueDidEmpty;
{
    
}

@end
