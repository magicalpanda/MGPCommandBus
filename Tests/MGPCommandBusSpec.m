//
//  IKBCommandBusSpec.m
//  IKBCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "Specta.h"

#define EXP_SHORTHAND
#import "Expecta.h"
#import "MGPCommandBus.h"
#import "MGPCommandBus+Extension.h"

@interface NSNumber (PandaKitAdditions)
- (void) times:(void(^)(void))block;
@end

@interface TestSender : NSObject<MGPCommandCallback>

@property (assign) BOOL willStartExectingCalled;
@property (assign) BOOL didCompleteSuccessfullyCalled;
@property (assign) BOOL didComleteWithFailureCalled;
@property (copy) NSError *error;

@end

@interface TestCommand : NSObject <MGPCommand>

@end

@interface TestCommandHandler : NSObject <MGPCommandHandler>

@end

@interface BoringCommandHandler : NSObject <MGPCommandHandler>

@end

@interface TestOperationCounter : NSObject

@property (nonatomic, assign) NSInteger preExecuteCount;
@property (nonatomic, assign) NSInteger postExecuteCount;
@property (nonatomic, readonly) NSInteger operationCountDelta;
- (void)execute: (id <MGPCommand>)command onBus: (MGPCommandBus *)bus;

@end

SpecBegin(IKBCommandBus)

describe(@"Command Bus", ^{
    
    __block MGPCommandBus *testBus = nil;
    
    beforeEach(^{
        testBus = [MGPCommandBus new];
        [[testBus queue] setSuspended:YES];
    });
    
    describe(@"handlers", ^{
       
        describe(@"registering", ^{
            
            context(@"one handler", ^{
                beforeEach(^{
                    [testBus registerCommandHandler:[TestCommandHandler new]];
                });
                
                it(@"should be registered", ^{
                    expect([testBus handlers]).to.haveCountOf(1);
                });
            });
            
            context(@"mutliple handlers of different classes", ^{
                beforeEach(^{
                    [testBus registerCommandHandler:[TestCommandHandler new]];
                    [testBus registerCommandHandler:[BoringCommandHandler new]];
                });
                
                it(@"should register all handlers", ^{
                    expect([testBus handlers]).to.haveCountOf(2);
                });
            });
            
            context(@"by class", ^{
               
                beforeEach(^{
                    [testBus registerCommandHandlerClass:[TestCommandHandler class]];
                });
                
                it(@"should be registered", ^{
                    expect([testBus handlers]).to.haveCountOf(1);
                });
            });

            context(@"multiple hanlder instances of the same class", ^{
                NSInteger numberOfHandlers = 2;
                
                beforeEach(^{
                    [@(numberOfHandlers) times:^{
                        [testBus registerCommandHandler:[TestCommandHandler new]];
                    }];
                });
                
                it(@"should register all handlers", ^{
                    expect([testBus handlers]).to.haveCountOf(numberOfHandlers);
                });
            });
        });
    });
    
    describe(@"commands", ^{

        __block TestCommand *testCommand = nil;
        __block TestOperationCounter *counter = nil;
        
        describe(@"queuing", ^{
            
            beforeEach(^{
                testCommand = [TestCommand new];
                counter = [TestOperationCounter new];
            });
            
            describe(@"without a handler", ^{
                
                it(@"should not be added to the bus", ^{
                    [counter execute:testCommand onBus:testBus];
                    
                    expect(counter.operationCountDelta).to.equal(0);
                });
                
                it(@"should not be handled", ^{
                    BOOL wasHandled = [testBus execute:testCommand];
                    expect(wasHandled).to.beFalsy();
                });
            });
            
            describe(@"with uninterested handler", ^{
                
                beforeEach(^{
                    [testBus registerCommandHandler:[BoringCommandHandler new]];
                });
                
                it(@"should not be handled", ^{
                    [counter execute:testCommand onBus:testBus];
                    expect(counter.operationCountDelta).to.equal(0);
                });
                
                it(@"should not be handled", ^{
                    BOOL wasHandled = [testBus execute:testCommand];
                    expect(wasHandled).to.beFalsy();
                });
            
            });
            
            describe(@"with a handler", ^{
               
                beforeEach(^{
                    id<MGPCommandHandler> testHandler = [TestCommandHandler new];
                    [testBus registerCommandHandler:testHandler];
                });
                
                it(@"should be added to the bus", ^{
                   [counter execute:testCommand onBus:testBus];
                    
                    expect(counter.operationCountDelta).to.equal(1);
                });
            });
            
            describe(@"multiple handlers for a command", ^{
                
                NSInteger numberOfCommands = 2;
                beforeEach(^{
                    [@(numberOfCommands) times:^{
                        [testBus registerCommandHandler:[TestCommandHandler new]];
                    }];
                });
                
                it(@"should be added to the bus", ^{
                    [counter execute:testCommand onBus:testBus];
                    
                    expect(counter.operationCountDelta).to.equal(numberOfCommands);
                });
                
                it(@"should be handled", ^{
                    BOOL wasHandled = [testBus execute:testCommand];
                    expect(wasHandled).to.beTruthy();
                });
            });        
        });
        
        describe(@"executing", ^{

            beforeEach(^{
                [testBus registerCommandHandlerClass:[TestCommandHandler class]];
            });
            
            describe(@"callbacks", ^{
                
                __block TestSender *testSender = nil;
                
                beforeAll(^{
                    testSender = [TestSender new];
                    testCommand = [TestCommand new];
                    testCommand.sender = testSender;
                    [[testBus queue] setSuspended:NO];
                    [testBus execute:testCommand];
                });
                
                afterAll(^{
                    [[testBus queue] setSuspended:YES];
                    [testBus removeAllCommands];
                });
                
                it(@"should callback before executing", ^{
                    expect(testSender.willStartExectingCalled).will.beTruthy();
                });
                
                it(@"should callback after executing on success", ^{
                    expect(testSender.didCompleteSuccessfullyCalled).will.beTruthy();
                });
                
                it(@"should callback after executing on failure", ^{
                    expect(testSender.didComleteWithFailureCalled).will.beFalsy();
                });
            });
            
            describe(@"with child commands", ^{
                
                __block TestCommand *childCommand = nil;
                
                beforeAll(^{
                    childCommand = [TestCommand new];
                    testCommand = [TestCommand new];
                    childCommand.parentCommand = testCommand;
                });
                
                it(@"should callback before executing", ^{
                    
                });
                

                describe(@"executing successfully", ^{
                    it(@"should wait for child command to complete successfully, then callback", ^{
                        
                    });
                    
                });
                
                
                it(@"should callback after executing on failure", ^{
                    
                });
                //test adding to the pendingCOmmands
                //should return YES on execute
            });
        });
    });
});

SpecEnd

@implementation TestCommand

@synthesize parentCommand;
@synthesize childCommands;
@synthesize sender;

- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return self; }
- (void)encodeWithCoder:(NSCoder *)aCoder {}
@end

@implementation TestCommandHandler
- (BOOL)canHandleCommand:(id<MGPCommand>)command { return YES; }
- (BOOL)executeCommand:(id<MGPCommand>)command error:(NSError *__autoreleasing *)error { return YES; }
@end

@implementation BoringCommandHandler
- (BOOL)canHandleCommand:(id<MGPCommand>)command { return NO; }
- (BOOL)executeCommand:(id<MGPCommand>)command error:(NSError *__autoreleasing *)error { return NO; }
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

-(void)commandWillBegin:(id<MGPCommand>)command;
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