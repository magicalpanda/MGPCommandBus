//
//  MGPSynchronousCommandOperation.m
//  MGPCommandBus
//
//  Created by Saul Mora on 5/17/14.
//
//

#import "MGPSynchronousCommandOperation.h"
#import "MGPCommandBus+Private.h"

@implementation MGPSynchronousCommandOperation

- (void)main;
{
    id<MGPCommand> command = self.command;

    id<MGPSynchronousCommandHandler> handler = self.handler;

    NSAssert(command, @"No command to execute");
    NSAssert(handler, @"No handler to execute command");
    [self.commandBus commandOperationWillBegin:self];

    [command commandWillStart];

    if (self.isCancelled)
    {
        [command commandDidNotStart];
        [self.commandBus commandOperationDidNotStart:self];
        return;
    }

    NSError *error = nil;
    BOOL succeeded = [handler executeCommand:command error:&error];
    if (!succeeded)
    {
        NSLog(@"!!! Command %@ failed %@", command, error);
        [command commandDidFailWithError:error];
        [self.commandBus commandOperationDidFail:self];
    }
    else
    {
        [command commandDidComplete];
        [self.commandBus commandOperationDidComplete:self];
    }
}

@end
