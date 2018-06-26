//
//  ImagesRedactor.swift
//  Images
//
//  Created by Admin on 26.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ImagesRedactor {
    
    private var fileManager = FileManagerForImages()
    
    func rotateImage(image: UIImage, imageNumber: Int, progress: @escaping (Int,Int,Int) -> Void,complete: @escaping (Int) -> Void) {
        let queue = DispatchQueue(label: "\(imageNumber + 2)")
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
            self.prepareTimer(valueForImage: imageNumber, image: UIImage(cgImage: cgImage), progress: progress, complete: complete)
        }
    }
    
    func invertColorImage(image: UIImage, imageNumber: Int, progress: @escaping (Int,Int,Int) -> Void,complete: @escaping (Int) -> Void) {
        let queue = DispatchQueue(label: "\(imageNumber + 2)")
        queue.async {
            let orientation = self.getImageOrientation(value: image.imageOrientation)
            let ciImage = CIImage(cgImage: (image.cgImage)!)
            let reorientedCIImage = ciImage.oriented(forExifOrientation: orientation)
            let filter = CIFilter(name: "CIPhotoEffectMono")
            filter?.setValue(reorientedCIImage, forKey: kCIInputImageKey)
            guard let outputImage = filter?.outputImage else { return }
            
            let contex = CIContext(options: [kCIContextUseSoftwareRenderer:true])
            guard let cgImage = contex.createCGImage(outputImage, from: outputImage.extent) else { return }
            self.prepareTimer(valueForImage: imageNumber, image: UIImage(cgImage: cgImage), progress: progress, complete: complete)
        }
    }
    
    func mirrorImage(image: UIImage, imageNumber: Int, progress: @escaping (Int,Int,Int) -> Void,complete: @escaping (Int) -> Void) {
        let queue = DispatchQueue(label: "\(imageNumber + 2)")
        queue.async {
            let orientation = self.getImageOrientation(value: image.imageOrientation)
            let ciImage = CIImage(cgImage: (image.cgImage)!)
            let reorientedCIImage = ciImage.oriented(forExifOrientation: orientation)
            let contex = CIContext(options: [kCIContextUseSoftwareRenderer:true])
            guard let cgImage = contex.createCGImage(reorientedCIImage, from: reorientedCIImage.extent) else { return }
            let newImage = UIImage(cgImage: cgImage, scale: 0, orientation: UIImageOrientation.upMirrored)
            self.prepareTimer(valueForImage: imageNumber, image: newImage, progress: progress, complete: complete)
        }
    }
    
    func getImageOrientation(value: UIImageOrientation) -> Int32
    {
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
    func prepareTimer(valueForImage: Int, image: UIImage,  progress: @escaping (Int,Int,Int) -> Void,complete: @escaping (Int) -> Void) {
        let duration:Int = Int(arc4random_uniform(UInt32(25)) + 1) + 5
        
        var userInfo: [String:Any] = [:]
        userInfo["duration"] = duration
        userInfo["image"] = image
        userInfo["value"] = valueForImage
       
        userInfo["position"] = 0
        userInfo["progress"] = progress
        userInfo["complete"] = complete
        
        DispatchQueue.main.async {
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startTimer(sender:)), userInfo: userInfo, repeats: false)
        }
        
    }
    
    @objc fileprivate func startTimer(sender timer: Timer) {
        guard var userInfo = timer.userInfo as? [String:Any] else { return }
        let duration = userInfo["duration"] as! Int
        let valueImage = userInfo["value"] as! Int
        
        var currentPosition = userInfo["position"] as! Int
        let complete = userInfo["complete"] as! (Int) -> Void
        let progress = userInfo["progress"] as! (Int,Int,Int) -> Void
        
        
        
        
        if currentPosition == duration {
            timer.invalidate()
            let image = userInfo["image"] as! UIImage
            self.fileManager.saveImage(withIndex: valueImage, image: image)
            complete(valueImage)
            //tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            currentPosition += 1
            progress(valueImage, currentPosition, duration)
            //cell.configureCell(value: Float(currentPosition)/Float(duration))
            userInfo["position"] = currentPosition
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startTimer(sender:)), userInfo: userInfo, repeats: false)
        }
    }
}
