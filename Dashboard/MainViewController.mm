//
//  ViewController.m
//  Dashboard
//
//  Created by Siddhanta Dange on 8/15/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //set up camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraImageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus

- (void)processImage:(Mat&)origImage{
    //correct image
    cv::Mat image(origImage.rows, origImage.cols, origImage.type());
    origImage.copyTo(image);
    flip(image, image, 0); //flip around x-axis
    
//    
//    //copy original image to workable image
//  //  Mat image(origImage.rows, origImage.cols, origImage.type());
//  //  origImage.copyTo(image);
//    
//    //correct image
//    transpose(origImage, origImage);
//    flip(origImage, origImage, 0);
//    
////    Mat newImage(origImage.rows,origImage.cols,origImage.type());
////    
////    //filter image
////    cvtColor(origImage, newImage, CV_BGRA2GRAY);
////    equalizeHist(newImage, newImage);
////    blur(newImage, newImage, cv::Size(11,11));
////    threshold(newImage, newImage, 20.0, 255.5, THRESH_BINARY_INV);
////    erode(newImage, newImage, cv::Mat(3,5,CV_8U));
////    Canny(newImage, newImage, 0, 40);
////    
////    //capture contours
////    vector<vector<cv::Point>>allContours;
////    vector<vector<cv::Point>>definedContours;
////    findContours(newImage, allContours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE); 
////    [self removeNoise:&allContours withThresh:15];
////    
////    //write to original image to display on iPhone
// //  origImage.convertTo(origImage, CV_8U);
//  //  image.copyTo(origImage);
    image.copyTo(origImage);
    
}

#endif

-(void)viewDidAppear:(BOOL)animated{
    [self.videoCamera start];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.videoCamera stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
