//
//  MGPCommand_Private.h
//  MGPCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "MGPCommand.h"

@interface MGPCommand ()

@property (nonatomic, strong, readwrite) NSMutableArray *childCommands;

- (void) addChildCommand:(id<MGPCommand>)command;
- (void) removeChildCommand:(id<MGPCommand>)command;

@end
