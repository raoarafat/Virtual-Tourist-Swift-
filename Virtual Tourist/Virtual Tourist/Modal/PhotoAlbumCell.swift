//
//  PhotoAlbumCell.swift
//  Virtual Tourist
//
//  Created by Arafat on 9/9/15.
//  Copyright (c) 2015 Arafat Khan. All rights reserved.
//

import UIKit

class PhotoAlbumCell: UICollectionViewCell {

    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var indicatorView: UIView!
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }

    
}
