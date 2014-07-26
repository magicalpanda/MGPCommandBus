//
//  MGPHTTPDataUploadRequestHandler.m
//  MGPCommandBus
//
//  Created by Saul Mora on 7/25/14.
//
//

#import "MGPHTTPDataUploadRequestHandler.h"
#import "MGPHTTPRequestHandler+Private.h"
#import "NSNumber+HTTPStatusAdditions.h"

@implementation MGPHTTPDataUploadRequestHandler

- (NSURLSessionTask *) createTaskForCommand:(MGPHTTPCommand *)command;
{
    NSURLRequest *request = [command request];
    NSURLSessionTask *task = [self.session uploadTaskWithRequest:request fromFile:nil completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

    }];

    return task;
}

@end
