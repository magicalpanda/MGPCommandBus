//
//  NSNumber+HTTPStatusAdditions.m
//  Committed
//
//  Created by Saul Mora on 5/18/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "NSNumber+HTTPStatusAdditions.h"

@implementation NSNumber (HTTPStatusAdditions)

- (BOOL) isSuccess;
{
    NSInteger statusCode = [self integerValue];
    return statusCode == 200 || statusCode == 201;
}

- (BOOL) isSuccessWithNoContent;
{
    NSInteger statusCode = [self integerValue];
    return statusCode == 304 || statusCode == 204;
}

- (BOOL) isRedirect;
{
    NSInteger statusCode = [self integerValue];
    return statusCode == 302;
}

- (BOOL) isNotAuthorized;
{
    NSInteger statusCode = [self integerValue];
    return statusCode == 401;
}

- (BOOL) isNotFound;
{
    NSInteger statusCode = [self integerValue];
    return statusCode == 404;
}

@end