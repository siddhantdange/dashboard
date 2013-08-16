//
//  Networking.h
//  Dashboard
//
//  Created by Joshua Alexander on 8/16/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * kHostAddress;
extern uint32_t kPort;

@interface ConnectionAPI : NSObject <NSStreamDelegate>

- (id)initConnectionToHost:(NSString *)host port:(uint32_t)port;

- (void)sendX:(float)x Y:(float)y H:(unsigned short)h;

@end
