//
//  EspWebSocketState.m
//  WebSocketDemoForIOS
//
//  Created by 白 桦 on 9/22/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import "EspWebSocketState.h"
#define FLAG_DISCONNECTED   1
#define FLAG_CONNECTED      2
#define FLAG_SUBSCRIBE      4

@interface EspWebSocketState()

@property(atomic, assign) int state;

@end

@implementation EspWebSocketState

- (id)init
{
    self = [super init];
    if (self) {
        self.state = 0;
    }
    return self;
}

- (BOOL) isDisconnected
{
    return (self.state & FLAG_DISCONNECTED) != 0;
}

- (BOOL) isConnected
{
    return (self.state & FLAG_CONNECTED) != 0;
}

- (BOOL) isSubscribe
{
    return (self.state & FLAG_SUBSCRIBE) != 0;
}

- (void) setDisconnected
{
    self.state = FLAG_DISCONNECTED;
}

- (void) setConnected
{
    self.state = FLAG_CONNECTED;
}

- (void) setSubscribe
{
    self.state = FLAG_SUBSCRIBE;
}

@end
