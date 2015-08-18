//
//  CameraViewController.swift
//  ocvCameraImage
//
//  Created by masui masanori on 2014/09/20.
//  Copyright (c) 2014年 masanori. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate
{
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var imgCameraView: UIImageView!
    var cpsSession: AVCaptureSession!
    //var videoDataOutputQueue: dispatch_queue_t!
    var imcImageController: ImageController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imcImageController = ImageController()
        // 初期化.
        imcImageController.initImageController()
    }
    override func viewWillAppear(animated: Bool)
    {
        // カメラの使用準備
        self.initCamera()
    }
    override func viewDidDisappear(animated: Bool)
    {
        self.cpsSession.stopRunning()
        for output in self.cpsSession.outputs
        {
            self.cpsSession.removeOutput(output as! AVCaptureOutput)
        }
        for input in self.cpsSession.inputs
        {
            self.cpsSession.removeInput(input as! AVCaptureInput)
        }
        self.cpsSession = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btnCancelTouched(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func initCamera()
    {
        var cpdCaptureDevice: AVCaptureDevice!
        
        // 背面カメラの検索
        for device: AnyObject in AVCaptureDevice.devices()
        {
            if device.position == AVCaptureDevicePosition.Back
            {
                cpdCaptureDevice = device as! AVCaptureDevice
            }
        }
        // カメラが見つからなければリターン
        if (cpdCaptureDevice == nil) {
            println("Camera couldn't found")
            return
        }
        cpdCaptureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        
        // 入力データの取得
        var deviceInput: AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(cpdCaptureDevice, error: nil) as! AVCaptureDeviceInput
        
        // 出力データの取得
        var videoDataOutput:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        
        // カラーチャンネルの設定.
        let dctPixelFormatType : Dictionary<NSString, NSNumber> = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA]
        videoDataOutput.videoSettings = dctPixelFormatType
        
        // 画像をキャプチャするキューの指定
        //var videoDataOutputQueue: dispatch_queue_t = dispatch_queue_create("CtrlVideoQueue", DISPATCH_QUEUE_SERIAL)
        videoDataOutput.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        // セッションの使用準備
        self.cpsSession = AVCaptureSession()
        
        if(self.cpsSession.canAddInput(deviceInput))
        {
            self.cpsSession.addInput(deviceInput as AVCaptureDeviceInput)
        }
        else
        {
            NSLog("Failed adding Input")
        }
        if(self.cpsSession.canAddOutput(videoDataOutput))
        {
            self.cpsSession.addOutput(videoDataOutput)
        }
        else
        {
            NSLog("Failed adding Output")
        }
        self.cpsSession.sessionPreset = AVCaptureSessionPresetMedium
        
        self.cpsSession.startRunning()
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        // SampleBufferから画像を取得してUIImageViewにセット.
        imgCameraView.image = imcImageController.createImageFromBuffer(sampleBuffer)
        
    }
    /*func imageFromSampleBuffer(sampleBuffer: CMSampleBufferRef) -> UIImage
    {
        // ピクセルバッファの取得.
        var imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // ピクセルバッファのベースアドレスをロックする
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get information of the image
        var baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        var bytesPerRow:size_t = CVPixelBufferGetBytesPerRow(imageBuffer);
        var width:size_t = CVPixelBufferGetWidth(imageBuffer);
        var height:size_t = CVPixelBufferGetHeight(imageBuffer);
        
        // RGBの色空間
        var colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB();
        
        
        var newContex:CGContextRef = CGBitmapContextCreate(baseAddress,
            width,
            height,
            8,
            bytesPerRow,
            colorSpace,
            CGBitmapInfo(CGImageAlphaInfo.PremultipliedFirst.toRaw()))
        
        var imageRef:CGImageRef = CGBitmapContextCreateImage(newContex);
        var ret:UIImage = UIImage(CGImage: imageRef);
        
        //CGImageRelease(imageRef);
        //CGContextRelease(newContext);
        //CGColorSpaceRelease(colorSpace);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        return ret;
    }*/
}