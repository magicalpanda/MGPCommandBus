//
//  MGPSubCommandHandler.h
//
//  Created by Saul Mora on 12/11/13.
//  Copyright (c) 2013 Magical Panda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPCommandHandler.h"


@interface MGPSubCommandHandler : NSObject<MGPCommandHandler>

- (BOOL) sendSubCommands:(NSArray *)subCommands;
- (void) waitForSubCommandsToComplete;

/// You should also implement the following methods

- (void) commandHandlerDidCompleteCommand:(id<MGPCommand>)command progress:(float)progress;
- (void) commandHandlerDidComplete;
- (void) commandHandlerDidFail:(NSError *)error;

/// When you implement `executeCommand:error:` you should at some point call `[self sendSubCommands:command.childCommands]`
/// to execute the child methods.
/// Optionally you can call `[self waitForSubCommandsToComplete]` to wait for the completion of the child commands

@end
