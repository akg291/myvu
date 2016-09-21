//
//  PlaybackSourceCell.swift
//  HelloWorld
//
//  Created by MacPro on 25/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

class PlaybackSourceCell: UICollectionViewCell {
    
    // MARK: Variables
    static let reuseIdentifier = "PlaybackSourceCell"
    var representedDataItem: Result?
    
    //MARK: - Outlets
    @IBOutlet weak var title: UIButton!
    
    // MARK: - Initialization
    override func awakeFromNib()    {
        super.awakeFromNib()
    }
    
    // MARK: - UICollectionReusableView
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - UIFocusEnvironment
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    }
}
