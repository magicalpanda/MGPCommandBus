//
//  OPDownloadImageCommand.h
//  Committed
//
//  Created by Saul Mora on 5/12/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import "MGPHTTPCommand.h"

@interface MGPHTTPImageCommand : MGPHTTPCommand

@property (nonatomic, copy, readonly) NSURL *imageURL;

- (instancetype) initWithURL:(NSURL *)imageURL;

@end

