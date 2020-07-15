import UIKit
import AmazonIVSPlayer

class PlayerViewController: UIViewController {
    @IBOutlet weak var playerView: IVSPlayerView!
    @IBOutlet weak var playerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var sourceSelectButton: UIButton!
    @IBOutlet weak var bufferIndicator: UIActivityIndicatorView!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var waitingLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var questionStackView: UIStackView!

    var player: IVSPlayer?
    var sourceUrl: String = ""
    var currentQuestion: Question?

    let videoSourceEntitiesSaveKey: String = "sources_history_data"
    let jsonDecoder = JSONDecoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializePlayerIfNecessary()
        liveLabel.layer.cornerRadius = 9
        playerView.layer.cornerRadius = 15
        questionView.layer.cornerRadius = 20
        questionStackView.alignment = .fill
        questionStackView.isLayoutMarginsRelativeArrangement = true
        view.applyGradientBackground()
        playerView.applyShadow()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadStream()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func initializePlayerIfNecessary() {
        guard player == nil else { return }
        player = IVSPlayer()
        player?.delegate = self
        playerView.player = player
        print("ℹ️ Player initialized: version \(player!.version)")
    }

    func loadStream() {
        if let url = URL(string: sourceUrl) {
            player?.load(url)
            player?.play()
        }
    }

    func setPlayerViewSize(_ newVideoSize: CGSize) {
        let newHeight = playerView.bounds.width / (newVideoSize.width / newVideoSize.height)
        guard newHeight.isFinite else {
            return
        }
        playerViewHeightConstraint.constant = newHeight
        view.layoutIfNeeded()
    }

    func show(_ question: Question) {
        questionView.layer.removeAllAnimations()
        questionStackView.subviews.forEach { $0.layer.removeAllAnimations(); $0.removeFromSuperview() }
        questionView.alpha = 1
        questionTitle.text = question.question
        questionTitle.sizeToFit()
        question.answers.forEach { (answer) in
            let answerButton = AnswerButton(answer)
            answerButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            questionStackView.addArrangedSubview(answerButton)
        }
        currentQuestion = question
        questionView.isHidden = false
    }

    @objc func answerTapped(_ button: AnswerButton) {
        button.isSelected = true
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseInOut, .autoreverse], animations: { [weak self] in
            if let title = button.titleLabel?.text, let question = self?.currentQuestion {
                let isCorrect = title == question.answers[question.correctIndex]
                button.setBackgroundColor(isCorrect ? UIColor(red: 0.15, green: 0.65, blue: 0.01, alpha: 1) : UIColor(red: 0.82, green: 0.2, blue: 0.07, alpha: 1), forState: .selected)
            }
            button.setTitleColor(.white, for: .normal)
            button.alpha = 0.3
            }, completion: { [weak self] (_) in
                self?.hideQuestion()
        })
    }

    func hideQuestion() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: { [weak self] in
            self?.questionView.alpha = 0.1
        }) { [weak self] (_) in
            self?.questionView.isHidden = true
        }
    }

    func showWaitingLabel() {
        waitingLabel.isHidden = false
        waitingLabelHeightConstraint.constant = 25
        UIView.animate(withDuration: 3,
                       delay: 0,
                       options: [.curveEaseInOut, .repeat, .autoreverse],
                       animations: { [weak self] in
                        self?.waitingLabelHeightConstraint.constant = 50
                        self?.view.layoutIfNeeded()
        })
    }

    func hideWaitingLabel() {
        waitingLabel.layer.removeAllAnimations()
        waitingLabel.isHidden = true
    }

    @IBAction func tappedSourceSelectButton(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension PlayerViewController: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        liveLabel.isHidden = state != .playing
        switch state {
        case .buffering:
            bufferIndicator.startAnimating()
            break
        case .playing:
            bufferIndicator.stopAnimating()
            showWaitingLabel()
            break
        default:
            bufferIndicator.stopAnimating()
            hideWaitingLabel()
            break
        }
    }

    func player(_ player: IVSPlayer, didChangeVideoSize videoSize: CGSize) {
        setPlayerViewSize(videoSize)
    }

    func player(_ player: IVSPlayer, didFailWithError error: Error) {
        print("‼️ got error: \(error.localizedDescription)")
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak self] (_) in
            if self?.player?.state != .playing { self?.dismiss(animated: true) }
        }))
        present(alert, animated: true)
    }

    func player(_ player: IVSPlayer, didOutputCue cue: IVSCue) {
        guard let textMetadataCue = cue as? IVSTextMetadataCue,
            let jsonData = textMetadataCue.text.data(using: .utf8),
            let question = try? jsonDecoder.decode(Question.self, from: jsonData) else {
            return
        }

        show(question)
    }
}
