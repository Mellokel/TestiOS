//
//  ImagesRedactor.swift
//  Images
//
//  Created by Admin on 26.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ImageEditor {
    
    private var fileManager = FileManagerForImages()
   
    func rotateImage(image: UIImage, imageNumber: Int, progress: @escaping (Int,Float) -> Void,complete: @escaping (Int) -> Void) {
        let queue = DispatchQueue(label: "\(imageNumber + 2)")
        let group = DispatchGroup()
        self.prepareTimer(valueForImage: imageNumber, progress: progress, group: group)
        queue.async {
            
            let orientation = self.getImageOrientation(value: image.imageOrientation)
            let ciImage = CIImage(cgImage: (image.cgImage)!)
            let reorientedCIImage = ciImage.oriented(forExifOrientation: orientation)
            let filter = CIFilter(name: "CIAffineTransform")
            filter?.setValue(reorientedCIImage, forKey: kCIInputImageKey)
            let transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
            filter?.setValue(NSValue(cgAffineTransform: transform), forKey: "inputTransform")
            guard let outputImage = filter?.outputImage else { return }
            
            let contex = CIContext(options: [kCIContextUseSoftwareRenderer:true])
            guard let cgImage = contex.createCGImage(outputImage, from: outputImage.extent) else { return }
            
            group.wait()
            self.fileManager.saveImage(withIndex: imageNumber, image: UIImage(cgImage: cgImage))
            complete(imageNumber)
        }
        
    }
    
    func invertColorImage(image: UIImage, imageNumber: Int, progress: @escaping (Int,Float) -> Void,complete: @escaping (Int) -> Void) {
        let queue = DispatchQueue(label: "\(imageNumber + 2)")
        let group = DispatchGroup()
        self.prepareTimer(valueForImage: imageNumber, progress: progress, group: group)
        queue.async {
            
            let orientation = self.getImageOrientation(value: image.imageOrientation)
            let ciImage = CIImage(cgImage: (image.cgImage)!)
            let reorientedCIImage = ciImage.oriented(forExifOrientation: orientation)
            let filter = CIFilter(name: "CIPhotoEffectMono")
            filter?.setValue(reorientedCIImage, forKey: kCIInputImageKey)
            guard let outputImage = filter?.outputImage else { return }
            
            let contex = CIContext(options: [kCIContextUseSoftwareRenderer:true])
            guard let cgImage = contex.createCGImage(outputImage, from: outputImage.extent) else { return }
            
            group.wait()
            self.fileManager.saveImage(withIndex: imageNumber, image: UIImage(cgImage: cgImage))
            complete(imageNumber)
        }
        
    }
    
    func mirrorImage(image: UIImage, imageNumber: Int, progress: @escaping (Int,Float) -> Void,complete: @escaping (Int) -> Void) {
        let queue = DispatchQueue(label: "\(imageNumber + 2)")
        let group = DispatchGroup()
        self.prepareTimer(valueForImage: imageNumber, progress: progress, group: group)
        queue.async {
            let orientation = self.getImageOrientation(value: image.imageOrientation)
            let ciImage = CIImage(cgImage: (image.cgImage)!)
            let reorientedCIImage = ciImage.oriented(forExifOrientation: orientation)
            let contex = CIContext(options: [kCIContextUseSoftwareRenderer:true])
            guard let cgImage = contex.createCGImage(reorientedCIImage, from: reorientedCIImage.extent) else { return }
            let newImage = UIImage(cgImage: cgImage, scale: 0, orientation: UIImageOrientation.upMirrored)
            
            group.wait()
            self.fileManager.saveImage(withIndex: imageNumber, image: newImage)
            complete(imageNumber)
        }
        
    }
    
    func getImageOrientation(value: UIImageOrientation) -> Int32 {
        switch (value)
        {
        case .up:
            return 1
        case .down:
            return 3
        case .left:
            return 8
        case .right:
            return 6
        case .upMirrored:
            return 2
        case .downMirrored:
            return 4
        case .leftMirrored:
            return 5
        case .rightMirrored:
            return 7
        }
    }
    
    
    //MARK: - Timer
    func prepareTimer(valueForImage: Int,  progress: @escaping (Int,Float) -> Void, group: DispatchGroup) {
        group.enter()
        
        let duration = Float(arc4random_uniform(UInt32(25)) + 1) + 5
        var currentPosition:Float = 0
        
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: 1)
        t.setEventHandler {
            if currentPosition == duration {
                group.leave()
                t.suspend()
            } else {
                currentPosition += 1
                progress(valueForImage, currentPosition/duration)
            }
        }
        t.resume()
    }
}
