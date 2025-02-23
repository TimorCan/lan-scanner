//
//  PingOperation.h
//
//  Created by Michael Mavris on 03/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MySimplePing.h"

@interface MyPingOperation : NSOperation <MySimplePingDelegate> {
    BOOL _isFinished;
    BOOL _isExecuting;
}
-(nullable instancetype)initWithIPToPing:(nonnull NSString*)ip andCompletionHandler:(nullable void (^)(NSError  * _Nullable error, NSString  * _Nonnull ip))result;

@end
