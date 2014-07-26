//
//  MGPHTTPRequestHandler.m
//  Committed
//
//  Created by Saul Mora on 5/7/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPDataRequestHandler.h"
#import "MGPHTTPRequestHandler+Private.h"
#import "NSNumber+HTTPStatusAdditions.h"


@implementation MGPHTTPDataRequestHandler

- (NSURLSessionTask *) createTaskForCommand:(MGPHTTPCommand *)command;
{
    NSURLRequest *request = [self requestFromCommand:command];

    NSLog(@"Building Data Task for Command %@ (Request: %@)", command, request);
    NSLog(@"- Headers: %@", [request allHTTPHeaderFields]);

    void (^completionHandler)(NSData *,NSURLResponse *, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *requestError) {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSNumber *statusCode = @([httpResponse statusCode]);

        NSLog(@"Data Request Completed - Status %@", statusCode);
        NSLog(@"- URL: %@", [request URL]);
        NSLog(@"- Headers: %@", [httpResponse allHeaderFields]);

        if ([statusCode isNotFound])
        {
            [self command:command notFound:request];
            return;
        }

        [command processHeaders:[httpResponse allHeaderFields]];
        id deserializedResponse = [command deserializeResponse:data];
//        id deserializer = [self.delegate respondsToSelector:@selector(deserializeResponse:forCommand:)] ? self.delegate : self;
//        id deserializedResponse = [deserializer deserializeResponse:data forCommand:self.command];

        if ([statusCode isNotAuthorized])
        {
            [self command:command notAuthorized:deserializedResponse statusCode:statusCode];
        }
        else
        {
            [self command:command successful:deserializedResponse statusCode:statusCode];
        }

    };

    return [self.session dataTaskWithRequest:request completionHandler:completionHandler];
}

- (void) command:(id)command notFound:(NSURLRequest *)request;
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: @"Not Found: Unable to load URL",
                               @"URL": [request URL]
                               };
    NSError *error = [NSError errorWithDomain:@"MGPCommandBus" code:404 userInfo:userInfo];
    [self didCompleteRequest:NO error:error];
}

- (void) command:(id)command successful:(id)deserializedResponse statusCode:(NSNumber *)statusCode;
{
    BOOL success = NO;
    if ([statusCode isSuccess] || [statusCode isSuccessWithNoContent])
    {
        success = [command completeWithResponse:deserializedResponse];
    }
    [self didCompleteRequest:success error:nil];
}

- (void) command:(MGPHTTPCommand *)command notAuthorized:(id)deserializedResponse statusCode:(NSNumber *)statusCode;
{
    NSString *message = @"Access unauthorized";//[deserializedResponse valueForKey:@"message"];
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: @"Unauthorized Access",
                               NSLocalizedRecoverySuggestionErrorKey: message,

                               };
    NSError *serviceError = [NSError errorWithDomain:@"MGPCommandBus"
                                                code:[statusCode integerValue]
                                            userInfo:userInfo];
    [self didCompleteRequest:NO error:serviceError];
}

@end

