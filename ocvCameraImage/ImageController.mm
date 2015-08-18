//
//  ImageController.m
//  CameraImage
//
//  Created by masui masanori on 2014/09/23.
//  Copyright (c) 2014年 masanori. All rights reserved.
//

#import "ocvCameraImage-Bridging-Header.h"
#import <opencv2/opencv.hpp>
#import "opencv2/imgcodecs/ios.h"

@interface ImageController()
@property (nonatomic)CVImageBufferRef ibrImageBuffer;
@property (nonatomic)CGColorSpaceRef csrColorSpace;
@property (nonatomic)uint8_t *baseAddress;
@property (nonatomic)size_t sztBytesPerRow;
@property (nonatomic)size_t sztWidth;
@property (nonatomic)size_t sztHeight;
@property (nonatomic)CGContextRef cnrContext;
@property (nonatomic)CGImageRef imrImage;
@property (nonatomic, strong)UIImage *imgCreatedImage;
@property (nonatomic, strong)UIImage *imgGray;
@property (nonatomic) cv::Scalar sclLineColor;
@end
@implementation ImageController

- (void) initImageController
{
    _sclLineColor = cv::Scalar(255, 255, 255);
}
- (UIImage *) createImageFromBuffer:(CMSampleBufferRef) sbrBuffer
{
    _ibrImageBuffer = CMSampleBufferGetImageBuffer(sbrBuffer);
    // ピクセルバッファのベースアドレスをロックする.
    CVPixelBufferLockBaseAddress(_ibrImageBuffer, 0);
    // ベースアドレスの取得.
    _baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(_ibrImageBuffer, 0);
//    _sztBytesPerRow = CVPixelBufferGetBytesPerRow(_ibrImageBuffer);
    // サイズの取得.
    _sztWidth = CVPixelBufferGetWidth(_ibrImageBuffer);
    _sztHeight = CVPixelBufferGetHeight(_ibrImageBuffer);
    
    
    cv::Mat matEdge((int)_sztHeight, (int)_sztWidth, CV_8UC4, (void*)_baseAddress);
    
    // 90°回転.
    cv::transpose(matEdge, matEdge);
    // 左右反転.
    cv::flip(matEdge, matEdge, 1);
    
    
    cv::cvtColor(matEdge, matEdge, cv::COLOR_BGR2GRAY);
    
    std::vector< std::vector < cv::Point > > vctContours;
    std::vector< cv::Vec4i > vctHierarchy;
    
    // Cannyアルゴリズムを使ったエッジ検出
    Canny(matEdge, matEdge, 100, 100, 3);
    // 輪郭を取得する
    cv::findContours(matEdge, vctContours, vctHierarchy, cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE);
    
    // 輪郭を表示する
    matEdge = cv::Mat::zeros(matEdge.size(), CV_8UC3 );
    
    cv::drawContours(matEdge, vctContours, -1, _sclLineColor, 1);
    
    _imgCreatedImage = MatToUIImage(matEdge);
    
    vctContours.clear();
    vctHierarchy.clear();
    matEdge.release();
    
/*    // RGBの色空間.
    _csrColorSpace = CGColorSpaceCreateDeviceRGB();
    _cnrContext = CGBitmapContextCreate(_baseAddress
                                                    , _sztWidth
                                                    , _sztHeight
                                                    , 8
                                                    , _sztBytesPerRow
                                                    , _csrColorSpace
                                                    , kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    _imrImage = CGBitmapContextCreateImage(_cnrContext);
    _imgCreatedImage = [UIImage imageWithCGImage:_imrImage scale:1.0f
                                     orientation:UIImageOrientationRight];
    
    _imgCreatedImage = [self getGrayScaleImage:_imgCreatedImage];
    
    // 解放
    CGImageRelease(_imrImage);
    CGContextRelease(_cnrContext);
    CGColorSpaceRelease(_csrColorSpace);*/
    
    
    // ベースアドレスのロックを解除
    CVPixelBufferUnlockBaseAddress(_ibrImageBuffer, 0);
    
    return _imgCreatedImage;
}
- (UIImage *) getGrayScaleImage : (UIImage *)imgSorce
{
    // 画像をグレイスケール化.
    cv::Mat matGray;
    UIImageToMat(imgSorce, matGray);
    
    cv::cvtColor(matGray, matGray, cv::COLOR_BGR2GRAY);
    
    _imgGray = MatToUIImage(matGray);
    matGray.release();
    
    return imgSorce;
}

@end
