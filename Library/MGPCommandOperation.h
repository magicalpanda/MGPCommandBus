//
//  MGPCommandOperation.h
//  MGPCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import <Foundation/Foundation.h>
#import "MGPCommand.h"
#import "MGPCommandHandler.h"
#import "MGPCommandBus.h"

@interface MGPCommandOperation : NSOperation

@property (nonatomic, strong, readonly) id<MGPCommand> command;
@property (nonatomic, strong, readonly) id<MGPCommandHandler> handler;
@property (nonatomic, strong, readonly) MGPCommandBus *commandBus;

- (instancetype) initWithBus:(MGPCommandBus *)bus command:(id<MGPCommand>)command handler:(id<MGPCommandHandler>)handler;

@end
