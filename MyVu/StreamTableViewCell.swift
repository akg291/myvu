//
//  StreamTableViewCell.swift
//  MyVu
//
//  Created by MacPro on 08/12/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import UIKit

class StreamTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnStreamTitle : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(red: 141/255, green: 172/255, blue: 204/255, alpha: 1)
        btnStreamTitle.backgroundColor = UIColor.clearColor()
        btnStreamTitle.titleLabel?.textColor = UIColor.blackColor()
    }

    func configureCell( title : String ) {
        btnStreamTitle.setTitle( title , forState: UIControlState.Normal)
    }
	
}
