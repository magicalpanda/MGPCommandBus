//
//  MGPRestAPICommand.m
//  Committed
//
//  Created by Saul Mora on 4/6/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPCommand.h"


static NSString * const MGPHTTPCommandAuthorizationHeader = @"Authorization";

@interface NSDictionary (URLAdditions)

- (NSString *) stringFromQueryParameters;

@end

@interface MGPHTTPCommand ()

- (NSString *) serializeHeaderValue:(id)obj;

@end

@implementation MGPHTTPCommand

- (NSDictionary *) queryParameters;
{
    return @{};
}

- (NSDictionary *) formParameters;
{
    return @{};
}

- (NSDictionary *) httpHeaders;
{
    return @{};
}

- (NSString *) path;
{
    return @"/";
}

- (NSString *) httpMethod;
{
    return @"GET";
}

- (NSData *) httpBody;
{
    NSData *httpBody = nil;
    if ([[self httpMethod] isEqualToString:@"POST"])
    {
        NSDictionary *formParameters = [self formParameters];
        if ([formParameters count])
        {
            NSString *parameterString = [formParameters stringFromQueryParameters];
            parameterString = [parameterString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            httpBody = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
        }
    }

    return httpBody;
}

- (NSURL *) requestURLWithServiceURL:(NSURL *)serviceURL;
{
    return [serviceURL URLByAppendingPathComponent:[self path]];
}

- (NSURLRequest *) requestWithServiceURL:(NSURL *)serviceURL;
{
    NSURL *url = [self requestURLWithServiceURL:serviceURL];
    NSString *method = [self httpMethod];

    if ([method isEqualToString:@"GET"])
    {
        NSDictionary *queryParameters = [self queryParameters];
        if ([queryParameters count])
        {
            url = [NSURL URLWithString:
            [[url absoluteString] stringByAppendingFormat:@"?%@", [queryParameters stringFromQueryParameters]]];
        }
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];

    NSDictionary *headers = [self httpHeaders];
    [self applyHTTPHeaders:headers toRequest:request];

    [request setHTTPBody:[self httpBody]];

    return request;
}

//NOTE: May need to move down to GithubCommand
- (void) applyHTTPHeaders:(NSDictionary *)headers toRequest:(NSMutableURLRequest *)request;
{
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        obj = [self serializeHeaderValue:obj];
        [request setValue:obj forHTTPHeaderField:key];
    }];
}

- (NSString *) serializeHeaderValue:(id)obj;
{
    if ([NSJSONSerialization isValidJSONObject:obj])
    {
        NSError *error = nil;
        NSData *serializedObj = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
        if (serializedObj == nil)
        {
            NSLog(@"Unable to serialize header: %@", obj);
        }
        else
        {
            obj = [[NSString alloc] initWithData:serializedObj encoding:NSUTF8StringEncoding];
        }
    }
    return obj;
}

- (NSURLRequest *) signedRequestWithServiceURL:(NSURL *)serviceURL;
{
    NSMutableURLRequest *request = [[self requestWithServiceURL:serviceURL] mutableCopy];

    NSString *authorization = [self authorization];
    if ([authorization length])
    {
        [request setValue:authorization forHTTPHeaderField:MGPHTTPCommandAuthorizationHeader];
    }

    return request;
}

- (BOOL) secure;
{
    return NO;
}

- (NSString *) httpHost;
{
    return @"localhost";
}

- (NSURLRequest *) request;
{
    NSString *protocol = [self secure] ? @"https" : @"http";
    NSString *host = [self httpHost];
    NSString *defaultServiceURL = [NSString stringWithFormat:@"%@://%@", protocol, host];

    return [self requestWithServiceURL:[NSURL URLWithString:defaultServiceURL]];
}

- (NSURLRequest *) signedRequest;
{
    NSMutableURLRequest *request = [[self request] mutableCopy];
    NSString *authorizationValue = [self authorization];
    if (authorizationValue)
    {
        [request setValue:authorizationValue forHTTPHeaderField:MGPHTTPCommandAuthorizationHeader];
    }
    return request;
}

- (NSString *) authorization;
{
    return nil;
}

- (void) processHeaders:(NSDictionary *)headers;
{
}
- (id) deserializeResponse:(NSData *)responseData;
{
    return responseData;
}

- (BOOL) completeWithResponse:(id)response;
{
    NSString *message = [NSString stringWithFormat:@"Must Implement %@ in Subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])];
    @throw [NSException exceptionWithName:@"Method Not Implemented" reason:message userInfo:nil];

    return NO;
}

@end

@implementation NSDictionary (URLAdditions)

- (NSString *) stringFromQueryParameters;
{
    NSMutableString *buffer = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(id index, id obj, BOOL *stop) {
        NSString *key = index;
        NSString *value = obj;
        if ([value isKindOfClass:[NSArray class]])
        {
            value = [obj componentsJoinedByString:@","];
        }
        [buffer appendFormat:@"%@=%@&",
         [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
         [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }];

    return [buffer substringToIndex:[buffer length]-1]; //Remove extra & at end
}

@end

