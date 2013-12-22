//
//  UIApplication+GibraltarAdditions.m
//  Gibraltar iOS
//
//  Created by Saul Mora on 12/9/13.
//  Copyright (c) 2013 Magical Panda. All rights reserved.
//

#import "UIApplication+IKBCommandBus.h"
#import "IKBCommand.h"
#import "IKBCommandBus.h"
#import <objc/runtime.h>

static NSString * const IKBCommandBusKey = @"commandBus";

@implementation UIApplication (GibraltarAdditions)

- (void)setCommandBus:(IKBCommandBus *)commandBus;
{
    objc_setAssociatedObject(self, (__bridge const void *)(IKBCommandBusKey), commandBus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IKBCommandBus *)commandBus;
{
    id commandBus = objc_getAssociatedObject(self, (__bridge const void *)(IKBCommandBusKey));
    if (commandBus == nil)
    {
        commandBus = [IKBCommandBus new];
        id<IKBCommandBusDelegate> delegate = (id)self.delegate;
        id classes = [delegate commandClasses];
        [commandBus registerHandlerClasses:classes];
        self.commandBus = commandBus;
    }
    return commandBus;
}

- (void) sendCommands:(id<NSFastEnumeration>)commands from:(id)sender;
{
    for (id<IKBCommand> command in commands)
    {
        [self sendCommand:command from:sender];
    }
}

- (BOOL) sendCommand:(id<IKBCommand>)command from:(id)sender;
{
    command.sender = sender;
    return [self sendCommand:command];
}

- (BOOL) sendCommand:(id<IKBCommand>)command;
{
    IKBCommandBus *commandBus = [self commandBus];
    BOOL didExecuteCommand = [commandBus execute:command];
    return didExecuteCommand;
}

- (BOOL) canExecuteCommand:(id<IKBCommand>)command;
{
    IKBCommandBus *commandBus = [self commandBus];
    return [commandBus commandCanExecute:command];
}

@end
