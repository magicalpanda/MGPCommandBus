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

#import "IKBCommandBus.h"
#import "IKBCommandBus+Extension.h"
#import "IKBCommand.h"
#import "IKBCommandHandler.h"
#import <objc/runtime.h>


void IKBCommandBusZeroHandlers(id <IKBCommand> command)
{
    NSLog(@"No handlers registered for command %@", command);
    NSLog(@"Break in IKBCommandBusZeroHandlers() to debug.");
}

@interface IKBCommandBus ()

@property (nonatomic, strong, readwrite) NSMutableSet *queuedCommands;

@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, strong, readonly) NSMutableDictionary *handlers;
@property (nonatomic, strong, readwrite) NSSet *handlersSet;

@end


@implementation IKBCommandBus

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
//    NSString *className = NSStringFromClass(klass);
//    [self.handlers setValue:[klass new] forKey:className];
    [self registerCommandHandler:[klass new]];
}

- (void) registerCommandHandler:(id <IKBCommandHandler>)handler
{
    NSParameterAssert(handler);
    NSAssert([handler conformsToProtocol:@protocol(IKBCommandHandler)], @"%@ does not comform to protocol '%@'", handler, @"IKBCommandHandler");
    
    [self.handlers setValue:handler forKey:NSStringFromClass([handler class])];
    self.handlersSet = [NSSet setWithArray:[self.handlers allValues]];
}

- (BOOL) commandCanExecute:(id<IKBCommand>)command;
{
    __block BOOL canHandleCommand = (command != nil);
    [self.handlersSet enumerateObjectsUsingBlock:^(id<IKBCommandHandler> handler, BOOL *stop) {

        canHandleCommand &= [handler canHandleCommand:command];
    }];
    return canHandleCommand;
}

- (NSSet *) handlersForCommand:(id<IKBCommand>)command;
{
    NSSet *matchingHandlers = [self.handlersSet objectsPassingTest: ^(id<IKBCommandHandler> thisHandler, BOOL *stop){
        return [thisHandler canHandleCommand:command];
    }];
    if ([matchingHandlers count] == 0)
    {
        IKBCommandBusZeroHandlers(command);
    }
    return matchingHandlers;
}

- (NSOperation *) operationWithHandler:(id<IKBCommandHandler>)handler forCommand:(id<IKBCommand>)command;
{
    id sender = [command sender];
    __weak typeof(self) weakSelf = self;
    NSSet *childCommands = [self.queuedCommands filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"parentCommand = %@", command]];
    NSBlockOperation *executeOperation = [NSBlockOperation blockOperationWithBlock:^{
        if ([sender respondsToSelector:@selector(commandWillBegin:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender commandWillBegin:command];
            });
        }
        
        NSError *error = nil;
        BOOL success = [handler executeCommand:command error:&error];
        if (!success)
        {
            NSLog(@"Command %@ failed %@", command, error);
            if ([sender respondsToSelector:@selector(commandDidFail:error:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender commandDidFail:command error:error];
                });
            }
        }
        else
        {
            if ([sender respondsToSelector:@selector(commandDidComplete:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender commandDidComplete:command];
                });
            }

            for (id<IKBCommand> childCommand in childCommands)
            {
                [childCommand setParentCommand:nil];
                [weakSelf.queuedCommands removeObject:childCommand];
                [weakSelf execute:childCommand];
            }
        }
    }];
    return executeOperation;
}

- (BOOL)execute:(id <IKBCommand>)command
{
    id<IKBCommand> parentCommand = [command parentCommand];
    if (parentCommand) //if have a parent command, add to pending
    {
        [self.queuedCommands addObject:command];
    }
    //if a command has children, add them, then run command
    NSSet *childCommands = [command childCommands];
    [self.queuedCommands addObjectsFromArray:[childCommands allObjects]];

    BOOL commandWasHandled = NO;
    if (![self.queuedCommands containsObject:command])
    {
        NSSet *matchingHandlers = [self handlersForCommand:command];
        for (id <IKBCommandHandler> thisHandler in matchingHandlers)
        {
            NSOperation *executeOperation = [self operationWithHandler:thisHandler forCommand:command];
            [self.queue addOperation:executeOperation];
        }
        commandWasHandled = [matchingHandlers count] > 0;
    }
    return commandWasHandled;
}

- (NSOperationQueue *) queue;
{
    if (_queue == nil)
    {
        _queue = [NSOperationQueue new];
    }
    return _queue;
}

- (NSMutableDictionary *)handlers;
{
    if (_handlers == nil)
    {
        _handlers = [NSMutableDictionary dictionary];
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

