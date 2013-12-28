//
//  IKBCommand.m
//  IKBCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "MGPCommand+Private.h"

@implementation MGPCommand

@synthesize sender = _sender;
@synthesize parentCommand = _parentCommand;
@synthesize childCommands = _childCommands;

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    return [super init];
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    
}

- (void) commandWillStart;
{
    
}

- (void) commandDidComplete;
{
    
}

- (void) commandDidFailWithError:(NSError *)error;
{
    
}

@end
