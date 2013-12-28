//
//  IKBCommand_Private.h
//  IKBCommandBus
//
//  Created by Saul Mora on 12/28/13.
//
//

#import "IKBCommand.h"

@interface MGPCommand ()

- (void) commandWillStart;
- (void) commandDidComplete;
- (void) commandDidFailWithError:(NSError *)error;

@end
