//
//  GBRRenderer.m
//  Gibraltar iOS
//
//  Created by Saul Mora on 12/11/13.
//  Copyright (c) 2013 Magical Panda. All rights reserved.
//

#import "MGPSubCommandHandler+Private.h"

#ifdef TARGET_OS_IPHONE
#import "UIApplication+MGPCommandBus.h"
#elif defined(TARGET_OS_MAC)
#import "NSApplication+CommandBusAdditions.h"
#endif

id mgp_shared_application(void)
{
#ifdef TARGET_OS_IPHONE
    return [UIApplication sharedApplication];
#else
    return [NSApplication sharedApplication];
#endif
}

@interface MGPSubCommandHandler ()

@property (nonatomic, strong, readwrite) dispatch_queue_t completionSyncQueue;
@property (nonatomic, strong, readwrite) dispatch_semaphore_t childCommandsLock;

@property (nonatomic, strong, readwrite) NSSet *sentCommands;
@property (nonatomic, strong, readwrite) NSMutableSet *completedCommands;

@end

@implementation MGPSubCommandHandler

- (id)init;
{
    self = [super init];
    if (self)
    {
        _childCommandsLock = dispatch_semaphore_create(0);
        _completedCommands = [NSMutableSet set];        
        _completionSyncQueue = dispatch_queue_create("com.magicalpanda.gibraltar.commandQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (BOOL)canHandleCommand:(id<MGPCommand>)command;
{
    NSAssert(NO, @"%@ must be implemented in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
    return NO;
}

- (BOOL)executeCommand:(id<MGPCommand>)command error:(NSError *__autoreleasing *)error;
{
    NSAssert(NO, @"%@ must be implemented in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
    return NO;
}

- (BOOL) sendSubCommands:(NSSet *)subCommands;
{
    if ([subCommands count] == 0)
    {
        NSLog(@"No Subcommands to send: %@", self);
        return NO;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        id sharedApplication = mgp_shared_application();
        [sharedApplication sendCommands:subCommands from:self];
        
        self.sentCommands = [subCommands mutableCopy];
    });
    return YES;
}

- (void) waitForSubCommandsToComplete;
{
    dispatch_semaphore_wait(self.childCommandsLock, DISPATCH_TIME_FOREVER);
}

- (void) subCommandsDidComplete;
{
    dispatch_semaphore_signal(self.childCommandsLock);
}

- (void) commandDidComplete:(id<MGPCommand>)command;
{
    NSMutableSet *completedCommands = self.completedCommands;
    [completedCommands addObject:command];
    NSUInteger completedCount = [completedCommands count];
    
    dispatch_sync(self.completionSyncQueue, ^{
        
        NSUInteger sentCommandCount = [self.sentCommands count];
        CGFloat progress = (CGFloat)completedCount / sentCommandCount;
        
        [self commandHandlerDidCompleteCommand:command progress:progress];
        
        if (sentCommandCount == completedCount)
        {
            [self commandHandlerDidComplete];
            [self subCommandsDidComplete];
        }
    });
}

- (void) commandDidFail:(id<MGPCommand>)command error:(NSError *)error;
{
    [self commandHandlerDidFail:error];
}

- (void) commandHandlerDidFail:(NSError *)error;
{
    NSAssert(NO, @"%@ must be implemented in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void) commandHandlerDidCompleteCommand:(id<MGPCommand>)command progress:(float)progress;
{
    NSAssert(NO, @"%@ must be implemented in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void) commandHandlerDidComplete;
{
    NSAssert(NO, @"%@ must be implemented in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

@end
