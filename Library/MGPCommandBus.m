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

@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, strong, readonly) NSMutableSet *handlers;

@end


@implementation MGPCommandBus

@synthesize queue = _queue;
@synthesize handlers = _handlers;

- (void) registerHandlerClasses:(id<NSFastEnumeration>)classes;
{
    for (Class klass in classes)
    {
        [self registerCommandHandlerClass:klass];
    }
}

- (void) registerCommandHandlerClass:(Class)klass;
{
    [self registerCommandHandler:[klass new]];
}

- (void) registerCommandHandler:(id <MGPCommandHandler>)handler
{
    NSParameterAssert(handler);
    NSAssert([handler conformsToProtocol:@protocol(MGPCommandHandler)], @"%@ does not comform to protocol '%@'", handler, @"IKBCommandHandler");
    
    [self.handlers addObject:handler];
}

- (void) removeAllCommands;
{
    [self.queuedCommands removeAllObjects];
    [self.queue cancelAllOperations];
}

- (BOOL) commandCanExecute:(id<MGPCommand>)command;
{
    __block BOOL canHandleCommand = (command != nil);
    [self.handlers enumerateObjectsUsingBlock:^(id<MGPCommandHandler> handler, BOOL *stop) {
        canHandleCommand &= [handler canHandleCommand:command];
    }];
    return canHandleCommand;
}

- (NSSet *) handlersForCommand:(id<MGPCommand>)command;
{
    NSSet *matchingHandlers = [self.handlers objectsPassingTest:^(id<MGPCommandHandler> handler, BOOL *stop){
        return [handler canHandleCommand:command];
    }];
    if ([matchingHandlers count] == 0)
    {
        MGPCommandBusZeroHandlers(command);
    }
    return matchingHandlers;
}

- (void) queueCommandDependencies:(id<MGPCommand>)command;
{
    id<MGPCommand> parentCommand = [command parentCommand];
    if (parentCommand) //if have a parent command, add to pending
    {
        [self.queuedCommands addObject:command];
    }
    
    //if a command has children, add them, then run command
    NSSet *childCommands = [command childCommands];
    [self.queuedCommands addObjectsFromArray:[childCommands allObjects]];
}

- (BOOL) execute:(id<MGPCommand>)command
{
    BOOL commandWasHandled = NO;
    if (![self.queuedCommands containsObject:command])
    {
        [self queueCommandDependencies:command];
        
        NSSet *matchingHandlers = [self handlersForCommand:command];
        for (id<MGPCommandHandler> handler in matchingHandlers)
        {
            NSOperation *executeOperation = [[MGPCommandOperation alloc] initWithBus:self
                                                                             command:command
                                                                             handler:handler];
            [self.queue addOperation:executeOperation];
        }
        commandWasHandled = [matchingHandlers count] > 0;
    }
    return commandWasHandled;
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
    [laterCommand setParentCommand:priorCommand];
    BOOL handled = YES;
    handled &= [self execute:priorCommand];
    handled &= [self execute:laterCommand];
    return handled;
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

- (NSMutableSet *) queuedCommands;
{
    if (_queuedCommands == nil)
    {
        _queuedCommands = [NSMutableSet set];
    }
    return _queuedCommands;
}

@end

