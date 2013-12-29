//
//  TestHelpers.h
//  MGPCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import <Foundation/Foundation.h>
#import "MGPCommand.h"
#import "MGPCommandHandler.h"
#import "MGPCommandBus.h"


@interface NSNumber (PandaKitAdditions)
- (void) times:(void(^)(void))block;
@end

@interface TestSender : NSObject<MGPCommandCallback>

@property (assign) BOOL willStartExectingCalled;
@property (assign) BOOL didCompleteSuccessfullyCalled;
@property (assign) BOOL didComleteWithFailureCalled;
@property (copy) NSError *error;

@end

@interface TimeStampTestSender : NSObject<MGPCommandCallback>

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

- (BOOL) isBefore:(TimeStampTestSender *)other;

@end

@interface TestCommand : MGPCommand

@end

@interface TestCommandHandler : NSObject<MGPCommandHandler>

@end

@interface BoringCommandHandler : NSObject<MGPCommandHandler>

@end

@interface FailAllCommandsHandler : NSObject<MGPCommandHandler>

@end

@interface SingleCommandHandler : NSObject<MGPCommandHandler>

@property (nonatomic, assign) BOOL shouldFail;

+ (instancetype) handlerForCommand:(id<MGPCommand>)command;

@end

@interface TestOperationCounter : NSObject

@property (nonatomic, assign) NSInteger preExecuteCount;
@property (nonatomic, assign) NSInteger postExecuteCount;
@property (nonatomic, readonly) NSInteger operationCountDelta;
- (void)execute: (id <MGPCommand>)command onBus: (MGPCommandBus *)bus;

@end
