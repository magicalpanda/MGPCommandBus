//
//  UIApplication+MGPCommandBus.h
//
//  Created by Saul Mora on 12/9/13.
//  Copyright (c) 2013 Magical Panda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGPCommandBus.h"

@protocol MGPCommand;

@interface UIApplication (MGPCommandBusAdditions)

@property (nonatomic, retain, readonly) MGPCommandBus *commandBus;

- (BOOL) sendCommand:(id<MGPCommand>)command;
- (BOOL) sendCommand:(id<MGPCommand>)command from:(id)sender;

- (void) sendCommands:(id<NSFastEnumeration>)commands from:(id)sender;

- (BOOL) canExecuteCommand:(id<MGPCommand>)command;

@end


@protocol MGPCommandBusDelegate <UIApplicationDelegate>

- (id<NSFastEnumeration>) commandClasses;

@end
