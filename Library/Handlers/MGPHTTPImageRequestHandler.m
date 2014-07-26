//
//  MGPHTTPImageRequestHandler.m
//  Committed
//
//  Created by Saul Mora on 5/13/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPImageRequestHandler.h"
#import "MGPHTTPRequestHandler+Private.h"
#import "MGPHTTPImageCommand.h"

@implementation MGPHTTPImageRequestHandler

- (NSURLSessionTask *) createTaskForCommand:(MGPHTTPCommand *)command;
{
    NSURLRequest *request = [self requestFromCommand:command];

    NSLog(@"- Image Request: %@", request);
    NSLog(@"- Headers: %@", [request allHTTPHeaderFields]);

    void (^completionBlock)(NSURL *, NSURLResponse *, NSError *) = ^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [httpResponse statusCode];

        NSLog(@"Image Request Completed - Status %zd", statusCode);
        NSLog(@"- URL: %@", [request URL]);
        NSLog(@"- Headers: %@", [httpResponse allHeaderFields]);

        [command processHeaders:[httpResponse allHeaderFields]];
        //if status code is success
        BOOL success = error == nil && [command completeWithResponse:location];

        [self didCompleteRequest:success error:error];
    };

    return [self.session downloadTaskWithRequest:request completionHandler:completionBlock];
}

@end
