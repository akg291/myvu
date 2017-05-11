//
//  ItemContainerCell.swift
//  MyVu
//
//  Created by MacPro on 02/01/2017.
//  Copyright © 2017 Aplos Inovations. All rights reserved.
//

import UIKit

class ItemContainerCell: UITableViewCell {
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	static let cellIdentifier = "ItemContainerCell"
	var nextUrl : String?
	
	override func awakeFromNib() {
		let flow : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		flow.minimumLineSpacing = 80
		flow.scrollDirection = .Horizontal
		self.collectionView.collectionViewLayout = flow
	}
	
}

extension ItemContainerCell {
	
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
