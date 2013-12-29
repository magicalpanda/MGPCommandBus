//
//  IKBCommand.m
//  IKBCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "MGPCommand+Private.h"

@interface MGPCommand ()

@property (nonatomic, strong, readwrite) NSSet *childCommands;

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
        _childCommands = [NSSet set];
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
    __weak id sender = [self sender];
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
    if ([sender respondsToSelector:@selector(commandDidFail:error:)])
    {
        [sender commandDidFail:sender error:error];
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
            NSSet *childCommands = [parentCommand.childCommands setByAddingObject:self];
            parentCommand.childCommands = childCommands;
        }
        else
        {
            NSMutableSet *childCommands = [[_parentCommand childCommands] mutableCopy];
            [childCommands removeObject:self];
            parentCommand.childCommands = [NSSet setWithSet:childCommands];
        }
        _parentCommand = parentCommand;
    }
}

@end
