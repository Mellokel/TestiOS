//
//  SaveImage.swift
//  Images
//
//  Created by Admin on 23.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class FileManagerForImages {
    func saveImage(withIndex index: Int, image: UIImage ) {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("image\(index).jpg")
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }

    func deleteImage(withIndex index: Int) {
        let fileManager = FileManager.default
        do {
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("image\(index).jpg")
            try fileManager.removeItem(atPath: paths)
        } catch { return }
    }
    func getImage(withIndex index: Int) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("image\(index).jpg")
        guard fileManager.fileExists(atPath: imagePath) else { return nil }
        return UIImage(contentsOfFile: imagePath)
    }
    func loadImagesFromAlbum() -> [Int]{
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        var theItems = [String]()
        guard let dirPath = paths.first else { return [] }
        let imageURL = URL(fileURLWithPath: dirPath)
        do {
            theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
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


    func getMatches(in path: String) -> [Int] {
        do {
            let regex = try NSRegularExpression(pattern: "[0-9]")
            let results = regex.matches(in: path, range: NSRange(path.startIndex..., in: path))
            return results.map {
                Int(path[Range($0.range, in: path)!])!
            }
        } catch { return [] }
    }

    func removeAllImages() {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        var theItems = [String]()
        guard let dirPath = paths.first else { return }
        let imageURL = URL(fileURLWithPath: dirPath)
        do {
            theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
            theItems.forEach({ (path) in
                deleteImage(withName: path)
            })
        } catch { }
    }
    func deleteImage(withName name: String) {
        let fileManager = FileManager.default
        do {
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
            try fileManager.removeItem(atPath: paths)
        } catch { return }
    }
}
