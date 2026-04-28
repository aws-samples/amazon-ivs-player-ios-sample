import UIKit

class QuizDemoSourceViewController: UIViewController {
    @IBOutlet weak var sourceInputTextField: UITextField!
    @IBOutlet weak var sourceEntitiesTableView: UITableView!

    var sources: [Source] = []
    var selectedUrl: String = ""

    let sourcesSaveKey = "quiz_sources_history_data"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        sourceInputTextField.delegate = self
        sourceEntitiesTableView.delegate = self
        sourceEntitiesTableView.dataSource = self
        sourceEntitiesTableView.register(SourceTableViewCell.self, forCellReuseIdentifier: SourceTableViewCell.reuseIdentifier)
        sourceEntitiesTableView.tableFooterView = UIView()
        sourceInputTextField.attributedPlaceholder = NSAttributedString(string: "Enter a custom playback URL",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.5)])
        sourceInputTextField.layer.cornerRadius = 10
        sourceInputTextField.layer.masksToBounds = true
        view.applyGradientBackground()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    func loadData() {
        if let data = UserDefaults.standard.value(forKey: sourcesSaveKey) as? Data, let savedEntities = try? PropertyListDecoder().decode([Source].self, from: data) {
            sources = savedEntities
        } else {
            sources = [
                Source("Pre-defined stream 1", "https://4c62a87c1810.us-west-2.playback.live-video.net/api/video/v1/us-west-2.049054135175.channel.GHRwjPylmdXm.m3u8")
            ]
        }
    }

    func saveData() {
        if let data = try? PropertyListEncoder().encode(sources) {
            UserDefaults.standard.setValue(data, forKey: sourcesSaveKey)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayerView", let playerVC = segue.destination as? QuizDemoViewController {
            playerVC.sourceUrl = selectedUrl
        }
    }

    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        if let path = sourceEntitiesTableView.indexPathForRow(at: sender.location(in: sourceEntitiesTableView)) {
            tableView(sourceEntitiesTableView, didSelectRowAt: path)
        } else {
            sourceInputTextField.resignFirstResponder()
        }
    }
}

extension QuizDemoSourceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedUrl = textField.text ?? ""
        if sources.filter({ $0.urlString == selectedUrl }).count == 0 {
            sources.append(Source(selectedUrl, selectedUrl))
            saveData()
            sourceEntitiesTableView.reloadData()
        }
        performSegue(withIdentifier: "toPlayerView", sender: self)
        return true
    }
}

extension QuizDemoSourceViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sources.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SourceTableViewCell.reuseIdentifier, for: indexPath) as? SourceTableViewCell else { return UITableViewCell() }
        cell.configure(with: sources[indexPath.section])
        return cell
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SourceTableViewCell {
            cell.textLabel?.textColor = .white
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SourceTableViewCell {
            cell.textLabel?.textColor = SourceTableViewCell.textColor
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUrl = sources[indexPath.section].urlString
        performSegue(withIdentifier: "toPlayerView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.sources.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .left)
            }
            self?.saveData()
        }
        return [delete]
    }
}
