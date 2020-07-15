import UIKit

class SourceViewController: UIViewController {
    @IBOutlet weak var sourceInputTextField: UITextField!
    @IBOutlet weak var sourceEntitiesTableView: UITableView!

    var videoSourceEntities: [SourceEntity] = []
    var selectedUrl: String = ""

    let videoSourceEntitiesSaveKey = "sources_history_data"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        sourceInputTextField.delegate = self
        sourceEntitiesTableView.delegate = self
        sourceEntitiesTableView.dataSource = self
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sourceEntitiesTableView.reloadData()
    }

    func loadData() {
        if let data = UserDefaults.standard.value(forKey: videoSourceEntitiesSaveKey) as? Data, let savedEntities = try? PropertyListDecoder().decode([SourceEntity].self, from: data) {
            videoSourceEntities = savedEntities
        } else {
            videoSourceEntities = [
                SourceEntity("Pre-defined stream 1", "https://fcc3ddae59ed.us-west-2.playback.live-video.net/api/video/v1/us-west-2.893648527354.channel.xhP3ExfcX8ON.m3u8")
            ]
        }
    }

    func saveData() {
        if let data = try? PropertyListEncoder().encode(videoSourceEntities) {
            UserDefaults.standard.setValue(data, forKey: videoSourceEntitiesSaveKey)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayerView", let playerVC = segue.destination as? PlayerViewController {
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

extension SourceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedUrl = textField.text ?? ""
        if videoSourceEntities.filter({ $0.urlString == selectedUrl }).count == 0 {
            videoSourceEntities.append(SourceEntity(selectedUrl, selectedUrl))
            saveData()
            sourceEntitiesTableView.reloadData()
        }
        performSegue(withIdentifier: "toPlayerView", sender: self)
        return true
    }
}

extension SourceViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        videoSourceEntities.count
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "sourceEntityCell", for: indexPath) as? SourceEntityCell else { return UITableViewCell() }
        cell.fill(videoSourceEntities[indexPath.section].title)
        return cell
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SourceEntityCell {
            cell.label.textColor = .white
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SourceEntityCell {
            cell.label.textColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUrl = videoSourceEntities[indexPath.section].urlString
        performSegue(withIdentifier: "toPlayerView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { [weak self] (_, _) in
            DispatchQueue.main.async {
                self?.videoSourceEntities.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .left)
            }
            self?.saveData()
        }
        return [delete]
    }
}
