//
//  TestHelpers.m
//  MGPCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "TestHelpers.h"
#import "MGPCommandBus+Private.h"

@implementation TestCommand

@end

@implementation TestCommandHandler
- (BOOL)canHandleCommand:(id<MGPCommand>)command { return YES; }
- (BOOL)executeCommand:(id<MGPCommand>)command error:(NSError *__autoreleasing *)error { return YES; }
@end

@implementation BoringCommandHandler
- (BOOL)canHandleCommand:(id<MGPCommand>)command { return NO; }
- (BOOL)executeCommand:(id<MGPCommand>)command error:(NSError *__autoreleasing *)error { return NO; }
@end

@implementation FailAllCommandsHandler

-(BOOL)canHandleCommand:(id<MGPCommand>)command { return YES; }
-(BOOL)executeCommand:(id<MGPCommand>)command error:(NSError *__autoreleasing *)error { return NO; };

@end

@implementation SingleCommandHandler
{
    id<MGPCommand> _command;
}

+ (instancetype)handlerForCommand:(id<MGPCommand>)command;
{
    return [[self alloc] initWithCommand:command];
}
-(id)initWithCommand:(id<MGPCommand>)command;
{
    self = [super init];
    _command = command;
    return self;
}
-(BOOL)canHandleCommand:(id<MGPCommand>)command;
{
    return command == _command;
}
-(BOOL)executeCommand:(id<MGPCommand>)command error:(NSError *__autoreleasing *)error;
{
    return !self.shouldFail;
};

@end
@implementation TestOperationCounter

- (void)execute:(id<MGPCommand>)command onBus:(MGPCommandBus *)bus
{
    self.preExecuteCount = [[bus queue] operationCount];
    [bus execute: command];
    self.postExecuteCount = [[bus queue] operationCount];
}

- (NSInteger)operationCountDelta { return self.postExecuteCount - self.preExecuteCount; }

@end

@implementation TestSender

-(void)commandWillStart:(id<MGPCommand>)command;
{
    self.willStartExectingCalled = YES;
}

-(void)commandDidComplete:(id<MGPCommand>)command;
{
    self.didCompleteSuccessfullyCalled = YES;
}

-(void)commandDidFail:(id<MGPCommand>)command error:(NSError *)error;
{
    self.didComleteWithFailureCalled = YES;
    self.error = error;
}

@end

@implementation TimeStampTestSender

-(void)commandWillStart:(id<MGPCommand>)command;
{
    self.startTime = [NSDate date];
}

-(void)commandDidComplete:(id<MGPCommand>)command;
{
    self.endTime = [NSDate date];
}

-(void)commandDidFail:(id<MGPCommand>)command error:(NSError *)error;
{
    self.endTime = [NSDate date];
}

-(BOOL)isBefore:(TimeStampTestSender *)other;
{
    if (self == other) { return NO; }
    
    NSComparisonResult startTimeCompare = [self.startTime compare:other.startTime];
    NSComparisonResult endTimeCompare = [self.endTime compare:other.endTime];
    
    return startTimeCompare == NSOrderedDescending && endTimeCompare == NSOrderedDescending;
}

@end

@implementation NSNumber (PandaKitAdditions)

- (void) times:(void(^)(void))block;
{
    NSParameterAssert(block);
    for (NSInteger i = 0; i < [self integerValue]; i++)
    {
        block();
    }
}

@end