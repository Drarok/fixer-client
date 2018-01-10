//
//  CurrencyTableViewCell.swift
//  Fixer
//
//  Created by Mat Gadd on 09/01/2018.
//  Copyright © 2018 Mat Gadd. All rights reserved.
//

import UIKit

protocol CurrencyTableViewCellDelegate: class {

    func currencyCell(_ cell: CurrencyTableViewCell, amountForRowAt indexPath: IndexPath) -> Double
    func currencyCell(_ cell: CurrencyTableViewCell, currencyForRowAt indexPath: IndexPath) -> Currency?
    func currencyCell(_ cell: CurrencyTableViewCell, selectCurrencyForRowAt indexPath: IndexPath)
    func currencyCell(_ cell: CurrencyTableViewCell, amountDidChangeTo amount: Double, forRowAt indexPath: IndexPath)

}

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var currencyButton: UIButton!

    var indexPath: IndexPath? = nil {
        didSet {
            format()
        }
    }

    weak var delegate: CurrencyTableViewCellDelegate? = nil {
        didSet {
            format()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        indexPath = nil
        delegate = nil
    }

    @IBAction func editingDidBegin(_ sender: Any) {
        guard let field = sender as? UITextField else {
            return
        }

        guard let indexPath = indexPath else {
            return
        }

        guard let amount = delegate?.currencyCell(self, amountForRowAt: indexPath) else {
            return
        }

        if amount <= 0.0 {
            field.text = nil
        } else {
            field.text = String(format: "%.2f", amount)
        }

        field.selectAll(nil)
    }

    @IBAction func editingChanged(_ sender: Any) {
        guard let field = sender as? UITextField, let text = field.text else {
            return
        }

        guard let indexPath = indexPath else {
            return
        }

        let amount = Double(text) ?? 0.0
        delegate?.currencyCell(self, amountDidChangeTo: amount, forRowAt: indexPath)
    }

    @IBAction func editingDidEnd(_ sender: Any) {
        format()
    }

    @IBAction func selectCurrency(_ sender: Any) {
        guard let indexPath = indexPath else {
            return
        }

        delegate?.currencyCell(self, selectCurrencyForRowAt: indexPath)
    }

    private func format() {
        guard let indexPath = indexPath, let currency = delegate?.currencyCell(self, currencyForRowAt: indexPath) else {
            textField.text = nil
            textField.placeholder = nil
            currencyButton.setTitle(nil, for: .normal)
            return
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = currency.locale

        currencyButton.setTitle("\(currency.flag) \(currency.id)", for: .normal)
        textField.placeholder = formatter.string(from: NSNumber(value: 0.0))

        let amount = delegate?.currencyCell(self, amountForRowAt: indexPath) ?? 0.0

        if amount <= 0.0 {
            textField.text = nil
        } else {
            textField.text = formatter.string(from: NSNumber(value: amount)) ?? ""
        }
    }

}
