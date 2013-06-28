#IKBCommandBus

A command bus for Objective-C apps. Compatible with iOS, Mac OS X and GNUstep.

#Usage

Commands describe requests from your application for work to be done, and should conform to the `IKBCommand` protocol. Add whatever properties you need to describe the work that needs doing. Submit them thus:

    [[IKBCommandBus applicationCommandBus] execute: command];

The bus looks for an appropriate `IKBCommandHandler` subclass to schedule in response to a command: command handlers define the work that is done when a given command is requested. Register handler classes with `+[IKBCommandBus registerHandlerClass:]`; the bus assumes that there will be one handler for every command it receives.

See [Separating User Interface From Work](http://blog.securemacprogramming.com/2013/06/separating-user-interface-from-work/) for more discussion of the pattern.

## Usage on iOS

To build for iOS, you need to run the "Real Framework" install script from [iOS-Universal-Framework](http://github.com/kstenerud/iOS-Universal-Framework).

#Licence

MIT. See the comments in the source files.