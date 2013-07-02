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

void IKBCommandBusZeroHandlers(id <IKBCommand> command)
{
    NSLog(@"No handlers registered for command %@", command);
    NSLog(@"Break in IKBCommandBusZeroHandlers() to debug.");
}

@implementation IKBCommandBus
{
    NSOperationQueue *_queue;
    NSSet *_handlers;
}

static IKBCommandBus *_defaultBus;

+ (void)initialize
{
    if (self == [IKBCommandBus class])
    {
        _defaultBus = [self new];
    }
}

+ (instancetype)applicationCommandBus
{
    return _defaultBus;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _queue = [NSOperationQueue new];
        _handlers = [[NSSet set] retain];
    }
    return self;
}

- (void)registerCommandHandler: (id <IKBCommandHandler>)handler
{
    NSParameterAssert(handler);
    _handlers = [[[_handlers autorelease] setByAddingObject: handler] retain];
}

- (void)execute: (id <IKBCommand>)command
{
    NSSet *matchingHandlers = [_handlers objectsPassingTest: ^(id <IKBCommandHandler> thisHandler, BOOL *stop){
        return [thisHandler canHandleCommand: command];
    }];
    if ([matchingHandlers count] == 0)
    {
        IKBCommandBusZeroHandlers(command);
    }
    for (id <IKBCommandHandler> thisHandler in matchingHandlers)
    {
        NSInvocationOperation *executeOperation = [[NSInvocationOperation alloc] initWithTarget: thisHandler selector: @selector(executeCommand:) object: command];
        [_queue addOperation: executeOperation];
        [executeOperation release];
    }
}

- (void)dealloc
{
    [_queue release];
    [_handlers release];
    [super dealloc];
}

- (NSOperationQueue *)queue
{
    return _queue;
}
@end

