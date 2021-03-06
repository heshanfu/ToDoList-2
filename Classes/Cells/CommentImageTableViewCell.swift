//
//  CommentImageTableViewCell.swift
//  ToDoList
//
//  Created by Radu Ursache on 14/01/2020.
//  Copyright © 2020 Radu Ursache. All rights reserved.
//

import UIKit
import ImageViewer_swift

class CommentImageTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var commentImageView: ImageViewerExt!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func getIdentifier() -> String {
        return "commentImageCell"
    }
}
