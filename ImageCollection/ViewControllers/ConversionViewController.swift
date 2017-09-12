//
//  ConversionViewController.swift
//  ImageToPhoto
//
//  Created by Sumedh Ravi on 11/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ConversionViewController: UIViewController {
    
    var videoURL = NSURL(fileURLWithPath: "")
    
    @IBAction func nextButton(_ sender: Any) {
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "audioVC") as! AudioSelectionViewController
        newController.selectedVideo = videoURL
        navigationController?.pushViewController(newController, animated: true)
        
    }
    var userImages : [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = RenderSettings()
        let imageAnimator = ImageAnimator(renderSettings:settings, imageArray: userImages)
        videoURL = settings.outputURL
        imageAnimator.render(){
            print("yes")
        }

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    var images : [UIImage] = []

    struct RenderSettings {
        
        var width: CGFloat = 1280
        var height: CGFloat = 720
        var fps = 0.5   // 2 frames per second
        var avCodecKey = AVVideoCodecH264
        var videoFilename = "SampleVideo"
        var videoFilenameExt = "mp4"
        
        var size: CGSize {
            return CGSize(width: width, height: height)
        }
        
        var outputURL: NSURL {
            // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
            // Using the CachesDirectory ensures the file won't be included in a backup of the app.
            let fileManager = FileManager.default
            if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                return tmpDirURL.appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt) as NSURL
            }
            fatalError("URLForDirectory() failed")
        }
    }
    
    
    class ImageAnimator {
        
        // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
        static let kTimescale: Int32 = 600
        
        let settings: RenderSettings
        let videoWriter: VideoWriter
        var images: [UIImage]!
        
        var frameNum = 0
        
        class func saveToLibrary(videoURL: NSURL) {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL as URL)
                }) { success, error in
                    if !success {
                        print("Could not save video to photo library:", error!)
                    }
                }
            }
        }
        
        class func removeFileAtURL(fileURL: NSURL) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path!)
            }
            catch _ as NSError {
                // Assume file doesn't exist.
            }
        }
        
        init(renderSettings: RenderSettings,imageArray:[UIImage] ) {
            settings = renderSettings
            videoWriter = VideoWriter(renderSettings: settings)
            images = imageArray
        }
        
        func render(completion: @escaping ()->Void) {
            
            // The VideoWriter will fail if a file exists at the URL, so clear it out first.
            ImageAnimator.removeFileAtURL(fileURL: settings.outputURL)
            
            videoWriter.start()
            videoWriter.render(appendPixelBuffers: appendPixelBuffers) {
                //ImageAnimator.saveToLibrary(videoURL: self.settings.outputURL)
                completion()
            }
            
        }
        
        
        // This is the callback function for VideoWriter.render()
        func appendPixelBuffers(writer: VideoWriter) -> Bool {
            
            let frameDuration = CMTimeMake(Int64(Double(ImageAnimator.kTimescale) / settings.fps), ImageAnimator.kTimescale)
            
            while !images.isEmpty {
                
                if writer.isReadyForData == false {
                    // Inform writer we have more buffers to write.
                    return false
                }
                
                let image = images.removeFirst()
                let presentationTime = CMTimeMultiply(frameDuration, Int32(frameNum))
                let success = videoWriter.addImage(image: image, withPresentationTime: presentationTime)
                if success == false {
                    fatalError("addImage() failed")
                }
                
                frameNum += 1
            }
            
            // Inform writer all buffers have been written.
            return true
        }
        
    }

    
    class VideoWriter {
        
        let renderSettings: RenderSettings
        
        var videoWriter: AVAssetWriter!
        var videoWriterInput: AVAssetWriterInput!
        var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
        
        var isReadyForData: Bool {
            return videoWriterInput?.isReadyForMoreMediaData ?? false
        }
        
        class func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
            
            var pixelBufferOut: CVPixelBuffer?
            
            let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
            if status != kCVReturnSuccess {
                fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
            }
            
            let pixelBuffer = pixelBufferOut!
            
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            let data = CVPixelBufferGetBaseAddress(pixelBuffer)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                    bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            context!.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            let horizontalRatio = size.width / image.size.width
            let verticalRatio = size.height / image.size.height
            //aspectRatio = max(horizontalRatio, verticalRatio) // ScaleAspectFill
            let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
            
            let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
            
            let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
            let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
            context?.draw(image.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            return pixelBuffer
        }
        
        init(renderSettings: RenderSettings) {
            self.renderSettings = renderSettings
        }
        
        func start() {
            
            let avOutputSettings: [String: AnyObject] = [
                AVVideoCodecKey: renderSettings.avCodecKey as AnyObject,
                AVVideoWidthKey: NSNumber(value: Float(renderSettings.width)),
                AVVideoHeightKey: NSNumber(value: Float(renderSettings.height))
            ]
            
            func createPixelBufferAdaptor() {
                let sourcePixelBufferAttributesDictionary = [
                    kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                    kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.width)),
                    kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.height))
                ]
                pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
            }
            
            func createAssetWriter(outputURL: NSURL) -> AVAssetWriter {
                guard let assetWriter = try? AVAssetWriter(outputURL: outputURL as URL, fileType: AVFileTypeMPEG4) else {
                    fatalError("AVAssetWriter() failed")
                }
                
                guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaTypeVideo) else {
                    fatalError("canApplyOutputSettings() failed")
                }
                
                return assetWriter
            }
            
            videoWriter = createAssetWriter(outputURL: renderSettings.outputURL)
            videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: avOutputSettings)
            
            if videoWriter.canAdd(videoWriterInput) {
                videoWriter.add(videoWriterInput)
            }
            else {
                fatalError("canAddInput() returned false")
            }
            
            // The pixel buffer adaptor must be created before we start writing.
            createPixelBufferAdaptor()
            
            if videoWriter.startWriting() == false {
                fatalError("startWriting() failed")
            }
            
            videoWriter.startSession(atSourceTime: kCMTimeZero)
            
            precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
        }
        
        func render(appendPixelBuffers: @escaping (VideoWriter)->Bool, completion: @escaping ()->Void) {
            
            precondition(videoWriter != nil, "Call start() to initialze the writer")
            
            let queue = DispatchQueue(label: "mediaInputQueue")
            videoWriterInput.requestMediaDataWhenReady(on: queue) {
                let isFinished = appendPixelBuffers(self)
                if isFinished {
                    self.videoWriterInput.markAsFinished()
                    self.videoWriter.finishWriting() {
                        DispatchQueue.main.async() {
                            completion()
                        }
                    }
                }
                else {
                    // Fall through. The closure will be called again when the writer is ready.
                }
            }
        }
        
        func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
            
            precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
            
            let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size)
            return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }
        
    }
    
    
    
    
    

    
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}
