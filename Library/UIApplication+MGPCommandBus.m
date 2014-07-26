//
//  UIApplication+MGPCommandBus.m
//
//  Created by Saul Mora on 12/9/13.
//  Copyright (c) 2013 Magical Panda. All rights reserved.
//

//#if TARGET_OS_IPHONE || TARGET_IOS_SIMULATOR

#import "UIApplication+MGPCommandBus.h"
#import "MGPCommand.h"
#import "MGPCommandBus.h"
#import <objc/runtime.h>

static NSString * const MGPCommandBusKey = @"commandBus";

@implementation UIApplication (MGPCommandBusAdditions)

- (void)setCommandBus:(MGPCommandBus *)commandBus;
{
    objc_setAssociatedObject(self, (__bridge const void *)(MGPCommandBusKey), commandBus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MGPCommandBus *)commandBus;
{
    id commandBus = objc_getAssociatedObject(self, (__bridge const void *)(MGPCommandBusKey));
    if (commandBus == nil)
    {
        commandBus = [MGPCommandBus new];
        self.commandBus = commandBus;
        
        id<MGPCommandBusDelegate> delegate = (id)self.delegate;
        if ([delegate respondsToSelector:@selector(commandHandlers)])
        {
            id<NSFastEnumeration> handlers = [delegate commandHandlers];
            [commandBus registerCommandHandlers:handlers];
        }
    }
    return commandBus;
}

- (void) sendCommands:(id<NSFastEnumeration>)commands from:(id)sender;
{
    for (id<MGPCommand> command in commands)
    {
        [self sendCommand:command from:sender];
    }
}

- (BOOL) sendCommand:(id<MGPCommand>)command from:(id)sender;
{
    command.sender = sender;
    return [self sendCommand:command];
}

- (BOOL) sendCommand:(id<MGPCommand>)command;
{
    MGPCommandBus *commandBus = [self commandBus];
    BOOL didExecuteCommand = [commandBus execute:command];
    return didExecuteCommand;
}

- (BOOL) canExecuteCommand:(id<MGPCommand>)command;
{
    MGPCommandBus *commandBus = [self commandBus];
    return [commandBus commandCanExecute:command];
}

@end

//#endif