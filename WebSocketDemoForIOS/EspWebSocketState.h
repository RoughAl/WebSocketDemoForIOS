//
//  EspWebSocketState.h
//  WebSocketDemoForIOS
//
//  Created by 白 桦 on 9/22/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EspWebSocketState : NSObject

- (BOOL) isDisconnected;

- (BOOL) isConnected;

- (BOOL) isSubscribe;

- (void) setDisconnected;

- (void) setConnected;

- (void) setSubscribe;

@end
