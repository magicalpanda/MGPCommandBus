//
//  MGPHTTPCommandHandler_Private.h
//  Committed
//
//  Created by Saul Mora on 4/29/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPCommandHandler.h"
#import "MGPHTTPCommand.h"
#import "MGPHTTPRequestHandler.h"
#import "MGPNetworkCommandHandler+Private.h"

@interface MGPHTTPCommandHandler ()<MGPHTTPRequestHandlerDelegate>

- (void) commandQueueDidEmpty;

@end
