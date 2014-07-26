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

#import "MGPCommandBus+Private.h"
#import "MGPCommand+Private.h"
#import "MGPCommandOperation.h"

#import <objc/runtime.h>


void MGPCommandBusZeroHandlers(id <MGPCommand> command)
{
    NSLog(@"No handlers registered for command %@", command);
    NSLog(@"Break in MGPCommandBusZeroHandlers() to debug.");
}

@interface MGPCommandBus ()

@property (nonatomic, strong, readonly) NSMutableSet *workingCommands;
@property (nonatomic, strong, readonly) NSMutableSet *waitingCommands;

@end


@implementation MGPCommandBus

@synthesize queue = _queue;
@synthesize handlers = _handlers;
@synthesize workingCommands = _workingCommands;
@synthesize waitingCommands = _waitingCommands;

- (void) registerCommandHandler:(id<MGPCommandHandler>)handler
{
    NSParameterAssert(handler);
    NSAssert([handler conformsToProtocol:@protocol(MGPCommandHandler)], @"%@ does not comform to protocol '%@'", handler, @"MGPCommandHandler");

    [self.handlers addObject:handler];
}

- (void) registerCommandHandlers:(id<NSFastEnumeration>)handlers;
{
    for (id<MGPCommandHandler> handler in handlers)
    {
        [self registerCommandHandler:handler];
    }
}

- (void) cancelAllCommands;
{
    [self.queue cancelAllOperations];
    [self.waitingCommands removeAllObjects];
}

- (BOOL) commandCanExecute:(id<MGPCommand>)command;
{
    __block BOOL canHandleCommand = NO;
    [self.handlers enumerateObjectsUsingBlock:^(id<MGPCommandHandler> handler, BOOL *stop) {
        canHandleCommand |=
            [handler canHandleCommand:command] &&
            ([command respondsToSelector:@selector(shouldExecute)] ? [command shouldExecute] : YES);
    }];
    return canHandleCommand;
}

- (NSSet *) handlersForCommand:(id<MGPCommand>)command;
{
    BOOL commandShouldRun = [command respondsToSelector:@selector(shouldExecute)] ? [command shouldExecute] : YES;
    if (commandShouldRun == NO)
    {
        return [NSSet set];
    }

    NSSet *matchingHandlers = [self.handlers objectsPassingTest:^BOOL(id<MGPCommandHandler> handler, BOOL *stop){
        return [handler canHandleCommand:command];
    }];
    if ([matchingHandlers count] == 0)
    {
        MGPCommandBusZeroHandlers(command);
    }
    return matchingHandlers;
}

- (void) commandOperationWillBegin:(MGPCommandOperation *)operation;
{
    @synchronized(self)
    {
        [self.workingCommands addObject:operation.command];
    }
}

- (void) commandOperationDidNotStart:(MGPCommandOperation *)operation;
{
    @synchronized(self)
    {
        if ([operation isCancelled])
        {
            [self.workingCommands removeObject:operation.command];
            [self cancelOperationsDependentOnCommand:operation.command];
            [self cancelWaitingCommandsDependentOnCommand:operation.command];
        }
    }
}

- (void) commandOperationDidFail:(MGPCommandOperation *)operation;
{
    @synchronized(self)
    {
        [self.workingCommands removeObject:operation.command];
        [self cancelOperationsDependentOnCommand:operation.command];
        [self cancelWaitingCommandsDependentOnCommand:operation.command];
    }
}

- (void) cancelWaitingCommandsDependentOnCommand:(id<MGPCommand>)command;
{
    [self.queue setSuspended:YES];
    NSSet *commandsToCancel = [self.waitingCommands filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"priorCommand = %@", command]];
    [self.waitingCommands minusSet:commandsToCancel];
    [commandsToCancel makeObjectsPerformSelector:@selector(commandDidNotStart)];
    [self.queue setSuspended:NO];
}

- (void) cancelOperationsDependentOnCommand:(id<MGPCommand>)command;
{
    [self.queue setSuspended:YES];

    NSArray *operations = [self.queue operations];
    NSPredicate *dependentCommandFilter = [NSPredicate predicateWithFormat:@"command.priorCommand = %@", command];
    NSArray *dependentOperations = [operations filteredArrayUsingPredicate:dependentCommandFilter];

    [dependentOperations enumerateObjectsUsingBlock:^(MGPCommandOperation *operation, NSUInteger idx, BOOL *stop) {
        [operation cancel];
    }];
    [self.queue setSuspended:NO];
}

- (void) commandOperationDidComplete:(MGPCommandOperation *)operation;
{
    id<MGPCommand> completedCommand = [operation command];
    NSSet *commandsToBeQueued = [self.waitingCommands filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"priorCommand = %@", completedCommand]];
    for (id command in commandsToBeQueued)
    {
        [self execute:command wasWaiting:YES];
    }
    [self.workingCommands removeObject:completedCommand];
}

- (NSSet *) operationsForCommand:(id<MGPCommand>)command;
{
    NSMutableSet *operations = [NSMutableSet set];
    NSSet *matchingHandlers = [self handlersForCommand:command];
    for (id<MGPCommandHandler> handler in matchingHandlers)
    {
        id<MGPCommandHandler> handlerInstance = handler;

        NSOperation *executeOperation = [MGPCommandOperation operationWithBus:self
                                                                      command:command
                                                                      handler:handlerInstance];
        [operations addObject:executeOperation];
    }
   
    return [NSSet setWithSet:operations];
}

- (BOOL) execute:(id<MGPCommand>)command;
{
    return [self execute:command wasWaiting:NO];
}

- (BOOL) execute:(id<MGPCommand>)command wasWaiting:(BOOL)wasWaiting;
{
    BOOL commandWasHandled = NO;

    if (!wasWaiting && [command priorCommand] && [self commandCanExecute:[command priorCommand]])
        //if this command has a parent to wait for, and has a handler
    {
        [self.waitingCommands addObject:command];
    }
    else    //otherwise, send it to the queue
    {
        [self.waitingCommands removeObject:command]; //if it was waiting, don't wait anymore
        NSSet *operations = [self operationsForCommand:command];
        [self.queue addOperations:[operations allObjects] waitUntilFinished:NO];

        commandWasHandled = [operations count] > 0;
    }
    return commandWasHandled || [self.waitingCommands containsObject:command];  //was handled, or is waiting with valid handler
}

- (BOOL) execute:(id<MGPCommand>)priorCommand before:(id<MGPCommand>)laterCommand;
{
    [laterCommand setPriorCommand:priorCommand];
    BOOL handled = YES;
    handled &= [self execute:priorCommand];
    handled &= [self execute:laterCommand];
    return handled;
}

- (BOOL) execute:(id<MGPCommand>)laterCommand after:(id<MGPCommand>)priorCommand;
{
    return [self execute:priorCommand before:laterCommand];
}

- (NSOperationQueue *) queue;
{
    if (_queue == nil)
    {
        _queue = [NSOperationQueue new];
        [_queue setName:@"MGPCommandBus Queue"];
    }
    return _queue;
}

- (NSMutableSet *) handlers;
{
    if (_handlers == nil)
    {
        _handlers = [NSMutableSet set];
    }
    return _handlers;
}

- (NSMutableSet *) workingCommands;
{
    if (_workingCommands == nil)
    {
        _workingCommands = [NSMutableSet set];
    }
    return _workingCommands;
}

- (NSMutableSet *) waitingCommands;
{
    if (_waitingCommands == nil)
    {
        _waitingCommands = [NSMutableSet set];
    }
    return _waitingCommands;
}

@end

