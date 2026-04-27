import UIKit

class SamplesViewController: UITableViewController {

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError() }

    private struct Sample {
        let title: String
        let subtitle: String
        let storyboardName: String
    }

    private let samples = [
        Sample(title: "Basic Playback", subtitle: "Simple streaming with standard controls", storyboardName: "BasicPlayback"),
        Sample(title: "Custom UI", subtitle: "Custom player controls with source selection", storyboardName: "CustomUI"),
        Sample(title: "Quiz Demo", subtitle: "Interactive quiz over timed metadata", storyboardName: "QuizDemo"),
    ]

    private let cellIdentifier = "SampleCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IVS Player Samples"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        samples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let sample = samples[indexPath.row]
        if #available(iOS 14.0, *) {
            var config = cell.defaultContentConfiguration()
            config.text = sample.title
            config.secondaryText = sample.subtitle
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = sample.title
            cell.detailTextLabel?.text = sample.subtitle
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sample = samples[indexPath.row]
        let storyboard = UIStoryboard(name: sample.storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else { return }
        show(vc, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
