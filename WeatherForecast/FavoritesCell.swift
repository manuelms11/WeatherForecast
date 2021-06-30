//
//  FavoritesCell.swift
//  WeatherForecast
//
//  Created by user198829 on 6/29/21.
//

import UIKit

class FavoritesCell: UITableViewCell {
    
    @IBOutlet weak var cellLocationLabel: UILabel?
    @IBOutlet weak var cellIconImageView: UIImageView!
    @IBOutlet weak var cellDescriptionLabel: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  /*  override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }*/

}
