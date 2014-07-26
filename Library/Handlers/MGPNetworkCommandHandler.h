//
//  OPNetworkCommandHandler.h
//  Committed
//
//  Created by Saul Mora on 4/24/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPCommandHandler.h"

@class KSReachability;

@interface MGPNetworkCommandHandler : NSObject<MGPCommandHandler>

@property (nonatomic, strong) NSURLSession *session;

- (instancetype) initWithReachability:(KSReachability *)reachability;

@end

