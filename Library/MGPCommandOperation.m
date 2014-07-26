//
//  MGPCommandOperation.m
//  MGPCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "MGPCommandOperation.h"
#import "MGPSynchronousCommandOperation.h"
#import "MGPAsynchronousCommandOperation.h"

@interface MGPCommandOperation ()

@property (nonatomic, strong, readwrite) id<MGPCommand> command;
@property (nonatomic, strong, readwrite) id handler;
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
    NSParameterAssert(handler);
    NSParameterAssert(command);

    BOOL useAsynchronousOperation = [handler conformsToProtocol:@protocol(MGPAsynchronousCommandHandler)];
    Class operationClass = useAsynchronousOperation ? [MGPAsynchronousCommandOperation class] : [MGPSynchronousCommandOperation class];

    self = [[operationClass alloc] init];
    if (self)
    {
        _commandBus = bus;
        _handler = handler;
        _command = command;
    }
    return self;
}

- (NSString *) description;
{
    return [NSString stringWithFormat:@"<%@: %p; Command: %@>", NSStringFromClass([self class]), self, self.command];
}

@end
