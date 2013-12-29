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

@property (weak, readwrite) id sender;

@property (weak) id<MGPCommand> parentCommand;
@property (strong, readonly) NSSet *childCommands;

- (void) commandWillStart;
- (void) commandDidComplete;
- (void) commandDidFailWithError:(NSError *)error;

@optional

/**
 * This property is currently unused.
 */
@property (nonatomic, readonly) NSUUID *identifier;

@end

@protocol MGPCommandCallback <NSObject>

@optional

- (void) commandWillStart:(id<MGPCommand>)command;
- (void) commandDidComplete:(id<MGPCommand>)command;
- (void) commandDidFail:(id<MGPCommand>)command error:(NSError *)error;

@end

@interface MGPCommand : NSObject<MGPCommand>

@property (copy, readonly) NSError *error;
@property (assign, readwrite) id<MGPCommand> parentCommand;

@end

//
//@interface IKBCommand ()
//
//@property (nonatomic, assign, readwrite) IKBCommandBus *commandBus;
//
//@end
