



import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imagesId: [Int] = []
    
    var redactor = ImagesRedactor()
    var fileManager = FileManagerForImages()
    
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
        imagesId.insert(indexForNewImage, at: 0)
        if imagesId.count != 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        redactor.rotateImage(image: image, imageNumber: indexForNewImage, progress: { (value,progress,duration)  -> Void in
            self.setProgressToCell(fotValue: value, progress: progress, duration: duration)
        }) { (value) in
            self.reloadCell(forValue: value)
        }
    }
    
    @IBAction func actionButtonInvert(_ sender: UIButton) {
        guard let image = self.imageView.image else { return }
        var indexForNewImage = 0
        if let first = self.imagesId.first {
            indexForNewImage = first + 1
        }
        self.imagesId.insert(indexForNewImage, at: 0)
        if imagesId.count != 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        redactor.invertColorImage(image: image, imageNumber: indexForNewImage, progress: { (value,progress,duration)  -> Void in
            self.setProgressToCell(fotValue: value, progress: progress, duration: duration)
        }) { (value) in
            self.reloadCell(forValue: value)
        }
    }
    
    @IBAction func actionButtonMirror(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        var indexForNewImage = 0
        if let first = self.imagesId.first {
            indexForNewImage = first + 1
        }
        self.imagesId.insert(indexForNewImage, at: 0)
        if imagesId.count != 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        redactor.mirrorImage(image: image, imageNumber: indexForNewImage, progress: { (value,progress,duration)  -> Void in
            self.setProgressToCell(fotValue: value, progress: progress, duration: duration)
        }) { (value) in
            self.reloadCell(forValue: value)
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
    
    func setProgressToCell(fotValue value: Int, progress: Int, duration: Int ) -> Void {
        guard let index = self.imagesId.index(where: { (currentValue) -> Bool in
            currentValue == value
        }) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = self.tableView.cellForRow(at: indexPath) as? CellWithIndicator else { return }
        cell.configureCell(value: Float(progress)/Float(duration))
    }
    
    func reloadCell(forValue value: Int) -> Void {
        guard let index = self.imagesId.index(where: { (currentValue) -> Bool in
            currentValue == value
        }) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let image = fileManager.getImage(withIndex: imagesId[indexPath.row]) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellResult") as! CellWithImage
            cell.imageView?.image = image
        } 
    }
}

