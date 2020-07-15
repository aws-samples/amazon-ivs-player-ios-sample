import UIKit
import AmazonIVSPlayer

protocol SourceSelectViewDelegate {
    var player: IVSPlayer? { get }
    var videoSourceEntities: [SourceEntity] { get set }

    func loadStream(_ urlString: String)
    func removeVideoSourceEntity(at index: Int)
}

class SourceSelectViewController: UIViewController {
    @IBOutlet weak var urlInputTextField: UITextField!
    @IBOutlet weak var predefinedUrlsTableView: UITableView!

    var delegate: SourceSelectViewDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate = presentingViewController as? SourceSelectViewDelegate
        urlInputTextField.text = delegate?.player?.path?.absoluteString
        urlInputTextField.delegate = self
        predefinedUrlsTableView.dataSource = self
        predefinedUrlsTableView.delegate = self
        predefinedUrlsTableView.tableFooterView = UIView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func loadNewSource(_ urlString: String) {
        dismissKeyboard()
        delegate?.loadStream(urlString)
        closeButtonTapped(self)
    }

    func dismissKeyboard() {
        urlInputTextField.resignFirstResponder()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        if let path = predefinedUrlsTableView.indexPathForRow(at: sender.location(in: predefinedUrlsTableView)) {
            tableView(predefinedUrlsTableView, didSelectRowAt: path)
        } else {
            dismissKeyboard()
        }
    }
}

extension SourceSelectViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadNewSource(textField.text ?? "")
        return true
    }
}

extension SourceSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        delegate?.videoSourceEntities.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let delegate = delegate, let cell = tableView.dequeueReusableCell(withIdentifier: "sourceUrlCell", for: indexPath) as? SourceTableViewCell else { return UITableViewCell() }
        cell.configure(with: delegate.videoSourceEntities[indexPath.section].title)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        loadNewSource(delegate.videoSourceEntities[indexPath.section].urlString)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 1
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if #available(iOS 11.0, *) {} else {
            if let cell = tableView.cellForRow(at: indexPath) as? SourceTableViewCell {
                cell.applyMaskLayer(90)
            }
        }
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if #available(iOS 11.0, *) {} else {
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? SourceTableViewCell {
                cell.applyMaskLayer()
            }
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let delegate = delegate else { return [] }
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            DispatchQueue.main.async {
                delegate.removeVideoSourceEntity(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .left)
            }
        }
        return [delete]
    }
}
