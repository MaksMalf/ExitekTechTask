import UIKit

class MobileViewController: UIViewController {

    // MARK: - Properties

    var mobiles = [Mobile]()
    var filtredMobiles = [Mobile]()
    let dataService = MobileDataService()
    var isFiltering = Bool()

    private var mobileView: MobileView? {
        guard isViewLoaded else { return nil }
        return view as? MobileView
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = MobileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mobiles = Array(dataService.getAll())
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mobileView?.tableView.reloadData()
    }

    // MARK: - Private functions

    private func setupView() {
        title = "Mobile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Throw off",
            style: .plain,
            target: self,
            action: #selector(throwOffTapped))
        navigationController?.navigationBar.prefersLargeTitles = true

        mobileView?.tableView.delegate = self
        mobileView?.tableView.dataSource = self
        mobileView?.addModelTextField.delegate = self
        mobileView?.addEmeiTextField.delegate = self
        mobileView?.tableView.keyboardDismissMode = .onDrag
        mobileView?.addMobileButton.addTarget(
            self,
            action: #selector(addMobileButtonTapped),
            for: .touchUpInside)
    }
}


extension MobileViewController {
    @objc func addMobileButtonTapped() {
        guard let model = mobileView?.addModelTextField.text,
              !model.trimmingCharacters(in: .whitespaces).isEmpty,
              let imei = mobileView?.addEmeiTextField.text
        else {
            showAlert(title: "Error", message: "Enter data")
            return
        }
        let mobile = Mobile(imei: imei, model: model)
        if mobiles.contains(mobile) {
            showAlert(title: "Error", message: "Such a model already exists")
            mobileView?.addModelTextField.text = ""
            mobileView?.addModelTextField.resignFirstResponder()
            mobileView?.addEmeiTextField.text = ""
            mobileView?.addEmeiTextField.resignFirstResponder()
            return
        }
        mobiles.append(mobile)
        mobileView?.tableView.reloadData()

        do {
            try dataService.save(mobile)
        } catch {

        }

        mobileView?.addModelTextField.text = ""
        mobileView?.addModelTextField.resignFirstResponder()
        mobileView?.addEmeiTextField.text = ""
        mobileView?.addEmeiTextField.resignFirstResponder()
    }

    @objc func searchTapped() {
        let alert = UIAlertController(title: "Enter IMEI", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Search", style: .default) { [weak self] _ in
            let text = alert.textFields?.first?.text
            if text == "" {
                self?.showAlert(title: "Error",
                                message: "Enter IMEI")
            }

            self?.isFiltering = true
            self?.filtredMobiles = self?.mobiles.filter({ $0.imei == text }) ?? []
            if self?.filtredMobiles.count == 0 {
                self?.showAlert(title: "Error",
                                message: "According to the specified IMEI, the mobile was not found")
                return
            }
            self?.mobileView?.tableView.reloadData()
        }

        alert.addAction(action)
        alert.addTextField()
        navigationController?.present(alert, animated: true)
    }

    @objc func throwOffTapped() {
        self.isFiltering.toggle()
        self.mobileView?.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension MobileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredMobiles.count
        }

        return mobiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var content = cell.defaultContentConfiguration()

        if isFiltering {
            let mobile = filtredMobiles[indexPath.row]
            content.text = mobile.model
            content.secondaryText = mobile.imei
            cell.contentConfiguration = content

        } else {
            let mobile = mobiles[indexPath.row]
            content.text = mobile.model
            content.secondaryText = mobile.imei

            cell.contentConfiguration = content
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension MobileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let mobile = mobiles[indexPath.row]
        if editingStyle == .delete {
            tableView.beginUpdates()

            do {
                mobiles.remove(at: indexPath.row)
                try dataService.delete(mobile)
            } catch {
                return
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}

// MARK: - UITextFieldDelegate

extension MobileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addMobileButtonTapped()
        textField.resignFirstResponder()
        return true
    }
}
