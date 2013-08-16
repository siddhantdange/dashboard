//
//  Networking.m
//  Dashboard
//
//  Created by Joshua Alexander on 8/16/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import "Networking.h"
#import "GCDAsyncUdpSocket.h"

NSString * kHostAddress = @"10.73.7.168";
uint32_t kPort = 1234;

@interface ConnectionAPI() <GCDAsyncUdpSocketDelegate>
@property (nonatomic, strong) GCDAsyncUdpSocket *sock;
@end

@implementation ConnectionAPI

- (id)initConnectionToHost:(NSString *)host port:(uint32_t)port
{
    if (self=[super init]) {
        self.sock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        if (![self.sock connectToHost:host onPort:port error:&error]) {
            NSLog(@"[Error] Connection didn't go - %@ %@", error, [error userInfo]);
        }
    }
    return self;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"congrats! connected to %@", address);
}

- (void)sendX:(float)x Y:(float)y H:(unsigned short)h
{
    NSLog(@"sending data: (%f, %f, %d)", x, y, h);
    NSString *dataStr  = [NSString stringWithFormat:@"%f,%f,%d\n", x, y, h];
    NSData *data = [[NSData alloc] initWithData:[dataStr dataUsingEncoding:NSASCIIStringEncoding]];
    //[self.outputStream write:[data bytes] maxLength:[data length]];
    [self.sock sendData:data withTimeout:10 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"sent data with tag %ld", tag);
}
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"socket closed with error %@ %@", error, [error userInfo]);
}

@end
