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

/**
 * A command is an object that can be sent to a command bus to request
 * some action be performed. It also implements NSCoding, so that
 * event-sourcing applications can store and replay the commands.
 *
 * Commands do not express _how_ they are to be carried out, they only
 * explain _what_ the application wanted to happen.
 */
@protocol MGPCommand <NSObject, NSCoding>

/** The object from where the command was send. The sender will typicall receive callbacks when the command is complete, or has failed. 
 */
@property (weak, readwrite) id sender;

/** Command that must be run prior to the current command. The command bus will not execute any commands dependent on a failed command. If the command fails, the command will not be run.
 */
@property (weak, readwrite) id<MGPCommand> priorCommand;

- (void) commandWillStart;
- (void) commandDidComplete;
- (void) commandDidFailWithError:(NSError *)error;
- (void) commandDidNotStart;

- (void) removeAllChildCommands;

@optional

/**
 * This property is currently unused.
 */
@property (nonatomic, readonly) NSUUID *identifier;

/**
 Gives the command a chance to validate or perform any sanity checks prior to actually running on the bus and handed off to a handler
 */
- (BOOL) shouldExecute;

@end

@protocol MGPCommandCallback <NSObject>

@optional

/** Sent when a command was unable to be run on the command bus. Most likely, the prior command failed.
 */
- (void) commandDidNotStart:(id<MGPCommand>)command;

/** Sent when a command is on the bus and will begin execution. This may be called from any queue/thread.
 */
- (void) commandWillStart:(id<MGPCommand>)command;
/** Sent when a command has completed its task. This may be called from any queue/thread.
 */
- (void) commandDidComplete:(id<MGPCommand>)command;
/** Sent when command failed during execution. This may be called from any queue/thread.
 */
- (void) command:(id<MGPCommand>)command didFailWithError:(NSError *)error;

@end

@interface MGPCommand : NSObject<MGPCommand>

@property (copy, readonly) NSError *error;

@end
