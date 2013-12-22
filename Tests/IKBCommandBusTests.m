//Copyright (c) 2013 Graham Lee
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "IKBCommandBusTests.h"
#import "IKBCommandBus.h"
#import "IKBCommandBus+Extension.h"

@interface TestCommand : NSObject <IKBCommand>

@end

@interface TestCommandHandler : NSObject <IKBCommandHandler>

@end

@interface BoringCommandHandler : NSObject <IKBCommandHandler>

@end

@interface TestOperationCounter : NSObject

@property (nonatomic, assign) int preExecuteCount;
@property (nonatomic, assign) int postExecuteCount;
@property (nonatomic, readonly) int operationCountDelta;
- (void)execute: (id <IKBCommand>)command onBus: (IKBCommandBus *)bus;

@end

@implementation IKBCommandBusTests
{
  IKBCommandBus *_defaultBus;
  IKBCommandBus *_perTestBus;
  TestCommand *_testCommand;
  TestOperationCounter *_counter;
}

- (void)setUp
{
  [super setUp];
//  _defaultBus = [IKBCommandBus applicationCommandBus];
  _perTestBus = [IKBCommandBus new];
  [[_perTestBus queue] setSuspended: YES];
  _testCommand = [TestCommand new];
  _counter = [TestOperationCounter new];
}

- (void)tearDown
{
  _counter = nil;
  _defaultBus = nil;
  [[_perTestBus queue] cancelAllOperations];
  _perTestBus = nil;
  _testCommand = nil;
  [super tearDown];
}

- (void)testDefaultBusIsNotNil
{
    STAssertNotNil(_defaultBus, @"Application can get access to the command bus");
}

- (void)testExecutingACommandWithoutAHandlerDoesNotScheduleAnyWork
{
  STAssertNoThrow([_counter execute: _testCommand onBus: _perTestBus], @"Shouldn't execute a command I don't have a handler for");
  STAssertEquals(_counter.operationCountDelta, 0, @"No operations were added to the handler's queue");
}

- (void)testExecutingACommandWithAHandlerAddsAnOperationToTheQueue
{
  [_perTestBus registerCommandHandler: [TestCommandHandler new]];
  STAssertNoThrow([_counter execute: _testCommand onBus: _perTestBus], @"Can execute a command when it's handled");
  STAssertEquals(_counter.operationCountDelta, 1, @"An execute operation was added to the queue");
}

- (void)testMultipleHandlersForTheSameCommandAllGetScheduled
{
  for (int i = 0; i++ < 2;)
    {
      [_perTestBus registerCommandHandler: [TestCommandHandler new]];
    }
  [_counter execute: _testCommand onBus: _perTestBus];
  STAssertEquals(_counter.operationCountDelta, 2, @"Two handlers should each get scheduled");
}

- (void)testTheBusDoesNotScheduleAnUninterestedHandler
{
  [_perTestBus registerCommandHandler: [BoringCommandHandler new]];
  [_counter execute: _testCommand onBus: _perTestBus];
  STAssertEquals(_counter.operationCountDelta, 0, @"Uninterested handler should not get scheduled");
}

@end

@implementation TestCommand
//@synthesize identifier;
@synthesize sender;
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return self; }
- (void)encodeWithCoder:(NSCoder *)aCoder {}
@end

@implementation TestCommandHandler
- (BOOL)canHandleCommand:(id<IKBCommand>)command { return YES; }
- (void)executeCommand:(id<IKBCommand>)command {  }
@end

@implementation BoringCommandHandler
- (BOOL)canHandleCommand:(id<IKBCommand>)command { return NO; }
- (void)executeCommand:(id<IKBCommand>)command {  }
@end

@implementation TestOperationCounter

- (void)execute:(id<IKBCommand>)command onBus:(IKBCommandBus *)bus
{
  self.preExecuteCount = [[bus queue] operationCount];
  [bus execute: command];
  self.postExecuteCount = [[bus queue] operationCount];
}

- (int)operationCountDelta { return self.postExecuteCount - self.preExecuteCount; }

@end