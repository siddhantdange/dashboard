//
//  Networking.m
//  Dashboard
//
//  Created by Joshua Alexander on 8/16/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import "Networking.h"

NSString * kHostAddress = @"10.73.7.168";
uint32_t kPort = 1234;

@interface ConnectionAPI()
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint32_t port;
@property (nonatomic, strong) NSOutputStream *outputStream;
@end

@implementation ConnectionAPI

- (id)initConnectionToHost:(NSString *)host port:(uint32_t)port
{
    if (self=[super init]) {
        self.host = host;
        self.port = port;
        
//        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        CFStringRef host = (__bridge CFStringRef)self.host;//CFSTR("10.73.7.168");
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, self.port, /*&readStream*/NULL, &writeStream);
        
//        NSInputStream *inputStream = (__bridge NSInputStream *)readStream;
        self.outputStream = (__bridge NSOutputStream *)writeStream;
        
//        [inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        
//        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
//        [inputStream open];
        [self.outputStream open];
    }
    return self;
}

- (void)sendX:(float)x Y:(float)y H:(unsigned short)h
{
    NSLog(@"sending data: (%f, %f, %d)", x, y, h);
    NSString *dataStr  = [NSString stringWithFormat:@"%f,%f,%d\n", x, y, h];
    NSData *data = [[NSData alloc] initWithData:[dataStr dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes] maxLength:[data length]];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    NSLog(@"stream event %d", streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
//            if (theStream == inputStream) {
//                
//                uint8_t buffer[1024];
//                int len;
//                
//                while ([inputStream hasBytesAvailable]) {
//                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
//                    if (len > 0) {
//                        
//                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
//                        
//                        if (nil != output) {
//                            NSLog(@"server said: %@", output);
//                            [self messageReceived:output];
//                        }
//                    }
//                }
//            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can't connect to server");
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"event end encountered");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        default:
            NSLog(@"Unknown event");
    }
}

@end
