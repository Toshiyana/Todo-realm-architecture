//
//  TaskCell.swift
//  Todo-UIKit
//
//  Created by Toshiyana on 2022/06/02.
//

import UIKit
import SwipeCellKit

class TaskCell: UITableViewCell {
    static let identifier = "TaskCell"

    static func nib() -> UINib {
        UINib(nibName: "TaskCell", bundle: nil)
    }

    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }

    func configure(titleText: String) {
        titleLabel.text = titleText
    }
}
