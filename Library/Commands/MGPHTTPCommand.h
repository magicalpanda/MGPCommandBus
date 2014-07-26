//
//  MGPRestAPICommand.h
//  Committed
//
//  Created by Saul Mora on 4/6/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGPCommand.h"

@interface MGPHTTPCommand : MGPCommand

- (BOOL) secure;
- (NSString *) httpHost;
- (NSDictionary *) httpHeaders;
- (NSString *) httpMethod;
- (NSData *) httpBody;
- (NSDictionary *) formParameters;
- (NSString *) path;

- (NSDictionary *) queryParameters;

- (NSURLRequest *) request;
- (NSURLRequest *) signedRequest;

- (NSURLRequest *) requestWithServiceURL:(NSURL *)serviceURL;

- (NSString *) authorization;

- (void) processHeaders:(NSDictionary *)headers;
- (BOOL) completeWithResponse:(id)response;
- (id) deserializeResponse:(NSData *)responseData;

@end
