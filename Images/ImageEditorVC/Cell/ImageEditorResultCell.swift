//
//  CellWithImage.swift
//  Images
//
//  Created by Admin on 23.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ImageEditorResultCell: UITableViewCell {
    @IBOutlet private weak var resultImageView: UIImageView!
    
    func configureCell(withPrimaryInfo info: CellResultPrimaryInfo) {
        guard let image = info.image else { return }
        resultImageView.image = image
    }
    
    func getImage() -> UIImage? {
        return resultImageView.image
    }
}
