//
//  MGPCommandOperation.m
//  MGPCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "MGPCommandOperation.h"
#import "MGPCommand+Private.h"
#import "MGPCommandBus+Private.h"


@interface MGPCommandOperation ()

@property (nonatomic, strong, readwrite) id<MGPCommand> command;
@property (nonatomic, strong, readwrite) id<MGPCommandHandler> handler;
@property (nonatomic, weak, readwrite) MGPCommandBus *commandBus;

@end


@implementation MGPCommandOperation

+ (instancetype) operationWithBus:(MGPCommandBus *)bus command:(id<MGPCommand>)command handler:(id<MGPCommandHandler>)handler;
{
    return [[self alloc] initWithBus:bus command:command handler:handler];
}

- (instancetype) initWithBus:(MGPCommandBus *)bus command:(id<MGPCommand>)command handler:(id<MGPCommandHandler>)handler;
{
    NSParameterAssert(bus);
    NSParameterAssert(command);
    NSParameterAssert(handler);
    
    self = [super init];
    if (self)
    {
        _commandBus = bus;
        _command = command;
        _handler = handler;
    }
    return self;
}

- (void)main;
{
    id<MGPCommand> command = self.command;
    id<MGPCommandHandler> handler = self.handler;
    
    NSAssert(command, @"No command to execute");
    NSAssert(handler, @"No handler to execute command");
    [self.commandBus commandOperationWillBegin:self];
    
    [command commandWillStart];
    
    NSError *error = nil;
    BOOL succeeded = [handler executeCommand:command error:&error];
    if (!succeeded)
    {
        NSLog(@"!!! Command %@ failed %@", command, error);
        [command commandDidFailWithError:error];
    }
    else
    {
        [command commandDidComplete];        
    }
    [self.commandBus commandOperationDidComplete:self];
}

@end
