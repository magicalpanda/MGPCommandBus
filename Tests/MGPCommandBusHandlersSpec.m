
#import "Specta.h"
#import "MGPCommandBus+Private.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "TestHelpers.h"

SpecBegin(MGPCommandBusHandlers)

describe(@"CommandBus Handlers", ^{

    __block MGPCommandBus *testBus = nil;
    
    beforeEach(^{
        testBus = [MGPCommandBus new];
        [[testBus queue] setSuspended:YES];
    });
    
    describe(@"handlers", ^{
        
        describe(@"registering", ^{
            
            context(@"one handler", ^{
                beforeEach(^{
                    [testBus registerCommandHandler:[TestCommandHandler new]];
                });
                
                it(@"should be registered", ^{
                    expect([testBus handlers]).to.haveCountOf(1);
                });
            });
            
            context(@"mutliple handlers of different classes", ^{
                beforeEach(^{
                    [testBus registerCommandHandler:[TestCommandHandler new]];
                    [testBus registerCommandHandler:[BoringCommandHandler new]];
                });
                
                it(@"should register all handlers", ^{
                    expect([testBus handlers]).to.haveCountOf(2);
                });
            });
            
            context(@"by class", ^{
                
                beforeEach(^{
                    [testBus registerCommandHandlerClass:[TestCommandHandler class]];
                });
                
                it(@"should be registered", ^{
                    expect([testBus handlers]).to.haveCountOf(1);
                });
            });
            
            context(@"multiple hanlder instances of the same class", ^{
                NSInteger numberOfHandlers = 2;
                
                beforeEach(^{
                    [@(numberOfHandlers) times:^{
                        [testBus registerCommandHandler:[TestCommandHandler new]];
                    }];
                });
                
                it(@"should register all handlers", ^{
                    expect([testBus handlers]).to.haveCountOf(numberOfHandlers);
                });
            });
        });
    });
});


SpecEnd