//
//  ImageURLSession.swift
//  Images
//
//  Created by Admin on 27.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ImageURLSession: URLSession, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var progressUpdateClosureHandler: ((String) -> Void)?
    var downloadCompleteClosureHandler: ((UIImage?) -> Void)?
    
    // методы для работы с загрузкой изображений из интернета
    func loadImage(url: URL) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            guard let image = UIImage(data: data)  else { return }
            DispatchQueue.main.async {
                guard let closure =  self.downloadCompleteClosureHandler else { return }
                closure(image)
            }
        } catch {
            DispatchQueue.main.async {
                guard let closure =  self.downloadCompleteClosureHandler else { return }
                closure(nil)
             
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            guard let closure =  self.progressUpdateClosureHandler else { return }
            closure(String(Int(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite) * 100))+"%")
        }
    }
}
