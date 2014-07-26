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
@property (nonatomic, strong, readonly) id handler;
@property (nonatomic, weak, readonly) MGPCommandBus *commandBus;

+ (instancetype) operationWithBus:(MGPCommandBus *)bus command:(id<MGPCommand>)command handler:(id<MGPCommandHandler>)handler;

- (instancetype) initWithBus:(MGPCommandBus *)bus command:(id<MGPCommand>)command handler:(id<MGPCommandHandler>)handler;

@end
