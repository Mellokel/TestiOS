



import UIKit

class ImageEditorVC: UIViewController {
    
    private var imagesId: [Int] = []
    
    private var imageEditor = ImageEditor()
    private var fileManager = FileManagerForImages()
    private let imageProvider = ImageProvider()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lableProgressPercent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ids = fileManager.getAllSavedImages()
        ids.forEach { (value) in
            imagesId.insert(value, at: 0)
        }
        
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
        tableView.reloadData()
    }
    //MARK: - Button Action
    @IBAction func actionButtonRotate(_ sender: UIButton) {
        preparationForEditing { (image, index) in
            imageEditor.rotateImage(image: image, imageNumber: index, progress: { (value,progress)  -> Void in
                self.setProgressToCell(forValue: value, progress: progress)
            }) { (value) in
                self.reloadCell(forValue: value)
            }
        }
    }
    
    @IBAction func actionButtonInvert(_ sender: UIButton) {
        preparationForEditing { (image, index) in
            imageEditor.invertColorImage(image: image, imageNumber: index, progress: { (value,progress)  -> Void in
                self.setProgressToCell(forValue: value, progress: progress)
            }) { (value) in
                self.reloadCell(forValue: value)
            }
        }
    }
    
    @IBAction func actionButtonMirror(_ sender: UIButton) {
        preparationForEditing { (image, index) in
            imageEditor.mirrorImage(image: image, imageNumber: index, progress: { (value,progress)  -> Void in
                self.setProgressToCell(forValue: value, progress: progress)
            }) { (value) in
                self.reloadCell(forValue: value)
            }
        }
    }
    
    //MARK: - Main Image Action
    @objc private func showMenu(sender: Any) {
        let alert = UIAlertController(title: "", message: "Выберите способ загрузки изображения", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: { (_) in
            self.imageProvider.presentCamera(updateImage: { (image) in
                self.imageView.image = image
            })
            
        }))
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { (_) in
            self.imageProvider.presentLibrary(updateImage: { (image) in
                self.imageView.image = image
            })
            
        }))
        alert.addAction(UIAlertAction(title: "По ссылке", style: .default, handler: { (_) in
            self.lableProgressPercent.text = "0$"
            self.imageProvider.presentURLDialog(progress: { (percent) in
                self.lableProgressPercent.text = percent
            }, complete: { (loadedImage) in
                if let image = loadedImage {
                    self.imageView.image = image
                }
                self.lableProgressPercent.text = ""
            })
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - accessory methods
    private func preparationForEditing(closure: (UIImage,Int) -> Void) {
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
        closure(image, indexForNewImage)
    }
    
}
//MARK: - Table View
extension ImageEditorVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.scrollsToTop = true
        if let image = fileManager.getImage(withIndex: imagesId[indexPath.row]) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellResult") as! ImageEditorResultCell
            let info = CellResultPrimaryInfo(image: image)
            cell.configureCell(withPrimaryInfo: info)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellIndicator") as! ImageEditorProgressCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImageEditorResultCell else { return nil}
        let alert = UIAlertController(title: "", message: "Что сделать с изображением?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Использовать", style: .default, handler: { (_) in
            self.imageView.image = cell.getImage()
        }))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { (_) in
            guard let image = cell.imageView?.image else { return }
            self.imageProvider.saveImage(image: image)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellResult") as! ImageEditorResultCell
            let info = CellResultPrimaryInfo(image: image)
            cell.configureCell(withPrimaryInfo: info)
        } 
    }
    
    //MARK: - accessory methods for TableViewCell
    private func setProgressToCell(forValue value: Int, progress: Float) -> Void {
        guard let index = self.imagesId.index(where: { (currentValue) -> Bool in
            currentValue == value
        }) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        DispatchQueue.main.async {
            guard let cell = self.tableView.cellForRow(at: indexPath) as? ImageEditorProgressCell else { return }
            let info = CellProgressPrimaryInfo(progress: progress)
            cell.configureCell(withPrimaryInfo: info)
        }
    }
    
    private func reloadCell(forValue value: Int) -> Void {
        guard let index = self.imagesId.index(where: { (currentValue) -> Bool in
            currentValue == value
        }) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

