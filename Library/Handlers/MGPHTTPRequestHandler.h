//
//  MGPNetworkRequestHandler.h
//  Committed
//
//  Created by Saul Mora on 5/16/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGPHTTPCommand;
@class MGPHTTPRequestHandler;

@protocol MGPHTTPRequestHandlerDelegate <NSObject>

@optional
- (void) handler:(MGPHTTPRequestHandler *)handler willBeginCommand:(MGPHTTPCommand *)command;
- (void) handler:(MGPHTTPRequestHandler *)handler didCompleteCommand:(MGPHTTPCommand *)command error:(NSError *)error;
- (BOOL) handler:(MGPHTTPRequestHandler *)handler shouldBegin:(MGPHTTPCommand *)command;

- (id) deserializeResponse:(NSData *)response forCommand:(MGPHTTPCommand *)command;

@end

@interface MGPHTTPRequestHandler : NSObject

@property (nonatomic, weak) id<MGPHTTPRequestHandlerDelegate> delegate;

- (instancetype) initWithSession:(NSURLSession *)session command:(MGPHTTPCommand *)command;

- (void) sendRequestCompletion:(void(^)(BOOL,NSError *))completion;

@end
