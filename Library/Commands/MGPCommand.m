//
//  MGPCommand.m
//  MGPCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "MGPCommand+Private.h"

@implementation MGPCommand

@synthesize sender = _sender;
@synthesize priorCommand = _priorCommand;

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    return [self init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    
}

- (NSString *) description;
{
    return [NSString stringWithFormat:@"<%@: %p; Prior Command: %p>", NSStringFromClass([self class]), self, self.priorCommand];
}

- (NSMutableArray *)childCommands;
{
    if (_childCommands == nil)
    {
        _childCommands = [NSMutableArray array];
    }
    return _childCommands;
}

- (void) commandWillStart;
{
    id sender = [self sender];
    if ([sender respondsToSelector:@selector(commandWillStart:)])
    {
        [sender commandWillStart:self];
    }
}

- (void) commandDidNotStart;
{
    id sender = [self sender];
    if ([sender respondsToSelector:@selector(commandDidNotStart:)])
    {
        [sender commandDidNotStart:self];
    }
}

- (void) commandDidComplete;
{
    id sender = [self sender];
    if ([sender respondsToSelector:@selector(commandDidComplete:)])
    {
        [sender commandDidComplete:self];
    }
}

- (void) commandDidFailWithError:(NSError *)error;
{
    id sender = [self sender];
    if ([sender respondsToSelector:@selector(command:didFailWithError:)])
    {
        [sender command:self didFailWithError:error];
    }
}

- (id<MGPCommand>)priorCommand;
{
    @synchronized(self)
    {
        return _priorCommand;
    }
}

- (void)setPriorCommand:(MGPCommand *)priorCommand;
{
    @synchronized(self)
    {
        [priorCommand removeChildCommand:self];
        _priorCommand = priorCommand;
        [(MGPCommand *)_priorCommand addChildCommand:self];
    }
}

- (void) addChildCommand:(id<MGPCommand>)command;
{
    if (command)
    {
        [self.childCommands addObject:command];
    }
}

- (void) removeChildCommand:(id<MGPCommand>)command;
{
    [self.childCommands removeObject:command];
}

- (void) removeAllChildCommands;
{
    [self.childCommands makeObjectsPerformSelector:@selector(setPriorCommand:) withObject:nil];
    [self.childCommands removeAllObjects];
}

@end
