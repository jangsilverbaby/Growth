//
//  FrontCell.swift
//  Growth
//
//  Created by eunae on 2021/09/09.
//

import UIKit

class FrontCell: UICollectionViewCell {
    @IBOutlet weak var frontImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var cornerRadius: CGFloat = 5.0
    
    override func awakeFromNib() {
            super.awakeFromNib()
                
            // Apply rounded corners to contentView
            contentView.layer.cornerRadius = cornerRadius
            contentView.layer.masksToBounds = true
            
            // Set masks to bounds to false to avoid the shadow
            // from being clipped to the corner radius
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = false
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        appDelegate.index = self.editBtn.tag
    }
}
