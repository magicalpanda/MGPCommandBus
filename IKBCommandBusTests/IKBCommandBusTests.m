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

@implementation IKBCommandBusTests
{
    IKBCommandBus *_defaultBus;
    IKBCommandBus *_perTestBus;
    TestCommand *_testCommand;
}

- (void)setUp
{
    [super setUp];
    _defaultBus = [IKBCommandBus applicationCommandBus];
    _perTestBus = [IKBCommandBus new];
    [[_perTestBus queue] setSuspended: YES];
    _testCommand = [TestCommand new];
}

- (void)tearDown
{
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
    int preExecuteCount, postExecuteCount;
    preExecuteCount = [[_perTestBus queue] operationCount];
    STAssertNoThrow([_perTestBus execute: _testCommand], @"Shouldn't execute a command I don't have a handler for");
    postExecuteCount = [[_perTestBus queue] operationCount];
    STAssertEquals(preExecuteCount, postExecuteCount, @"No operations were added to the handler's queue");
}

- (void)testExecutingACommandWithAHandlerAddsAnOperationToTheQueue
{
    int preExecuteCount, postExecuteCount;
    [_perTestBus registerCommandHandler: [TestCommandHandler new]];
    preExecuteCount = [[_perTestBus queue] operationCount];
    STAssertNoThrow([_perTestBus execute: _testCommand], @"Can execute a command when it's handled");
    postExecuteCount = [[_perTestBus queue] operationCount];
    STAssertEquals(postExecuteCount - preExecuteCount, 1, @"An execute operation was added to the queue");
}

@end

@implementation TestCommand
@synthesize identifier;
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return self; }
- (void)encodeWithCoder:(NSCoder *)aCoder {}
@end

@implementation TestCommandHandler
- (BOOL)canHandleCommand:(id<IKBCommand>)command { return YES; }
- (void)executeCommand:(id<IKBCommand>)command {  }
@end