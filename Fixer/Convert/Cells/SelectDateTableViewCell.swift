//
//  SelectDateTableViewCell.swift
//  Fixer
//
//  Created by Mat Gadd on 09/01/2018.
//  Copyright © 2018 Mat Gadd. All rights reserved.
//

import UIKit

protocol SelectDateTableViewCellDelegate: class {

    func selectDateCell(_ cell: SelectDateTableViewCell, didSelectDate date: Date)

}

class SelectDateTableViewCell: UITableViewCell {

    @IBOutlet var datePicker: UIDatePicker!

    var delegate: SelectDateTableViewCellDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
    }

    @IBAction func datePickerChanged(_ sender: Any) {
        guard let date = (sender as? UIDatePicker)?.date else {
            return
        }

        delegate?.selectDateCell(self, didSelectDate: date)
    }

}
