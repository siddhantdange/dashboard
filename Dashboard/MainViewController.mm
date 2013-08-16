//
//  ViewController.m
//  Dashboard
//
//  Created by Siddhanta Dange on 8/15/13.
//  Copyright (c) 2013 Siddhanta Dange. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, assign) Mat *meanImage;
@property (nonatomic, assign) int frameCount;

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
    
    //set up mat
    self.frameCount = 0;
    self.meanImage = new Mat(352, 288, 0);
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus

- (void)processImage:(Mat&)origImage{
    //correct image
    cv::Mat image(origImage.rows, origImage.cols, origImage.type());
    transpose(origImage, image);
    flip(image, image, 0); //flip around x-axis
    cvtColor(image, image, CV_BGRA2RGB);
    cvtColor(image, image, CV_RGB2HSV);
    
    replaceMatWithChannel(&image, @"H", 1, 0, 100);
    
    float denom = 7.14 + pow(2.718281,_frameCount-10);
    float ALPHA = (1/denom) + 0.01;
    *_meanImage = ALPHA * image + (1-ALPHA) * *_meanImage;
    image -= *_meanImage;
    
    //TODO: use ML for threshold value
    threshold(image, image, 50.0, 255.0, CV_THRESH_BINARY);
    
    //morphological operators
    dilate(image, image, Mat(5,5, CV_8U));
    erode(image, image, Mat(3,3, CV_8U));
    
    vector<vector<cv::Point>>allContours;
    findContours(image, allContours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    image = Mat::zeros(image.rows, image.cols, image.type());
    
    //qualify contours based on circular size to area
    if(allContours.size()){
        float THRESHOLD_PERC = 0.6;
        
        
        
        for(int i = 0; i < allContours.size(); i++){
            //circle area
            Point2f center;
            float radius;
            minEnclosingCircle(allContours[i], center, radius);
            float circleArea = CV_PI * radius * radius;
            
            
            //contour area
            float cArea = contourArea(allContours[i]);
            
            if(cArea/circleArea > THRESHOLD_PERC){
                circle(image, center, radius, Scalar(255.0, 255.0, 255.0));
                allContours.erase(allContours.begin() + i);
                i--;
                
            }
        }
        
        //drawContours(image, allContours, -1, Scalar(255.0, 255.0, 255.0), CV_FILLED);
    }
    
    
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

//convert a 3-channel matrix to a specified single channel matrix
void replaceMatWithChannel(cv::Mat *original, NSString *channel, float multiplier, float constant, int threshold){
    int componentNum = 0;
    int cCap = 255;
    if([channel isEqual: @"H"] || [channel isEqual: @"R"]){
        componentNum = 0;
        cCap = 180;
    } else if([channel isEqual:@"S"] || [channel isEqual: @"G"]){
        componentNum = 1;
    } else if([channel isEqual:@"V"] || [channel isEqual: @"B"]){
        componentNum = 2;
    }
    
    cv::Mat channelMat(original->rows, original->cols, CV_8U);
    for (int i = 0; i < channelMat.rows; i++) {
        for (int j = 0; j < channelMat.cols; j++) {
            float realMultiplier = multiplier;
            
            if((int)original->at<Vec3b>(i,j)[componentNum] < threshold)
                realMultiplier = 1/multiplier;
            
            int cVal = ((int)original->at<Vec3b>(i,j)[componentNum] * realMultiplier) + constant;
            if(cVal > cCap)
                cVal = cCap;
            else if(cVal < 0)
                cVal = 0;
            channelMat.at<uchar>(i,j) = cVal;
        }
    }
    
    original->convertTo(*original, CV_8U);
    channelMat.copyTo(*original);
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
