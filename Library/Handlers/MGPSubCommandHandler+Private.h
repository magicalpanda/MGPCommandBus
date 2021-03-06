//
//  MGPSubCommandHandler+Private.h
//
//  Created by Saul Mora on 1/1/14.
//  Copyright (c) 2014 Magical Panda. All rights reserved.
//


#import "MGPSubCommandHandler.h"
#import "MGPCommand.h"


@interface MGPSubCommandHandler ()<MGPCommandCallback>

- (void) commandHandlerDidCompleteCommand:(id<MGPCommand>)command progress:(float)progress;
- (void) commandHandlerDidComplete;
- (void) commandHandlerDidFail:(NSError *)error;

@end
