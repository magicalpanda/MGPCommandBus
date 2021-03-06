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

@protocol MGPCommand;

/**
 * A command handler represents the work that is scheduled by the bus upon
 * reception of a command.
 */
@protocol MGPCommandHandler <NSObject>

/**
 * Inspect the command and report whether this handler can execute
 * the work needed to fulfil the command.
 */
- (BOOL) canHandleCommand:(id<MGPCommand>)command;

///**
// Used to tell the bus that you want to handle the threading more manually. Will launch your command using an async command operation, and will use the execute:completion: method on the handler
// */
//- (BOOL) isAsynchronous;

@end

@protocol MGPSynchronousCommandHandler <MGPCommandHandler>

/**
 * Perform this work to satisfy the requested command.
 * @note This method will be executed in a context private to the command bus,
 *       don't make any assumptions about the thread or queue it's running in.
 *       Particularly, be aware that this method could be called concurrently
 *       on different threads.
 @parameter error an error that occured during operation
 @return BOOL indicate command succeeded or failed

 */
- (BOOL) executeCommand:(id<MGPCommand>)command error:(NSError **)error;

@end

@protocol MGPAsynchronousCommandHandler <MGPCommandHandler>

/**
 Perform the work to satisfy the command
 @note this method is expected to execute asynchronously and should not block on completion.
 You MUST fire the completion block in order for the command to complete.
 */
- (void) executeCommand:(id<MGPCommand>)command completion:(void (^)(BOOL,NSError *))completion;

@end
