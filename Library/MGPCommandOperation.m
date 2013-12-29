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
@property (nonatomic, strong, readwrite) MGPCommandBus *commandBus;

@end


@implementation MGPCommandOperation

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
    NSSet *childCommands = [command childCommands];
    
    NSAssert(command, @"No command to execute");
    NSAssert(handler, @"No handler to execute command");
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
        //when no child commands, if all child commands have no error, send command complete
        [command commandDidComplete];
        
        //if child commands, execute child commands.
        for (id<MGPCommand> childCommand in childCommands)
        {
            [childCommand setParentCommand:nil];
            
            MGPCommandBus *bus = self.commandBus;
            [bus.queuedCommands removeObject:childCommand];
            [bus execute:childCommand];
        }
    }
}

@end
