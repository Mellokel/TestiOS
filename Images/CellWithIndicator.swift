//
//  TableViewCell.swift
//  Images
//
//  Created by Admin on 23.06.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class CellWithIndicator: UITableViewCell {
    
    @IBOutlet private weak var progressView: UIProgressView!
    
    func configureCell(value: Float) {
        self.progressView.setProgress(value, animated: true)
    }
    
}
