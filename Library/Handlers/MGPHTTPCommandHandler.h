//
//  MGPHTTPCommandHandler.h
//  Committed
//
//  Created by Saul Mora on 5/16/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPNetworkCommandHandler.h"

@interface MGPHTTPCommandHandler : MGPNetworkCommandHandler<MGPAsynchronousCommandHandler>

- (void) registerCommandType:(Class)commandType;

@end
