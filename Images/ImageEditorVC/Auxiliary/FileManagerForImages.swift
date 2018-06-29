//
//  SaveImage.swift
//  Images
//
//  Created by Admin on 23.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class FileManagerForImages {
    private let fileManager = FileManager.default
   
    //MARK: - main methods
    func saveImage(withIndex index: Int, image: UIImage ) {
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: getPath(index: index), contents: imageData, attributes: nil)
    }
    
    func getImage(withIndex index: Int) -> UIImage? {
        guard fileManager.fileExists(atPath: getPath(index: index)) else { return nil }
        return UIImage(contentsOfFile: getPath(index: index))
    }
    
    func getAllSavedImages() -> [Int]{
        var theItems: [String] = []
        let imageURL = URL(fileURLWithPath: String(getDirectory()))
        do {
            theItems = try fileManager.contentsOfDirectory(atPath: imageURL.path)
            var result: [Int] = []
            theItems.forEach({ (path) in
                let matches = getMatches(in: path)
                matches.forEach({ (value) in
                    result.append(value)
                })
            })
            return result
        } catch { return [] }
    }
    
    func removeAllImages() {
        var theItems: [String] = []
        let imageURL = URL(fileURLWithPath: String(getDirectory()))
        do {
            theItems = try fileManager.contentsOfDirectory(atPath: imageURL.path)
            theItems.forEach({ (path) in
                deleteImage(withName: path)
            })
        } catch { }
    }
    
    func deleteImage(withIndex index: Int) {
        do {
            try fileManager.removeItem(atPath: getPath(index: index))
        } catch { return }
    }
    
    func deleteImage(withName name: String) {
        do {
            try fileManager.removeItem(atPath: getPath(name: name))
        } catch { return }
    }
    
    
    //MARK: - accessory methods
    private func getPath(index: Int) -> String{
        return String(getDirectory().appendingPathComponent("image\(index).jpg"))
    }
    
    private func getPath(name: String) -> String {
        return String(getDirectory().appendingPathComponent(name))
    }
    
    private func getDirectory() -> NSString{
        return NSString(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
    }

    // для получения всех номеров изображений
    private func getMatches(in path: String) -> [Int] {
        do {
            let regex = try NSRegularExpression(pattern: "[0-9]")
            let results = regex.matches(in: path, range: NSRange(path.startIndex..., in: path))
            return results.map {
                Int(path[Range($0.range, in: path)!])!
            }
        } catch { return [] }
    }

}
