//
//  main.m
//  fakepoints
//
//  Created by Joshua Alexander on 8/16/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

const unsigned SLEEP_TIME = 0.05;

void doit() {
    
    NSLog(@"** starting doit()");
    
    NSMutableString *s = [NSMutableString stringWithString:@""];
    
    int height = 0;
    unsigned num = 0;
    
    CGPoint lastPoint = CGPointZero;
    
    while (1) {
        CGEventRef event = CGEventCreate(NULL);
        CGPoint cursor = CGEventGetLocation(event);
        CFRelease(event);
        
        if (cursor.x != lastPoint.x && cursor.y != lastPoint.y) {
            lastPoint = cursor;
            //NSLog(@"cursor = %f %f", cursor.x, cursor.y);
            
            if (cursor.y < 100)
                break;
            
            num++;
            if (num%100 == 0)
                NSLog(@"num = %u", num); // logs current number of points every 100 points
            
            [s appendFormat:@"%f,%f,%d\n", cursor.x, cursor.y, height];
        }
        else if (lastPoint.x == 0 && lastPoint.y == 0) {
            lastPoint = cursor;
        }
        
        sleep(SLEEP_TIME);
    }
    
    NSLog(@"s = \n\n%@\n\n", s);
    
    NSError *error = nil;
    NSString *home = NSHomeDirectory();
    BOOL success = [s writeToFile:[NSString stringWithFormat:@"%@/fakepoints.csv", home] atomically:NO encoding:NSASCIIStringEncoding error:&error];
    if (!success) {
        NSLog(@"error - %@ %@", error, [error userInfo]);
    }
    else if (success) {
        NSLog(@"write was successful - Done.");
    }
}


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        doit();
//        NSLog(@"%s, %d, %s", __FILE__, __LINE__, __PRETTY_FUNCTION__);
    }
    return 0;
}

