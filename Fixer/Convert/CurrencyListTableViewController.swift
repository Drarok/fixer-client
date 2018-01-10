//
//  CurrencyListTableViewController.swift
//  Fixer
//
//  Created by Mat Gadd on 09/01/2018.
//  Copyright © 2018 Mat Gadd. All rights reserved.
//

import UIKit

protocol CurrencyListTableViewControllerDelegate {
    func didSelectCurrency(currency: Currency)
}

class CurrencyListTableViewController: UITableViewController {

    struct Key {
        static let currencyCellIdentifier = "currencyCell"
    }

    var delegate: CurrencyListTableViewControllerDelegate?
    var currency: Currency?
    var currencies: [Currency] = Currency.all

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let index = Currency.all.index { $0.id == currency?.id ?? "" }

        if let index = index {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        }
    }

}

private typealias TableViewDataSource = CurrencyListTableViewController
extension TableViewDataSource {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Key.currencyCellIdentifier, for: indexPath)

        let currency = currencies[indexPath.row]
        cell.textLabel?.text = currency.name
        cell.detailTextLabel?.text = "\(currency.flag) \(currency.id)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCurrency(currency: currencies[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}
