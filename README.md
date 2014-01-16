MGPCommandBus README
--
The Command Bus motivations are simply to provide a way to decouple your visual aspects of apps from all the background processing. When you send a command to the bus, it will run asynchronously until completion, or failure. The command pattern helps provide a place for all logic for simple points of execution of services for your app.

The MGPCommandBus is a fork of the [IKBCommandBus](https://bitbucket.org/iamleeg/ikbcommandbus) originally [authored by Graham Lee](http://blog.securemacprogramming.com/2013/06/separating-user-interface-from-work/).

How to Use the Bus
--
Registering Handlers:

    id<MGPCommandHandler> handler = //...;
    [[UIApplication sharedApplication] commandBus] registerHandler:handler];
    

Or, to register a set of classes that will be instantiated on demand, in your application delegate, implement:

    - (id<NSFastEnumeration>)commandClasses;

The return value will commonly be an NSArray of Class objects.    

Sending commands:

    MGPCommand *command = //...;
    [[UIApplication sharedApplication] sendCommand:command]

To receive callbacks when commands have completed, in your sending class, implement the **MGPCommandCallback** protocol:

    @interface MyViewController : UIViewController<MGPCommandCallback>
    //...
    @end
    
Implement one of the callback methods:

    - (void) commandWillStart:(id<MGPCommand>)command;
    - (void) commandDidComplete:(id<MGPCommand>)command;
    - (void) command:(id<MGPCommand>)command didFailWithError:(NSError *)error;
    
Creating a batch command handler, you can subclass **MGPSubCommandHandler**, and implement the following methods

    - (void) commandHandlerDidCompleteCommand:(id<MGPCommand>)command progress:(float)progress;
    - (void) commandHandlerDidComplete;
    - (void) commandHandlerDidFail:(NSError *)error;

Installation
--
- Drag the MGPCommandBus project into your app as a sub project. 
- **iOS** - In the 'Link Binary with Library' step of your app's Build Phases, add the libMGPCommandBus-iOS library. 
- **Mac** - In the 'Link Binary with Library' step of your app's Build Phases, add the MGPCommandBus.framework.
- In the "Header Search Paths" setting, add $(SRCROOT)/relative/path/to/your/copy/of/MGPCommandBus/Library
- In your prefix file, add 
	
	\#import "MGPCommandBus.h" // for iOS Apps
	
	\#import \<MGPCommandBus/MGPCommandBus.h\> // for Mac Apps


License
--
The MIT License (MIT)

Copyright (c) 2014 Magical Panda Software, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

* attribution must include project name, "MGPCommandBus" and credit "Magical Panda Software, LLC"

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.