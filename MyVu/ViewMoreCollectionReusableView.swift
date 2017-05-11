//
//  ViewMoreCollectionReusableView.swift
//  MyVu
//
//  Created by MacPro on 27/10/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

protocol CollectionCellReusableViewDelegate {
    func collectionCellReusableViewDelegate()
}

class ViewMoreCollectionReusableView: UICollectionReusableView {
    
    private var _delegate:CollectionCellReusableViewDelegate?
	
    var delegate:CollectionCellReusableViewDelegate {
		
		get{
			return _delegate!
		}
		
        set{
            if( _delegate == nil ){
                _delegate = newValue
            }
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var btnViewMore: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override var preferredFocusedView: UIView? {
        return btnViewMore
    }
    
    @IBAction func actionViewMore(){
        _delegate?.collectionCellReusableViewDelegate()
    }
    
}
