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
@property (nonatomic, assign) float recentArea, x, y;

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

struct allContoursComparitor {
    bool operator ()(vector<cv::Point> const& a, vector<cv::Point> const& b) const {
        return contourArea(a) > contourArea(b);
    }
};

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
    threshold(image, image, 30.0, 255.0, CV_THRESH_BINARY);
    
    //morphological operators
    dilate(image, image, Mat(3,3, CV_8U));
    erode(image, image, Mat(7,7, CV_8U));
    
    Canny(image, image, 100, 200);
    

    vector<vector<cv::Point>>allContours;
    findContours(image, allContours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    
    image = Mat::zeros(image.rows, image.cols, image.type());

    //qualify contours based on circular size to area
    if(allContours.size() > 5){
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
        dilate(image, image, Mat(3,3, CV_8U));
        
        findContours(image, allContours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
        
        image = Mat::zeros(image.rows, image.cols, image.type());
        if(allContours.size()){
            
            
            sort(allContours.begin(), allContours.end(), allContoursComparitor());
            Point2f center;
            float radius;
            minEnclosingCircle(allContours[0], center, radius);
            
            float circArea = M_PI * radius * radius;
            if(self.frameCount > 10 && self.frameCount < 20){
                self.recentArea = ((self.recentArea * (self.frameCount - 11)) + circArea)/(float)(self.frameCount - 10);
                
                if(self.frameCount == 19){
                    self.x = center.x;
                    
                }
            }
            
            //match area and zone
            if(abs(circArea/self.recentArea) > 0.9 && abs(center.x/self.x) > 0.6){
                circle(image, center, radius, Scalar(255.0, 255.0, 255.0));
                
                float percX =  (center.x - self.x)/center.x;
                float percY = (center.y - self.y)/center.y;
                
                cout << "xPerc: " << percX << " yPerc: " << percY << endl;
                
                self.x = center.x;
                self.y = center.y;
            }
        }
    }
    
    self.frameCount++;
    if(self.frameCount > 5000){
        self.frameCount = 50;
    }
    image.copyTo(origImage);
    
}

void findGreatestAreaContour(vector<vector<cv::Point>> contours, int &idx){
    float maxArea = contourArea(contours[0]);
    for (int i = 1; i < contours.size(); i++) {
        if(contourArea(contours[i]) > maxArea){
            idx = i;
        }
    }
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
