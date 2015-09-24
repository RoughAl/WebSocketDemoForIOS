//
//  EspWebSocketConnection.h
//  WebSocketDemoForIOS
//
//  Created by 白 桦 on 9/21/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

#define ESPWEBSOCKET_NSStringEncoding NSUTF8StringEncoding

@class EspWebSocketConnection;

@protocol EspWebSocketDelegate <NSObject>

/**
 * Fired when the WebSockets connection has been established. After this
 * happened, messages may be sent.
 *
 * @param webSocket
 *            the webSocket
 */
- (void)webSocketDidOpen:(EspWebSocketConnection *)webSocket;

/**
 * Fired when a message has been received
 *
 * @param webSocket
 *            the webSocket
 * @param message
 *            Text message payload or null (empty payload).
 */
- (void)webSocket:(EspWebSocketConnection *)webSocket didReceiveMessage:(id)message;

/**
 * Fired when the WebSockets connection encounter Error
 *
 * @param webSocket
 *            the webSocket
 * @param error
 *            Error
 */
- (void)webSocket:(EspWebSocketConnection *)webSocket didFailWithError:(NSError *)error;

/**
 * Fired when the WebSockets connection has deceased (or could not
 * established in the first place).
 *
 * @param webSocket
 *            the webSocket
 * @param code
 *            Close code.
 * @param reason
 *            Close reason (human-readable).
 * @param wasClean
 *            Whether the connection is cleaned
 */
- (void)webSocket:(EspWebSocketConnection *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

@interface EspWebSocketConnection : NSObject<SRWebSocketDelegate>

@property (nonatomic, weak) id <EspWebSocketDelegate> delegate;

/**
 * connect the ws asyn
 *
 *@param wsUrl
 *            the url of ws
 */
- (void) connectWithUrl:(NSString *)wsUrl;

/**
 * connect the ws syn(NOTE: don't call it in main Thread)
 *
 * @param wsUrl
 *            the url of ws
 * @return whether the connection is build up suc
 */
- (BOOL) connectBlockingWithUrl:(NSString*)wsUrl;

/**
 * disconnect the ws
 */
- (void) disconnect;

/**
 * send binary message
 * @param data the binary message
 */
- (void) sendBinaryMessage:(NSData *)data;

/**
 * send text message
 * @param message the text message
 */
- (void) sendTextMessage:(NSString *)message;

@end
