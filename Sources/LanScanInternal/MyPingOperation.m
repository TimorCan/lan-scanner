//
//  MyPingOperation.m
//  WhiteLabel-Test
//
//  Created by Michael Mavris on 03/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MyPingOperation.h"
#import "LanScan.h"

static const float PING_TIMEOUT = TIMEOUT;

@interface MyPingOperation ()
@property (nonatomic,strong) NSString *ipStr;
@property (nonatomic,strong) NSDictionary *brandDictionary;
@property(nonatomic,strong)MySimplePing *SimplePing;
@property (nonatomic, copy) void (^result)(NSError  * _Nullable error, NSString  * _Nonnull ip);
@end

@interface MyPingOperation()
- (void)finish;
@end

@implementation MyPingOperation {
    BOOL _stopRunLoop;
    NSTimer *_keepAliveTimer;
    NSError *errorMessage;
    NSTimer *pingTimer;
}

-(instancetype)initWithIPToPing:(NSString*)ip andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip))result;{

    self = [super init];
    
    if (self) {
        self.name = ip;
        _ipStr= ip;
        _SimplePing = [MySimplePing MySimplePingWithHostName:ip];
        _SimplePing.delegate = self;
        _result = result;
        _isExecuting = NO;
        _isFinished = NO;
    }
    
    return self;
};

-(void)start {

    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    // Run loops don't run if they don't have input sources or timers on them.  So we add a timer that we never intend to fire.
    _keepAliveTimer = [NSTimer timerWithTimeInterval:1000000.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
    [runLoop addTimer:_keepAliveTimer forMode:NSDefaultRunLoopMode];
    
    //Ping method
    [self ping];
    
    NSTimeInterval updateInterval = 0.1f;
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];
    
    while (!_stopRunLoop && [runLoop runMode: NSDefaultRunLoopMode beforeDate:loopUntil]) {
        loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];
    }

}
-(void)ping {
    [self.SimplePing start];
}
- (void)finishedPing {
    
    //Calling the completion block
    if (self.result) {
        self.result(errorMessage,self.name);
    }
    
    [self finish];
}

- (void)timeout:(NSTimer*)timer
{
    //This method should never get called. (just in case)
    errorMessage = [NSError errorWithDomain:@"Ping Timeout" code:10 userInfo:nil];
    [self finishedPing];
}

-(void)finish {

    //Removes timer from the NSRunLoop
    [_keepAliveTimer invalidate];
    _keepAliveTimer = nil;
    
    //Kill the while loop in the start method
    _stopRunLoop = YES;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}
#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)MySimplePing:(MySimplePing *)pinger didStartWithAddress:(NSData *)address {
    
    if (self.isCancelled) {
        [self finish];
        return;
    }
    
    [pinger sendPingWithData:nil];
}

- (void)MySimplePing:(MySimplePing *)pinger didFailWithError:(NSError *)error {
  
    [pingTimer invalidate];
    errorMessage = error;
    [self finishedPing];
}

- (void)MySimplePing:(MySimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
    
    [pingTimer invalidate];
    errorMessage = error;
    [self finishedPing];
}

- (void)MySimplePing:(MySimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
   
    [pingTimer invalidate];
    [self finishedPing];
}

- (void)MySimplePing:(MySimplePing *)pinger didSendPacket:(NSData *)packet {
    //This timer will fired pingTimeOut in case the MySimplePing don't answer in the specific time
    pingTimer = [NSTimer scheduledTimerWithTimeInterval:PING_TIMEOUT target:self selector:@selector(pingTimeOut:) userInfo:nil repeats:NO];
}

- (void)pingTimeOut:(NSTimer *)timer {
    // Move to next host
    errorMessage = [NSError errorWithDomain:@"Ping timeout" code:11 userInfo:nil];
    [self finishedPing];
}

@end
