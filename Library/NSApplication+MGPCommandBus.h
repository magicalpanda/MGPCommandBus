//
//  NSApplication+CommandBusAdditions.h
//  MGPCommandBus
//
//  Created by Saul Mora on 1/12/14.
//
//

#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)

#import <Cocoa/Cocoa.h>

#import "MGPCommandBus.h"

@protocol MGPCommand;

@interface NSApplication (MGPCommandBusAdditions)

@property (nonatomic, retain, readonly) MGPCommandBus *commandBus;

- (BOOL) sendCommand:(id<MGPCommand>)command;
- (BOOL) sendCommand:(id<MGPCommand>)command from:(id)sender;

- (void) sendCommands:(id<NSFastEnumeration>)commands from:(id)sender;

- (BOOL) canExecuteCommand:(id<MGPCommand>)command;

@end


@protocol MGPCommandBusDelegate

- (id<NSFastEnumeration>) commandClasses;

@end

#end if