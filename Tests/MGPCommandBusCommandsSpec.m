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
#import "MGPCommandBus+Private.h"
#import "TestHelpers.h"


SpecBegin(MGPCommandBus)

describe(@"Command Bus", ^{
    
    __block MGPCommandBus *testBus = nil;
    
    beforeEach(^{
        testBus = [MGPCommandBus new];
        [[testBus queue] setSuspended:YES];
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

            __block TestSender *testSender = nil;
            
            describe(@"callbacks", ^{
                
                beforeAll(^{
                    [testBus registerCommandHandlerClass:[TestCommandHandler class]];
                    
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
                __block TestSender *childSender = nil;
                
                beforeEach(^{
                    [[testBus queue] setSuspended:NO];
                    
                    childCommand = [TestCommand new];
                    testCommand = [TestCommand new];
                    
                    testSender = [TestSender new];
                    childSender = [TestSender new];
                    
                    childCommand.sender = childSender;
                    childCommand.parentCommand = testCommand;
                    testCommand.sender = testSender;
                });
                
                afterEach(^{
                    [[testBus queue] setSuspended:YES];
                });
                
                describe(@"executing successfully", ^{
                    beforeEach(^{
                        [testBus registerCommandHandlerClass:[TestCommandHandler class]];
                        
                        [testBus execute:childCommand];
                        [testBus execute:testCommand];
                    });

                    it(@"should callback before executing", ^{
                        expect(testSender.willStartExectingCalled).will.beTruthy();
                        expect(childSender.willStartExectingCalled).will.beTruthy();
                    });

                    it(@"should call success callback", ^{
                        expect(testSender.didCompleteSuccessfullyCalled).will.beTruthy();
                        expect(childSender.didCompleteSuccessfullyCalled).will.beTruthy();
                    });
                    
                    it(@"should not call fail callback", ^{
                        expect(testSender.didComleteWithFailureCalled).will.beFalsy();
                        expect(childSender.didComleteWithFailureCalled).will.beFalsy();
                    });
                });
                
                describe(@"executing failure", ^{
                    beforeEach(^{
                        [testBus registerCommandHandlerClass:[FailAllCommandsHandler class]];
                        
                        [testBus execute:childCommand];
                        [testBus execute:testCommand];
                    });
                    
                    it(@"should callback before executing", ^{
                        expect(testSender.willStartExectingCalled).will.beTruthy();
                        expect(childSender.willStartExectingCalled).will.beTruthy();
                    });
                    
                    it(@"should not call success callback", ^{
                        expect(testSender.didCompleteSuccessfullyCalled).will.beFalsy();
                        expect(childSender.didCompleteSuccessfullyCalled).will.beFalsy();
                    });
                    
                    it(@"should call fail callback", ^{
                        expect(testSender.didComleteWithFailureCalled).will.beTruthy();
                        expect(childSender.didComleteWithFailureCalled).will.beTruthy();
                    });
                });
                
                describe(@"child command failed to execute", ^{
                    beforeEach(^{
                        SingleCommandHandler *successHandler = [SingleCommandHandler handlerForCommand:testCommand];
                        successHandler.shouldFail = NO;
                        SingleCommandHandler *failHandler = [SingleCommandHandler handlerForCommand:childCommand];
                        failHandler.shouldFail = YES;
                        
                        [testBus registerCommandHandler:successHandler];
                        [testBus registerCommandHandler:failHandler];
                        
                        [testBus execute:testCommand];
                        [testBus execute:childCommand];
                    });
                    
                    it(@"should callback before executing", ^{
                        expect(testSender.willStartExectingCalled).will.beTruthy();
                        expect(childSender.willStartExectingCalled).will.beTruthy();
                    });
                    
                    it(@"should not call success callback", ^{
                        expect(testSender.didCompleteSuccessfullyCalled).will.beTruthy();
                        expect(childSender.didCompleteSuccessfullyCalled).will.beFalsy();
                    });
                    
                    it(@"should call fail callback", ^{
                        expect(testSender.didComleteWithFailureCalled).will.beFalsy();
                        expect(childSender.didComleteWithFailureCalled).will.beTruthy();
                    });
                });
            });
            
            describe(@"order", ^{
                __block TimeStampTestSender *firstCommandSender = nil;
                __block TimeStampTestSender *secondCommandSender = nil;
                
                beforeEach(^{
                    
                    firstCommandSender = [TimeStampTestSender new];
                    secondCommandSender = [TimeStampTestSender new];
                    
                    [testBus registerCommandHandlerClass:[TestCommandHandler class]];
                    [[testBus queue] setSuspended:NO];
                });
                
                afterEach(^{
                    [[testBus queue] setSuspended:YES];
                });
                
                it(@"should execute before command", ^{
                    id<MGPCommand> firstCommand = [TestCommand new];
                    [firstCommand setSender:firstCommandSender];
                    [testCommand setSender:secondCommandSender];
                    
                    [testBus execute:firstCommand before:testCommand];
                    
                    expect([firstCommandSender isBefore:secondCommandSender]).will.beTruthy();

                });
                
                it(@"should execute after command", ^{
                    id<MGPCommand> secondCommand = [TestCommand new];
                    [secondCommand setSender:secondCommandSender];
                    [testCommand setSender:firstCommandSender];
                    
                    [testBus execute:secondCommand after:testCommand];
                    
                    expect([firstCommandSender isBefore:secondCommandSender]).will.beTruthy();
                });
            });
        });
    });
});

SpecEnd

