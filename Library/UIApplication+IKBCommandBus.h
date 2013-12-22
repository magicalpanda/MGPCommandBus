//
//  UIApplication+GibraltarAdditions.h
//  Gibraltar iOS
//
//  Created by Saul Mora on 12/9/13.
//  Copyright (c) 2013 Magical Panda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IKBCommandBus;
@protocol IKBCommand;


@interface UIApplication (IKBCommandBusAdditions)

@property (nonatomic, retain, readonly) IKBCommandBus *commandBus;

- (BOOL) sendCommand:(id<IKBCommand>)command;
- (BOOL) sendCommand:(id<IKBCommand>)command from:(id)sender;

- (void) sendCommands:(id<NSFastEnumeration>)commands from:(id)sender;

- (BOOL) canExecuteCommand:(id<IKBCommand>)command;

@end

@protocol IKBCommandBusDelegate <UIApplicationDelegate>

- (id<NSFastEnumeration>) commandClasses;

@end
