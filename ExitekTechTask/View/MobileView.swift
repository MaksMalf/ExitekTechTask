import UIKit
import SnapKit

class MobileView: UIView {

    // MARK: - Views

    var addModelTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter mobile model"
        textField.textAlignment = .center
        textField.layer.cornerRadius = Metrics.cornerRadius
        textField.clearsOnBeginEditing = true
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .systemGray5
        return textField
    }()

    var addEmeiTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter mobile EMEI"
        textField.textAlignment = .center
        textField.layer.cornerRadius = Metrics.cornerRadius
        textField.clearsOnBeginEditing = true
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .systemGray5
        return textField
    }()

    var addMobileButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .large
        configuration.cornerStyle = .medium
        configuration.title = "Press"
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
            return outgoing
        }
        button.configuration = configuration
        return button
    }()

    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    // MARK: - Initial

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupHierarchy()
        setupLayout()
        setupView()
    }

    // MARK: - Settings

       private func setupHierarchy() {
           let subviews = [addModelTextField,
                           addEmeiTextField,
                           addMobileButton,
                           tableView]
           subviews.forEach { addSubview($0) }
       }

       private func setupLayout() {
           addModelTextField.snp.makeConstraints { make in
               make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
               make.left.equalTo(self.safeAreaLayoutGuide.snp.left).offset(Metrics.addUserTextFieldLeftOffset)
               make.right.equalTo(self.safeAreaLayoutGuide.snp.right).offset(Metrics.addUserTextFieldRightOffset)
               make.height.equalTo(Metrics.addUserTextFieldHeight)
           }

           addEmeiTextField.snp.makeConstraints { make in
               make.top.equalTo(addModelTextField.snp.bottom).offset(Metrics.addUserButtonTopOffset)
               make.left.right.equalTo(addModelTextField)
               make.height.equalTo(Metrics.addUserTextFieldHeight)
           }

           addMobileButton.snp.makeConstraints { make in
               make.top.equalTo(addEmeiTextField.snp.bottom).offset(Metrics.addUserButtonTopOffset)
               make.left.right.equalTo(addModelTextField)
           }

           tableView.snp.makeConstraints { make in
               make.top.equalTo(addMobileButton.snp.bottom).offset(Metrics.tableViewTopOffset)
               make.left.right.bottom.equalTo(self)
           }
       }

       private func setupView() {
           backgroundColor = .systemBackground
       }
}

// MARK: - Metrics

extension MobileView {
    enum Metrics {
        static let addUserTextFieldLeftOffset = 15
        static let addUserTextFieldRightOffset = -addUserTextFieldLeftOffset
        static let addUserTextFieldHeight = 45

        static let addUserButtonTopOffset = 10

        static let tableViewTopOffset = 20

        static let cornerRadius: CGFloat = 10
    }
}

