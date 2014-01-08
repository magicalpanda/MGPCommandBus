//
//  IKBCommand.m
//  IKBCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "MGPCommand+Private.h"

@interface MGPCommand ()

@property (nonatomic, strong, readwrite) NSMutableSet *childCommands;

@end


@implementation MGPCommand

@synthesize sender = _sender;
@synthesize parentCommand = _parentCommand;
@synthesize childCommands = _childCommands;

- (instancetype) init;
{
    self = [super init];
    if (self)
    {
        _childCommands = [NSMutableSet set];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    return [self init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    
}

- (void) commandWillStart;
{
    id sender = [self sender];
    if ([sender respondsToSelector:@selector(commandWillStart:)])
    {
        [sender commandWillStart:self];
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

- (id<MGPCommand>)parentCommand;
{
    @synchronized(self)
    {
        return _parentCommand;
    }
}

- (void)setParentCommand:(MGPCommand *)parentCommand;
{
    @synchronized(self)
    {
        if (parentCommand)
        {
            [parentCommand.childCommands addObject:self];
        }
        else
        {
            NSMutableSet *childCommands = [[_parentCommand childCommands] mutableCopy];
            [childCommands removeObject:self];
        }
        _parentCommand = parentCommand;
    }
}

- (void) removeAllChildCommands;
{
    [self.childCommands makeObjectsPerformSelector:@selector(setParentCommand:) withObject:nil];
    [self.childCommands removeAllObjects];
}

@end
