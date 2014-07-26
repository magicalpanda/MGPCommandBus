//
//  MGPNetworkCommandHandler_Private.h
//  Committed
//
//  Created by Saul Mora on 4/26/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPNetworkCommandHandler.h"


@interface MGPNetworkCommandHandler ()<NSURLSessionDataDelegate>

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, assign) BOOL success;

- (void) reachabilityDidChangeTo:(BOOL)isReachable;

@end

