//
//  CurrencyConversionTableViewController.swift
//  Fixer
//
//  Created by Mat Gadd on 09/01/2018.
//  Copyright © 2018 Mat Gadd. All rights reserved.
//

import UIKit

import MRProgress

class CurrencyConversionTableViewController: UITableViewController {

    struct Key {
        static let currencyCellIdentifier = "currencyCellIdentifier"
        static let currentDateCellIdentifier = "currentDateCellIdentifier"
        static let selectDateCellIdentifier = "selectDateCellIdentifier"
        static let showCurrencySegueIdentifier = "showCurrencySegueIdentifier"
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()


    var currencies = [Currency.all[9], Currency.all[30]]
    var currencyAmount = 0.0 // Always stored in the base currency (EUR)
    var currentCurrencyIndex = -1
    var currentSections = 2
    var currentDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use autolayout cells
        tableView.estimatedRowHeight = 56.0
        tableView.rowHeight = UITableViewAutomaticDimension

        // Hide separators for non-existent cells
        tableView.tableFooterView = UIView()

        tableView.keyboardDismissMode = .interactive
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Currency.rates.count == 0 {
            fetchRates()
        }

        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CurrencyListTableViewController {
            destination.delegate = self
        }
    }

    // Update the *other* input cell, not the one the user is using
    private func updateInputCells(senderIndex index: Int) {
        let otherIndex = index == 0 ? 1 : 0
        let otherRow = IndexPath(row: otherIndex, section: 0)
        tableView.reloadRows(at: [otherRow], with: .none)
    }

    private func fetchRates(showUpdates: Bool = true) {
        let apiDateFormatter = DateFormatter()
        apiDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        apiDateFormatter.dateFormat = "yyyy'-'MM'-'dd"

        let formattedDate = apiDateFormatter.string(from: currentDate)
        guard let url = URL(string: "https://api.fixer.io/\(formattedDate)") else {
            print("Failed to create URL from \(formattedDate)")
            return
        }

        let v = navigationController?.view.window ?? view
        var overlay: MRProgressOverlayView? = nil
        if showUpdates {
            overlay = MRProgressOverlayView.showOverlayAdded(to: v, title: "Loading…", mode: .indeterminate, animated: true)
        }

        func dismiss(_ message: String, success: Bool, error: Error? = nil) {
            if !success {
                print("Dismissing overlay due to error \(error?.localizedDescription ?? "<unknown>") with message \(message)")
            }

            DispatchQueue.main.async {
                overlay?.mode = success ? .checkmark : .cross
                overlay?.titleLabelText = message

                if success {
                    let indexSet = IndexSet([0, 1])
                    self.tableView.reloadSections(indexSet, with: .fade)

                    if self.currentSections == 3, let pickerCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SelectDateTableViewCell {
                        if pickerCell.datePicker.date != self.currentDate {
                            pickerCell.datePicker.setDate(self.currentDate, animated: true)
                        }
                    }
                }
            }

            let delay = success ? 0.5 : 1.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                overlay?.dismiss(true)
            })
        }

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                dismiss(error.localizedDescription, success: false, error: error)
                return
            }

            guard let data = data else {
                dismiss("No data", success: false, error: error)
                return
            }

            let jsonObject: Any
            do {
                jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            } catch let e {
                dismiss("Parse failure", success: false, error: e)
                return
            }

            guard let json = jsonObject as? [String : Any] else {
                dismiss("Unexpected response", success: false)
                return
            }

            guard let rates = json["rates"] as? [String : Double] else {
                dismiss("No rates", success: false)
                return
            }

            Currency.rates = rates

            if let dateString = json["date"] as? String, let date = apiDateFormatter.date(from: dateString) {
                self.currentDate = date
            }

            dismiss("", success: true)
        })
        task.resume()
    }

}

private typealias TableViewDataSource = CurrencyConversionTableViewController
extension TableViewDataSource {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? currencies.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        switch indexPath.section {
            case 0:
                identifier = Key.currencyCellIdentifier
            case 1:
                identifier = Key.currentDateCellIdentifier
            case 2:
                identifier = Key.selectDateCellIdentifier
            default:
                identifier = ""
        }

        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cls = String(describing: type(of: cell))
        print("tableView: willDisplay:\(cls) forRowAt:\(indexPath)")

        if let cell = cell as? CurrencyTableViewCell {
            cell.delegate = self
            cell.indexPath = indexPath
        } else if let cell = cell as? SelectDateTableViewCell {
            cell.delegate = self
            cell.datePicker.date = currentDate
        } else {
            if indexPath.section == 1 {
                cell.textLabel?.text = nil
                cell.detailTextLabel?.text = dateFormatter.string(from: currentDate)
            }
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // Block selection of anything except the "current date" section
        if indexPath.section != 1 {
            return nil
        }

        // Deselect the row immediately with animation, and toggle the section.
        DispatchQueue.main.async {
            let indexSet = IndexSet(integer: 2)

            tableView.deselectRow(at: indexPath, animated: true)

            if self.currentSections == 2 {
                self.currentSections = 3
                tableView.insertSections(indexSet, with: .top)
            } else {
                self.currentSections = 2
                tableView.deleteSections(indexSet, with: .top)
            }
        }

        return indexPath
    }

}

private typealias CurrencyCellDelegate = CurrencyConversionTableViewController
extension CurrencyCellDelegate: CurrencyTableViewCellDelegate {

    func currencyCell(_ cell: CurrencyTableViewCell, amountForRowAt indexPath: IndexPath) -> Double {
        let toCurrency = currencies[indexPath.row]
        return Currency.convert(currencyAmount, from: Currency.base, to: toCurrency)
    }

    func currencyCell(_ cell: CurrencyTableViewCell, currencyForRowAt indexPath: IndexPath) -> Currency? {
        return currencies[indexPath.row]
    }

    func currencyCell(_ cell: CurrencyTableViewCell, selectCurrencyForRowAt indexPath: IndexPath) {
        currentCurrencyIndex = indexPath.row
        performSegue(withIdentifier: Key.showCurrencySegueIdentifier, sender: cell)
    }

    func currencyCell(_ cell: CurrencyTableViewCell, amountDidChangeTo amount: Double, forRowAt indexPath: IndexPath) {
        let fromCurrency = currencies[indexPath.row]
        currencyAmount = Currency.convert(amount, from: fromCurrency, to: Currency.base)
        updateInputCells(senderIndex: indexPath.row)
    }

}

private typealias SelectDateCellDelegate = CurrencyConversionTableViewController
extension SelectDateCellDelegate: SelectDateTableViewCellDelegate {

    func selectDateCell(_ cell: SelectDateTableViewCell, didSelectDate date: Date) {
        currentDate = date
        fetchRates(showUpdates: false)
    }

}

private typealias CurrencyListDelegate = CurrencyConversionTableViewController
extension CurrencyListDelegate: CurrencyListTableViewControllerDelegate {

    func didSelectCurrency(currency: Currency) {
        currencies[currentCurrencyIndex] = currency
        updateInputCells(senderIndex: currentCurrencyIndex)
    }

}
