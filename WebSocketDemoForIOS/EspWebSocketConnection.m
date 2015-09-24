//  EspWebSocketConnection.m
//  WebSocketDemoForIOS
//
//  Created by 白 桦 on 9/21/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import "EspWebSocketConnection.h"
#import "SRWebSocket.h"

@interface EspWebSocketConnection()

@property (atomic, strong) __block NSCondition *condition;

@property (nonatomic, assign) __block BOOL isConnectSuc;

@property (nonatomic, assign) __block BOOL isConnectFinished;

@property (atomic, strong) SRWebSocket *websocket;

@end

@implementation EspWebSocketConnection

- (id)init
{
    self = [super init];
    if (self) {
        self.isConnectFinished = NO;
        self.isConnectSuc = NO;
        self.condition = [[NSCondition alloc]init];
        self.websocket = nil;
    }
    return self;
}

- (void)dealloc
{
    [self disconnect];
}

- (void) __signal
{
    [self.condition lock];
    [self.condition signal];
    [self.condition unlock];
}

- (void) __wait
{
    [self.condition lock];
    [self.condition wait];
    [self.condition unlock];
}

- (void) __connectSuc
{
    self.isConnectFinished = YES;
    self.isConnectSuc = YES;
    // wake up connect blocking thread
    [self __signal];
}

- (void) __connectFail
{
    self.isConnectFinished = YES;
    self.isConnectSuc = NO;
    // wake up connect blocking thread
    [self __signal];
}

- (void) __clearConnectState
{
    self.isConnectFinished = NO;
    self.isConnectSuc = NO;
}

#pragma SRWebSocketDelegate implement
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if ([self.delegate respondsToSelector:@selector(webSocket:didReceiveMessage:)])
    {
        NSLog(@"EspWebSocketConnection didReceiveMessage");
        [self.delegate webSocket:self didReceiveMessage:message];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"EspWebSocketConnection did Open, current Thread:%@", [NSThread currentThread]);
    if ([self.delegate respondsToSelector:@selector(webSocketDidOpen:)])
    {
        NSLog(@"EspWebSocketConnection didOpen");
        [self.delegate webSocketDidOpen:self];
    }
    [self __connectSuc];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webSocket:didFailWithError:)])
    {
        NSLog(@"EspWebSocketConnection didFail");
        [self.delegate webSocket:self didFailWithError:error];
    }
    if (!self.isConnectFinished)
    {
        [self __connectFail];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if ([self.delegate respondsToSelector:@selector(webSocket:didCloseWithCode:reason:wasClean:)])
    {
        NSLog(@"EspWebSocketConnection didClose");
        [self.delegate webSocket:self didCloseWithCode:code reason:reason wasClean:wasClean];
    }
    if (!self.isConnectFinished)
    {
        [self __connectFail];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"EspWebSocketConnection didReceivePong");
}

#pragma implement EspWebSocketConnectiong.h
- (void) connectWithUrl:(NSString *)wsUrl
{
    NSLog(@"EspWebSocketConnection connectWithUrl:%@",wsUrl);
    // disconnect current connection
    [self disconnect];
    
    NSURL *url = [NSURL URLWithString:wsUrl];
    
    // clear connect state
    [self __clearConnectState];
    
    // init ws
    self.websocket = [[SRWebSocket alloc]initWithURL:url];
    self.websocket.delegate = self;
    
    NSString *scheme = [url scheme];
    if (![scheme isEqualToString:@"ws"] && ![scheme isEqualToString:@"wss"])
    {
        NSLog(@"unsupported scheme for WebSockets URI");
        assert(0);
    }
    
    if ([[url port]intValue] == 9000)
    {
        if (![scheme isEqualToString:@"ws"])
        {
            NSLog(@"port 9000 only support ws");
            assert(0);
        }
    }
    else if ([[url port]intValue] == 9443)
    {
        if (![scheme isEqualToString:@"wss"])
        {
            NSLog(@"port 9443 only support wss");
            assert(0);
        }
    }
    // open
    [self.websocket open];
}

- (BOOL) connectBlockingWithUrl:(NSString*)wsUrl
{
    if ([[NSThread currentThread] isEqual:[NSThread mainThread]])
    {
        NSLog(@"don't call connectBlockingWithUrl in main Thread,call connectWithUrl instead of it");
        assert(0);
    }
    [self connectWithUrl:wsUrl];
    
    // blocking until connect suc or fail
    NSLog(@"EspWebSocketConnection wait start");
    [self __wait];
    NSLog(@"EspWebSocketConnection wait end");
    return self.isConnectSuc;
}

- (void) disconnect
{
    if (self.websocket!=nil)
    {
        self.websocket.delegate = nil;
        [self.websocket close];
    }
}

- (void) sendBinaryMessage:(NSData *)data
{
    [self.websocket send:data];
}

- (void) sendTextMessage:(NSString *)message
{
    [self.websocket send:message];
}

@end
