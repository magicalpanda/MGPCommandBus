//Copyright (c) 2013 Graham Lee
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "MGPCommand.h"
#import "MGPCommandHandler.h"
#import "MGPSubCommandHandler.h"

#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import "NSApplication+MGPCommandBus.h"
#else
#import "UIApplication+MGPCommandBus.h"
#endif

/**
 * The command bus accepts commands from the application and schedules work
 * to fulfil those commands.
 */
@interface MGPCommandBus : NSObject

///**
// * A convenience method to get a shared bus everywhere in your app. While
// * MGPCommandBus is not a singleton, you need to register handlers and
// * submit commands to the same bus which can be arranged via this method.
// */
//+ (instancetype)applicationCommandBus;

- (void) cancelAllCommands;

/**
 Check if a command as configured can be executed. Useful for determining if
 visual state of onscreen elements such as buttons to toggle as on or off.
 */
- (BOOL) commandCanExecute:(id<MGPCommand>)command;

/**
 * Request a command be performed. The command should conform to MGPCommand,
 * and additionally specify any additional data needed. As an example, a
 * contacts app might have an "add person" command which carries a name,
 * phone number, email address and so on.
 
 @return BOOL specifies if the command was handled by a handler
 */
- (BOOL) execute:(id<MGPCommand>)command;

- (BOOL) execute:(id<MGPCommand>)priorCommand before:(id<MGPCommand>)laterCommand;
- (BOOL) execute:(id<MGPCommand>)laterCommand after:(id<MGPCommand>)priorCommand;

/**
 * Add a handler object to the command bus.
 */
- (void) registerCommandHandler:(id<MGPCommandHandler>)handler;
- (void) registerCommandHandlers:(id<NSFastEnumeration>)handlers;

//- (void) registerHandlerClasses:(id<NSFastEnumeration>)classes;
//- (void) registerCommandHandlerClass:(Class)klass;

@end
