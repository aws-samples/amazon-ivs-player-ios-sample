import UIKit
import AmazonIVSPlayer

class ViewController: UIViewController {

    // MARK: IBOutlet

    @IBOutlet private var playerView: IVSPlayerView!
    @IBOutlet private var bufferIndicator: UIActivityIndicatorView!
    @IBOutlet private var controlsView: UIView!
    @IBOutlet private var playbackRateButton: UIButton!
    @IBOutlet private var qualityButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var pauseButton: UIButton!
    @IBOutlet private var currentPositionLabel: UILabel!
    @IBOutlet private var seekSlider: UISlider!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var bufferedRangeProgressView: UIProgressView!

    // MARK: IBAction

    @IBAction private func playbackRateTapped(_ sender: Any) {
        presentPlaybackRates()
    }

    @IBAction private func qualityTapped(_ sender: Any) {
        presentQualities()
    }

    @IBAction private func playTapped(_ sender: Any) {
        startPlayback()
    }

    @IBAction private func pauseTapped(_ sender: Any) {
        pausePlayback()
    }

    @IBAction private func onSeekSliderValueChanged(_ sender: UISlider, event: UIEvent) {
        guard let touchEvent = event.allTouches?.first else {
            seek(toFractionOfDuration: sender.value)
            return
        }

        switch touchEvent.phase {
        case .began, .moved:
            seekStatus = .choosing(sender.value)

        case .ended:
            seek(toFractionOfDuration: sender.value)

        case .cancelled:
            seekStatus = nil

        default: ()
        }
    }

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        connectProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpDisplayLink()

        let url = URL(string: "https://fcc3ddae59ed.us-west-2.playback.live-video.net/api/video/v1/us-west-2.893648527354.channel.DmumNckWFTqz.m3u8")!

        loadStream(from: url)

        startPlayback()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        pausePlayback()

        tearDownDisplayLink()
    }

    // MARK: Application Lifecycle

    private var didPauseOnBackground = false

    @objc private func applicationDidEnterBackground(notification: Notification) {
        if player?.state == .playing || player?.state == .buffering {
            didPauseOnBackground = true
            pausePlayback()
        } else {
            didPauseOnBackground = false
        }
    }

    @objc private func applicationDidBecomeActive(notification: Notification) {
        if didPauseOnBackground {
            startPlayback()
            didPauseOnBackground = false
        }
    }

    private func addApplicationLifecycleObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func removeApplicationLifecycleObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    // MARK: State display

    private var playbackPositionDisplayLink: CADisplayLink?

    private func setUpDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(playbackDisplayLinkDidFire(_:)))
        displayLink.preferredFramesPerSecond = 5
        displayLink.isPaused = player?.state != .playing
        displayLink.add(to: .main, forMode: .common)
        playbackPositionDisplayLink = displayLink
    }

    private func tearDownDisplayLink() {
        playbackPositionDisplayLink?.invalidate()
        playbackPositionDisplayLink = nil
    }

    @objc private func playbackDisplayLinkDidFire(_ displayLink: CADisplayLink) {
        self.updatePositionDisplay()
        self.updateBufferProgress()
    }

    private let timeDisplayFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private func updatePositionDisplay() {
        guard let player = player else {
            currentPositionLabel.text = nil
            return
        }
        let playerPosition = player.position
        let duration = player.duration
        let position: CMTime
        switch seekStatus {
        case let .choosing(fractionOfDuration):
            position = CMTimeMultiplyByFloat64(duration, multiplier: Float64(fractionOfDuration))
        case let .requested(seekPosition):
            position = seekPosition
        case nil:
            position = playerPosition
            updateSeekSlider(position: position, duration: duration)
        }
        currentPositionLabel.text = timeDisplayFormatter.string(from: position.seconds)
    }

    private var bufferedRangeProgress: Progress? {
        didSet {
            connectProgress()
        }
    }

    private func connectProgress() {
        bufferedRangeProgressView?.observedProgress = bufferedRangeProgress
    }

    private func updateBufferProgress() {
        guard let duration = player?.duration, let buffered = player?.buffered,
            duration.isNumeric, buffered.isNumeric else {
                bufferedRangeProgress?.completedUnitCount = 0
                return
        }
        let scaledBuffered = buffered.convertScale(duration.timescale, method: .default)
        bufferedRangeProgress?.completedUnitCount = scaledBuffered.value
    }

    private enum SeekStatus: Equatable {
        case choosing(Float)
        case requested(CMTime)
    }

    private var seekStatus: SeekStatus? {
        didSet {
            updatePositionDisplay()
        }
    }

    private func updateSeekSlider(position: CMTime, duration: CMTime) {
        if duration.isNumeric && position.isNumeric {
            let scaledPosition = position.convertScale(duration.timescale, method: .default)
            let progress = Double(scaledPosition.value) / Double(duration.value)
            seekSlider.setValue(Float(progress), animated: false)
        }
    }

    private func updateForState(_ state: IVSPlayer.State) {
        playbackPositionDisplayLink?.isPaused = state != .playing

        let showPause = state == .playing || state == .buffering
        pauseButton.isHidden = !showPause
        playButton.isHidden = showPause

        if state == .buffering {
            bufferIndicator?.startAnimating()
        } else {
            bufferIndicator?.stopAnimating()
        }
    }

    private func updateForDuration(duration: CMTime) {
        if duration.isIndefinite {
            durationLabel.text = "Live"
            durationLabel.isHidden = false
            seekSlider.isHidden = true
            bufferedRangeProgressView.isHidden = true
            bufferedRangeProgress = nil
        } else if duration.isNumeric {
            durationLabel.text = timeDisplayFormatter.string(from: duration.seconds)
            durationLabel.isHidden = false
            seekSlider.isHidden = false
            bufferedRangeProgress = Progress.discreteProgress(totalUnitCount: duration.value)
            updateBufferProgress()
            bufferedRangeProgressView.isHidden = false
        } else {
            durationLabel.text = nil
            durationLabel.isHidden = true
            seekSlider.isHidden = true
            bufferedRangeProgressView.isHidden = true
            bufferedRangeProgress = nil
        }
    }

    private func presentError(_ error: Error, componentName: String) {
        let alert = UIAlertController(title: "\(componentName) Error", message: String(reflecting: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    private func presentActionSheet(title: String, actions: [UIAlertAction], sourceView: UIView) {
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(
            UIAlertAction(title: "Close", style: .cancel, handler: { _ in
                actionSheet.dismiss(animated: true)
            })
        )
        actions.forEach { actionSheet.addAction($0) }
        actionSheet.popoverPresentationController?.sourceView = sourceView
        actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        present(actionSheet, animated: true)
    }

    // MARK: - Player

    var player: IVSPlayer? {
        didSet {
            if oldValue != nil {
                removeApplicationLifecycleObservers()
            }
            playerView?.player = player
            seekStatus = nil
            updatePositionDisplay()
            if player != nil {
                addApplicationLifecycleObservers()
            }
        }
    }

    // MARK: Playback Control

    func loadStream(from streamURL: URL) {
        let player: IVSPlayer
        if let existingPlayer = self.player {
            player = existingPlayer
        } else {
            player = IVSPlayer()
            player.delegate = self
            self.player = player
            print("ℹ️ Player initialized: version \(player.version)")
        }
        player.load(streamURL)
    }

    private func seek(toFractionOfDuration fraction: Float) {
        guard let player = player else {
            seekStatus = nil
            return
        }
        let position = CMTimeMultiplyByFloat64(player.duration, multiplier: Float64(fraction))
        seek(to: position)
    }

    private func seek(to position: CMTime) {
        guard let player = player else {
            seekStatus = nil
            return
        }
        seekStatus = .requested(position)
        player.seek(to: position) { [weak self] _ in
            guard let self = self else {
                return
            }
            if self.seekStatus == .requested(position) {
                self.seekStatus = nil
            }
        }
    }

    private func startPlayback() {
        player?.play()
    }

    private func pausePlayback() {
        player?.pause()
    }

    private func presentPlaybackRates() {
        let minPlaybackRate: Float = 0.5
        let maxPlaybackRate: Float = 2.0
        // Present valid rates (0.5 to 2.0) in increments of 0.5
        let rates = stride(from: minPlaybackRate, through: maxPlaybackRate, by: 0.5)

        let actions: [UIAlertAction] = rates.map { rate in
            UIAlertAction(title: "\(rate)x", style: .default) { [weak self] _ in
                self?.player?.playbackRate = rate
                self?.playbackRateButton.setTitle(String(rate), for: .normal)
            }
        }
        presentActionSheet(title: "Playback speed", actions: actions, sourceView: playbackRateButton)
    }

    private func presentQualities() {
        guard let player = player else { return }

        var actions = [UIAlertAction]()

        let autoMode = player.autoQualityMode
        actions.append(
            UIAlertAction(title: "Auto \(autoMode ? "✔️" : "")", style: .default) { [weak self, weak player] _ in
                guard let player = player, self?.player == player else {
                    return
                }
                player.autoQualityMode = !autoMode
            }
        )

        for quality in player.qualities {
            let isCurrent = player.quality == quality
            actions.append(
                UIAlertAction(title: "\(quality.name) \(isCurrent ? "✔️" : "")", style: .default) { [weak self, weak player] _ in
                    guard let player = player, self?.player == player else {
                        return
                    }
                    player.quality = quality
                }
            )
        }

        presentActionSheet(title: "Quality options", actions: actions, sourceView: qualityButton)
    }
}

// MARK: - IVSPlayer.Delegate

extension ViewController: IVSPlayer.Delegate {

    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        updateForState(state)
    }

    func player(_ player: IVSPlayer, didFailWithError error: Error) {
        presentError(error, componentName: "Player")
    }

    func player(_ player: IVSPlayer, didChangeDuration duration: CMTime) {
        updateForDuration(duration: duration)
    }

    func player(_ player: IVSPlayer, didOutputCue cue: IVSCue) {
        switch cue {
        case let textMetadataCue as IVSTextMetadataCue:
            print("Received Timed Metadata (\(textMetadataCue.textDescription)): \(textMetadataCue.text)")
        case let textCue as IVSTextCue:
            print("Received Text Cue: “\(textCue.text)”")
        default:
            print("Received unknown cue (type \(cue.type))")
        }
    }

    func player(_ player: IVSPlayer, didOutputMetadataWithType type: String, content: Data) {
        if type == "text/plain" {
            guard let textData = String(data: content, encoding: .utf8) else {
                print("Unable to parse metadata as string")
                return
            }
            print("Received Timed Metadata: \(textData)")
        }
    }

    func playerWillRebuffer(_ player: IVSPlayer) {
        print("Player will rebuffer and resume playback")
    }
}
