//
//  ItemHeaderCellTableViewCell.swift
//  MyVu
//
//  Created by MacPro on 05/01/2017.
//  Copyright © 2017 Aplos Inovations. All rights reserved.
//

import UIKit

class ItemHeaderCellTableViewCell: UITableViewCell {
	
	@IBOutlet weak var labelTitle : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

	func configureCell(){
		
		labelTitle.text = "MAMUU"
		
	}

}
