//
//  NewTableCell.swift
//  HelloWorld
//
//  Created by MacPro on 09/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation
import UIKit

class NewTableCell: UITableViewCell {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
}

extension NewTableCell {
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
}
