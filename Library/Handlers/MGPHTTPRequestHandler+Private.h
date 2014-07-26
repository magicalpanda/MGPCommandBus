//
//  MGPHTTPRequestHandler_Private.h
//  Committed
//
//  Created by Saul Mora on 5/16/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPRequestHandler.h"
#import "MGPHTTPCommand.h"

@interface MGPHTTPRequestHandler ()

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) MGPHTTPCommand *command;

@property (nonatomic, copy) void (^completion)(BOOL,NSError *);

- (NSURLSessionTask *) createTaskForCommand:(MGPHTTPCommand *)command;
- (NSURLRequest *) requestFromCommand:(MGPHTTPCommand *)command;
- (void) didCompleteRequest:(BOOL)success error:(NSError *)error;


@end