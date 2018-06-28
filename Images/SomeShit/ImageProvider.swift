//
//  ImageProvider.swift
//  Images
//
//  Created by Admin on 26.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ImageProvider: UIImagePickerController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let imageURLSession = ImageURLSession()
    private var updateImageClosure: ((UIImage) -> Void)? = nil
    
    // Методы для получения изображений из камеры, галереи и интернета
    func presentCamera(updateImage: @escaping (UIImage) -> Void) {
        updateImageClosure = updateImage
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            UIApplication.shared.delegate?.window??.rootViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func presentLibrary(updateImage: @escaping (UIImage) -> Void) {
        updateImageClosure = updateImage
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            UIApplication.shared.delegate?.window??.rootViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func presentURLDialog(progress: @escaping (String) -> Void, complete: @escaping (UIImage?) -> Void ) {
        let alertURL = UIAlertController(title: "", message: "Введите URL", preferredStyle: .alert)
        alertURL.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alertURL.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
            let textField = alertURL.textFields?.first
            guard let text = textField?.text  else { return }
            guard let url = URL(string: text) else { return }
            self.imageURLSession.loadImage(url: url, progress: progress, comlete: complete)
        }))
        alertURL.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "URL"
        })
        UIApplication.shared.delegate?.window??.rootViewController?.present(alertURL, animated: true, completion: nil)
    }
    
    func saveImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        let alert = UIAlertController(title: "", message: "Изображение сохранено!", preferredStyle: .alert)
         UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true) {
            guard let closure = self.updateImageClosure else { return }
            closure(image)
        }
    }
}




















