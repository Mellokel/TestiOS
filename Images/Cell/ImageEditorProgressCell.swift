//
//  TableViewCell.swift
//  Images
//
//  Created by Admin on 23.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ImageEditorProgressCell: UITableViewCell {
    
    @IBOutlet private weak var progressView: UIProgressView!
    
    func configureCell(withPrimaryInfo info: CellProgressPrimaryInfo) {
        guard let value = info.progress else { return }
        progressView.setProgress(value, animated: true)
    }
    
}
