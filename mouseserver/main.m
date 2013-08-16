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
@end
@implementation ConnectionAPI
- (id)initConnectionIntoPort:(uint32_t)port
{
    if (self=[super init]) {
    }
    return self;
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

