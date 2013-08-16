//
//  ViewController.h
//  Dashboard
//
//  Created by Siddhanta Dange on 8/15/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>

#ifdef __cplusplus

using namespace std;
using namespace cv;

#endif

@interface MainViewController : UIViewController <CvVideoCameraDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *cameraImageView;
@property (nonatomic, strong) CvVideoCamera* videoCamera;

@end
