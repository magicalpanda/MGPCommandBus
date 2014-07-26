//
//  NSNumber+HTTPStatusAdditions.h
//  Committed
//
//  Created by Saul Mora on 5/18/14.
//  Copyright (c) 2014 MagicalPanda Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (HTTPStatusAdditions)

- (BOOL) isSuccess;
- (BOOL) isSuccessWithNoContent;
- (BOOL) isRedirect;
- (BOOL) isNotAuthorized;
- (BOOL) isNotFound;

@end