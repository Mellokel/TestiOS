



import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imagesId: [Int] = []
    private var fileManager = FileManagerForImages()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ids = fileManager.loadImagesFromAlbum()
        //fileManager.removeAllImages()
        ids.forEach { (value) in
            imagesId.insert(value, at: 0)
        }
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
        tableView.reloadData()
    }
    
    
    @IBAction func actionButtonRotate(_ sender: UIButton) {
        guard let image = self.imageView.image else { return }
        var indexForNewImage = 0
        if let first = self.imagesId.first {
            indexForNewImage = first + 1
        }
        fileManager.deleteImage(withIndex: indexForNewImage)
        
        let queue = DispatchQueue(label: "\(indexForNewImage + 2)")
        imagesId.insert(indexForNewImage, at: 0)
        if imagesId.count != 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
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
            self.prepareTimer(valueForImage: indexForNewImage, image: UIImage(cgImage: cgImage))
        }
        
    }
    
    @IBAction func actionButtonInvert(_ sender: UIButton) {
        guard let image = self.imageView.image else { return }
        var indexForNewImage = 0
        if let first = self.imagesId.first {
            indexForNewImage = first + 1
        }
        fileManager.deleteImage(withIndex: indexForNewImage) //не обязательно, но мало ли
        
        let queue = DispatchQueue(label: "\(indexForNewImage + 2)")
        self.imagesId.insert(indexForNewImage, at: 0)
        if imagesId.count != 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        queue.async {
            let orientation = self.getImageOrientation(value: image.imageOrientation)
            let ciImage = CIImage(cgImage: (image.cgImage)!)
            let reorientedCIImage = ciImage.oriented(forExifOrientation: orientation)
            let filter = CIFilter(name: "CIPhotoEffectMono")
            filter?.setValue(reorientedCIImage, forKey: kCIInputImageKey)
            guard let outputImage = filter?.outputImage else { return }
            
            let contex = CIContext(options: [kCIContextUseSoftwareRenderer:true])
            guard let cgImage = contex.createCGImage(outputImage, from: outputImage.extent) else { return }
            self.prepareTimer(valueForImage: indexForNewImage, image: UIImage(cgImage: cgImage))
        }
        
    }
    
    @IBAction func actionButtonMirror(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        var indexForNewImage = 0
        if let first = self.imagesId.first {
            indexForNewImage = first + 1
        }
        fileManager.deleteImage(withIndex: indexForNewImage)
        
        let queue = DispatchQueue(label: "\(indexForNewImage + 2)")
        self.imagesId.insert(indexForNewImage, at: 0)
        if imagesId.count != 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        queue.async {
            let orientation = self.getImageOrientation(value: image.imageOrientation)
            let ciImage = CIImage(cgImage: (image.cgImage)!)
            let reorientedCIImage = ciImage.oriented(forExifOrientation: orientation)
            let contex = CIContext(options: [kCIContextUseSoftwareRenderer:true])
            guard let cgImage = contex.createCGImage(reorientedCIImage, from: reorientedCIImage.extent) else { return }
            let newImage = UIImage(cgImage: cgImage, scale: 0, orientation: UIImageOrientation.upMirrored)
            self.prepareTimer(valueForImage: indexForNewImage, image: newImage)
        }
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lableProgressPercent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Main Image
    @objc fileprivate func showMenu(sender: Any) {
        let alert = UIAlertController(title: "", message: "Выберите способ загрузки изображения", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "По ссылке", style: .default, handler: { (_) in
            let alertURL = UIAlertController(title: "", message: "Введите URL", preferredStyle: .alert)
            alertURL.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            alertURL.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
                let textField = alertURL.textFields?.first
                guard let text = textField?.text  else { return }
                guard let url = URL(string: text) else { return }
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                self.lableProgressPercent.text = "0$"
                let task = session.downloadTask(with: url)
                task.resume()
            }))
            alertURL.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "URL"
            })
            self.present(alertURL, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        dismiss(animated:true, completion: nil)
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
    func prepareTimer(valueForImage: Int, image: UIImage) {
        let duration:Float = Float(arc4random_uniform(UInt32(25)) + 1) + 5
        
        var userInfo: [String:Any] = [:]
        userInfo["duration"] = duration
        userInfo["image"] = image
        userInfo["value"] = valueForImage
        
        DispatchQueue.main.async {
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startTimer(sender:)), userInfo: userInfo, repeats: true)
        }
        
    }
    
    @objc fileprivate func startTimer(sender timer: Timer) {
        guard let userInfo = timer.userInfo as? [String:Any] else {
            timer.invalidate()
            return
        }
        let duration = userInfo["duration"] as! Float
        let valueImage = userInfo["value"] as! Int
        guard let index = self.imagesId.index(where: { (value) -> Bool in
            return value == valueImage
        }) else {
            timer.invalidate()
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = self.tableView.cellForRow(at: indexPath) as? CellWithIndicator else {
            timer.invalidate()
            return
        }
        if cell.progressView.progress == 1 {
            timer.invalidate()
            let image = userInfo["image"] as! UIImage
            self.fileManager.saveImage(withIndex: valueImage, image: image)
            cell.progressView.setProgress(0, animated: false)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            cell.progressView.setProgress(cell.progressView.progress+(1/duration), animated: true)
        }
        
    }
}

extension ViewController : URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            guard let image = UIImage(data: data)  else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                self.lableProgressPercent.text = ""
            }
        } catch {
            DispatchQueue.main.async {
                self.lableProgressPercent.text = ""
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.lableProgressPercent.text = String(Int(Double(totalBytesWritten)/Double(totalBytesExpectedToWrite) * 100))+"%"
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesId.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.scrollsToTop = true
        if let image = fileManager.getImage(withIndex: imagesId[indexPath.row]) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellResult") as! CellWithImage
            cell.imageView?.image = image
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIndicator") as! CellWithIndicator
            return cell
        }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.cellForRow(at: indexPath) as? CellWithImage else { return nil}
        let alert = UIAlertController(title: "", message: "Что сделать с изображением?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Использовать", style: .default, handler: { (_) in
            self.imageView.image = cell.imageView?.image
        }))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { (_) in
            guard let image = cell.imageView?.image else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            let alert = UIAlertController(title: "", message: "Изображение сохранено!", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { (_) in
            self.fileManager.deleteImage(withIndex: self.imagesId[indexPath.row])
            self.imagesId.remove(at: indexPath.row)
            tableView.deleteRows(at:[indexPath], with: .automatic)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return nil
    }
}

