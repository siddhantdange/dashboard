//
//  main.m
//  mouseserver
//
//  Created by Joshua Alexander on 8/16/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionAPI : NSObject <NSStreamDelegate>
- (id)initConnectionIntoPort:(uint32_t)port;
@property (nonatomic, strong) NSInputStream *inputStream;
@end
@implementation ConnectionAPI
- (id)initConnectionIntoPort:(uint32_t)port
{
    if (self=[super init]) {
//        CFReadStreamRef readStream;
//        //    CFWriteStreamRef writeStream;
//        
//        CFStringRef host = CFSTR("127.0.0.1");//(__bridge CFStringRef)self.host;//CFSTR("10.73.7.168");
//        
//        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, /*&writeStream*/NULL);
//        
//        NSInputStream *inputStream = (__bridge NSInputStream *)readStream;
//        //    self.outputStream = (__bridge NSOutputStream *)writeStream;
//        
//        [inputStream setDelegate:self];
//        //    [self.outputStream setDelegate:self];
//        
//        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        //    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        
//        [inputStream open];
//        //    [self.outputStream open];
        
        NSInputStream *inputStream = nil;
        NSOutputStream *outputStream = nil;
        NSHost *host = [NSHost hostWithAddress:@"127.0.0.1"];
        [NSStream getStreamsToHost:host port:port inputStream:&inputStream outputStream:nil];
        self.inputStream = inputStream;
        self.inputStream.delegate = self;
        
        if ([self.inputStream streamStatus] == NSStreamStatusNotOpen)
            [self.inputStream open];
        
//        if ([outStream streamStatus] == NSStreamStatusNotOpen)
//            [outStream open];
    }
    return self;
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    NSLog(@"stream event %d", (int)streamEvent);
    
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            NSLog(@"bytes available");
            if (theStream == self.inputStream) {
                uint8_t buffer[1024];
                NSInteger len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (output) {
                            NSLog(@"server said: %@", output);
                            //[self messageReceived:output];
                        }
                    }
                }
            }
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
            NSLog(@"Unknown event %d", (int)streamEvent);
    }
}
@end


void doit() {
    NSLog(@"starting connection");
    ConnectionAPI *conn = [[ConnectionAPI alloc] initConnectionIntoPort:1236];
    while (1) {
        
    }
    NSLog(@"ended doit");
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        doit();
    }
    return 0;
}

