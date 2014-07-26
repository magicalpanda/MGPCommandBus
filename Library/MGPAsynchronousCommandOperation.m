//
//  MGPAsynchronousCommandOperation.m
//  MGPCommandBus
//
//  Created by Saul Mora on 5/17/14.
//
//

#import "MGPAsynchronousCommandOperation.h"
#import "MGPCommandBus+Private.h"

@interface MGPAsynchronousCommandOperation ()

@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;

@end

@implementation MGPAsynchronousCommandOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (void) setExecuting:(BOOL)executing;
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void) setFinished:(BOOL)finished;
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void) start;
{
    id<MGPCommand> command = self.command;
    if (!self.isExecuting)
    {
        self.executing = YES;

        id<MGPAsynchronousCommandHandler> handler = self.handler;

        NSAssert(command, @"No command to execute");
        NSAssert(handler, @"No handler to execute command");
        [self.commandBus commandOperationWillBegin:self];

        [command commandWillStart];

        if ([self isCancelled])
        {
            [self didNotStart];
        }
        else
        {
            __weak typeof(self) weakSelf = self;
            [handler executeCommand:command completion:^(BOOL success, NSError *error){
                [weakSelf finish:success error:error];
            }];
        }
    }
    else
    {
        [self didNotStart];
    }
}

- (void) didNotStart;
{
    self.finished = YES;
    [self.command commandDidNotStart];
    [self.commandBus commandOperationDidNotStart:self];
}

- (void) finish:(BOOL)success error:(NSError *)error;
{
    id<MGPCommand> command = self.command;
    if (success)
    {
        [command commandDidComplete];
        [self.commandBus commandOperationDidComplete:self];
    }
    else
    {
        NSLog(@"!!! Command %@ failed %@", command, error);
        [command commandDidFailWithError:error];
        [self.commandBus commandOperationDidFail:self];
    }

    self.executing = NO;
    self.finished = YES;
}

- (BOOL) isConcurrent;
{
    return YES;
}

@end
