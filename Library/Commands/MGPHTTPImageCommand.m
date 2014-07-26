//
//  OPDownloadImageCommand.m
//  Committed
//
//  Created by Saul Mora on 5/12/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPImageCommand.h"

@interface MGPHTTPImageCommand ()

@property (nonatomic, copy, readwrite) NSURL *imageURL;

@end


@implementation MGPHTTPImageCommand

- (instancetype) initWithURL:(NSURL *)imageURL;
{
    NSParameterAssert(imageURL);
    self = [super init];
    if (self)
    {
        self.imageURL = imageURL;
    }
    return self;
}

- (BOOL) isEqual:(id)object;
{
    return [object isKindOfClass:[self class]] && [self.imageURL isEqual:[object imageURL]];
}

- (NSURLRequest *)request;
{
    return [NSURLRequest requestWithURL:self.imageURL];
}

- (BOOL) completeWithResponse:(NSURL *)downloadedImageURL;
{
    return downloadedImageURL != nil;
}

@end
