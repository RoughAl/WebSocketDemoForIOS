//
//  EspViewController.m
//  WebSocketDemoForIOS
//
//  Created by 白 桦 on 9/22/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import "EspViewController.h"
#import "EspWebSocketState.h"
#import "ESPHttpClient.h"

#define MASTER_DEVICE_KEY       @"e61f7534b1d0e2642bee485a6b51fd105fd1a20c"


@interface EspViewController ()

@property(nonatomic, strong) EspWebSocketConnection *connection;
@property(nonatomic, strong) EspWebSocketState *webSocketState;
@property(nonatomic, assign) BOOL isConnectBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *labelConnectState;
@property (weak, nonatomic) IBOutlet UILabel *labelSubscribeState;
@property (weak, nonatomic) IBOutlet UITextView *tvSendStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnConnectDisconnect;
@property (weak, nonatomic) IBOutlet UIButton *btnSubscribe;
@property (weak, nonatomic) IBOutlet UIButton *btnSendRandomMessage;

@end

@implementation EspViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"EspViewController viewDidLoad");
    
    self.connection = [[EspWebSocketConnection alloc]init];
    self.connection.delegate = self;
    self.webSocketState = [[EspWebSocketState alloc]init];
    
    [self disalbeSubscribeButton];
    [self enableConnectButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSendStatusWithMessage:(NSString *) message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *statusHeader = @"send random message status:";
        NSString *statusStr = [NSString stringWithFormat:@"%@%@",statusHeader,message];
        self.tvSendStatus.text = statusStr;
    });
}

- (IBAction)btnTapAction:(id)sender
{
    if (sender == self.btnConnectDisconnect)
    {
        if (self.isConnectBtn)
        {
            // do connect action
            [self doConnectTask];
        }
        else
        {
            // do disconnect action
            [self disconnect];
        }
    }
    else if(sender == self.btnSendRandomMessage)
    {
        // send random message
        [self sendRandomMessage];
    }
    else if(sender == self.btnSubscribe)
    {
        // subscribe
        [self subscribe];
    }
}

/**
 * update UI about the status
 */
- (void) updateUI
{
    NSString *tvConnectTitle = @"Connect";
    NSString *tvDisconnectTitle = @"Disconnect";
    NSString *tvSubscribeTitle = @"Subscribe";
    NSString *tvUnsubscribeTitle = @"Unsubscribe";
    if (self.webSocketState.isConnected)
    {
        self.labelSubscribeState.text = tvUnsubscribeTitle;
        self.labelConnectState.text = tvConnectTitle;
    }
    else if (self.webSocketState.isDisconnected)
    {
        self.labelSubscribeState.text = tvUnsubscribeTitle;
        self.labelConnectState.text = tvDisconnectTitle;
    }
    else if(self.webSocketState.isSubscribe)
    {
        self.labelSubscribeState.text = tvSubscribeTitle;
    }
}

/**
 * enable subscribe button could be tapped
 */
- (void) enalbeSubscribeButton
{
    NSLog(@"enalbeSubscribeButton");
    if(self.webSocketState.isDisconnected)
    {
        NSLog(@"before subscribing, connect should be built up");
        assert(0);
    }
    [self.btnSubscribe setEnabled:YES];
    self.btnSubscribe.alpha = 1.0f;
    [self updateUI];
}

/**
 * disable subscribe button could be tapped
 */
- (void) disalbeSubscribeButton
{
    [self.btnSubscribe setEnabled:NO];
    self.btnSubscribe.alpha = 0.4f;
    [self updateUI];
}

/**
 * enable connect button could be tapped
 */
- (void) enableConnectButton
{
    self.isConnectBtn = YES;
    NSString *btnTitle = @"Connect";
    [self.btnConnectDisconnect setTitle:btnTitle forState:UIControlStateNormal];
    [self updateUI];
}

/**
 * enable disconnect button could be tapped
 */
- (void) enableDisconnectButton
{
    self.isConnectBtn = NO;
    NSString *btnTitle = @"Disconnect";
    [self.btnConnectDisconnect setTitle:btnTitle forState:UIControlStateNormal];
    [self updateUI];
}

- (void)alertCenter:(NSString *)message
{
    NSString *title = @"EspWebSocketDemo";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    NSLog(@"alert show");
    // dismiss after 1 seconds
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        NSLog(@"alert dismiss");
    });
}

/**
 * do connect task
 */
- (void) doConnectTask
{
    [self.spinner startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // ws://iot.espressif.cn:9000 is like http,
        // wss://iot.espressif.cn:9443 is like https
        NSString *url = @"wss://iot.espressif.cn:9443/";
        __block BOOL isConnectSuc = [self.connection connectBlockingWithUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            if (isConnectSuc)
            {
                [self alertCenter:@"Web socket connect suc"];
            }
            else
            {
                [self alertCenter:@"Web socket connect fail"];
            }
        });
    });
}

- (void) connectSuc
{
    NSLog(@"EspViewController connectSuc");
    [self.webSocketState setConnected];
    [self enableDisconnectButton];
    [self enalbeSubscribeButton];
}

- (void) disconnect
{
    NSLog(@"EspViewController disconnect");
    [self.connection disconnect];
    [self.webSocketState setDisconnected];
    [self enableConnectButton];
    [self disalbeSubscribeButton];
}

- (void) subscribe
{
    NSString *request = [NSString stringWithFormat:@"{\"path\": \"/v1/mbox/\", \"method\": \"POST\", \"body\": {\"action\": \"subscribe\", \"type\": \"datastream\", \"stream\": \"light\"}, \"meta\": {\"Authorization\": \"token %@\"}}", MASTER_DEVICE_KEY];
    NSLog(@"EspViewController subscribe:%@",request);
    [self.connection sendTextMessage:request];
}

- (void) subscribeSuc
{
    [self.webSocketState setSubscribe];
    [self disalbeSubscribeButton];
}

- (void) sendRandomMessage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = @"http://iot.espressif.cn/v1/datastreams/light/datapoint/";
        NSString *token = [NSString stringWithFormat:@"token %@",MASTER_DEVICE_KEY];
        NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:token
                                 ,@"Authorization", nil];
        NSDictionary *datapointValue = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"x",@"2",@"y",@"3",@"z", nil];
        NSDictionary *datapoint = [NSDictionary dictionaryWithObject:datapointValue forKey:@"datapoint"];
        NSDictionary *resp =
        [ESPHttpClient postSynPath:path headers:headers parameters:datapoint timeoutSeconds:10];
        NSLog(@"resp:%@",resp);
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma implement EspWebSocketDelegate

- (void)webSocketDidOpen:(EspWebSocketConnection *)webSocket
{
    NSLog(@"EspViewController webSocketDidOpen");
    [self connectSuc];
}

- (void)webSocket:(EspWebSocketConnection *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"EspViewController didReceiveMessage: %@", message);
    NSError *error = nil;
    NSDictionary *dict = nil;
    // NSString message
    if ([message isKindOfClass:[NSString class]])
    {
        dict = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:ESPWEBSOCKET_NSStringEncoding] options:NSJSONReadingMutableContainers error:&error];
    }
    if (dict==nil||error!=nil)
    {
        NSLog(@"EspViewController didReceiveMessage parse json error");
        [self disconnect];
        return;
    }
    BOOL isSubScribe = [[dict allKeys] containsObject:@"status"];
    if (isSubScribe)
    {
        int status = [[dict objectForKey:@"status"]intValue];
        if (status == 200)
        {
            NSLog(@"EspViewController onMessage subscribe suc");
            [self subscribeSuc];
        }
        else
        {
            NSLog(@"EspViewController onMessage subscribe fail");
        }
    }
    else
    {
        // NSString message
        if ([message isKindOfClass:[NSString class]])
        {
            [self alertCenter:message];
        }
    }    
}

- (void)webSocket:(EspWebSocketConnection *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"EspViewController didFailWithError");
    [self disconnect];
}

- (void)webSocket:(EspWebSocketConnection *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"EspViewController didCloseWithCode");
    [self disconnect];
}

@end
