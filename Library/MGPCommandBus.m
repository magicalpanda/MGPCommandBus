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

@property (nonatomic, strong, readonly) NSMutableSet *waitingCommands;
@property (nonatomic, strong, readonly) NSMutableSet *workingCommands;

@end


@implementation MGPCommandBus

@synthesize queue = _queue;
@synthesize handlers = _handlers;
@synthesize workingCommands = _workingCommands;
@synthesize waitingCommands = _waitingCommands;

- (void) registerHandlerClasses:(id<NSFastEnumeration>)classes;
{
    for (Class klass in classes)
    {
        [self registerCommandHandlerClass:klass];
    }
}

- (void) registerCommandHandlerClass:(Class)klass;
{
    NSParameterAssert(klass);
    Protocol *handlerProtocol = @protocol(MGPCommandHandler);
    NSAssert([klass conformsToProtocol:handlerProtocol], @"%@ does not comform to protocol '%@'", NSStringFromClass(klass), NSStringFromProtocol(handlerProtocol));
    
    [self.handlers addObject:klass];
}

- (void) registerCommandHandler:(id <MGPCommandHandler>)handler
{
    NSParameterAssert(handler);
    NSAssert([handler conformsToProtocol:@protocol(MGPCommandHandler)], @"%@ does not comform to protocol '%@'", handler, @"IKBCommandHandler");
    
    [self.handlers addObject:[handler class]];
}

- (void) removeAllCommands;
{
    [self.waitingCommands removeAllObjects];
    [self.queue cancelAllOperations];
}

- (BOOL) commandCanExecute:(id<MGPCommand>)command;
{
    __block BOOL canHandleCommand = NO;
    [self.handlers enumerateObjectsUsingBlock:^(id<MGPCommandHandler> handler, BOOL *stop) {
        canHandleCommand |= [[handler class] canHandleCommand:command];
    }];
    return canHandleCommand;
}

- (NSSet *) handlersForCommand:(id<MGPCommand>)command;
{
    NSSet *matchingHandlers = [self.handlers objectsPassingTest:^(id<MGPCommandHandler> handler, BOOL *stop){
        return [[handler class] canHandleCommand:command];
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

- (void) commandOperationDidFail:(MGPCommandOperation *)operation;
{
    @synchronized(self)
    {
        [self.workingCommands removeObject:operation.command];
    }
}

- (void) commandOperationDidComplete:(MGPCommandOperation *)operation;
{
    id<MGPCommand> parentCommand = [operation command];
    @synchronized(self)
    {
        [self.workingCommands removeObject:parentCommand];
    }
}

- (NSSet *) operationsForCommand:(id<MGPCommand>)command;
{
    NSMutableSet *operations = [NSMutableSet set];
    NSSet *matchingHandlers = [self handlersForCommand:command];
    for (id<MGPCommandHandler> handler in matchingHandlers)
    {
        id<MGPCommandHandler> handlerInstance = [[[handler class] alloc] init];
        NSOperation *executeOperation = [MGPCommandOperation operationWithBus:self
                                                                      command:command
                                                                      handler:handlerInstance];
        [operations addObject:executeOperation];
    }
   
    return [NSSet setWithSet:operations];
}

- (BOOL) execute:(id<MGPCommand>)command;
{
    BOOL commandWasHandled = NO;
    NSMutableSet *waitingCommands = self.waitingCommands;
    if ([command parentCommand])
    {
        [waitingCommands removeObject:command];
    }
    
    if ([command.childCommands count]> 0)
    {
        [waitingCommands unionSet:[NSSet setWithArray:[command childCommands]]];
    }

    NSSet *operations = [self operationsForCommand:command];
    [self setDependenciesForOperations:operations];
    [self.queue addOperations:[operations allObjects] waitUntilFinished:NO];

    commandWasHandled = [operations count] > 0;
    
    return commandWasHandled;
}

- (void) setDependenciesForOperations:(NSSet *)operations
{
    for (MGPCommandOperation *operation in operations) {
        if (operation.command.dependentCommand) {
            NSMutableSet *dependentOperations = [NSMutableSet setWithArray:self.queue.operations];
            [dependentOperations filterUsingPredicate:[NSPredicate predicateWithFormat:@"command == %@", operation.command.dependentCommand]];
            [dependentOperations enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                [operation addDependency:obj];
            }];
        }
    }
}

- (BOOL) execute:(id<MGPCommand>)priorCommand before:(id<MGPCommand>)laterCommand;
{
    [laterCommand setParentCommand:priorCommand];
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

- (NSMutableSet *) waitingCommands;
{
    if (_waitingCommands == nil)
    {
        _waitingCommands = [NSMutableSet set];
    }
    return _waitingCommands;
}

- (NSMutableSet *) workingCommands;
{
    if (_workingCommands == nil)
    {
        _workingCommands = [NSMutableSet set];
    }
    return _workingCommands;
}

@end

