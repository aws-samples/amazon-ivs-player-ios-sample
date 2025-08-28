import UIKit
import AmazonIVSPlayer

class MainViewController: UIViewController, SourceSelectViewDelegate {
    @IBOutlet weak var playerView: IVSPlayerView!
    @IBOutlet weak var bufferIndicator: UIActivityIndicatorView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var playbackRateButton: UIButton!
    @IBOutlet weak var qualityButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var currentPositionLabel: UILabel!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var vodControlsView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playerStateLabel: UILabel!
    @IBOutlet weak var bufferedRangeProgressView: UIProgressView!
    @IBOutlet weak var controlsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsContentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoUrlEditButton: UIButton!

    var player: IVSPlayer?
    var periodicTimer: Timer?
    var isDarkMode: Bool = false
    var videoSourceEntities: [SourceEntity] = []

    let videoSourceEntitiesSaveKey: String = "sources_history_data"
    let playbackRates: [Float] = [2.0, 1.5, 1.0, 0.5]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        initializePlayerIfNecessary()
        applyStyleToControlsView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createAppLifetimeNotificationObservers()
        if #available(iOS 12.0, *) { isDarkMode = traitCollection.userInterfaceStyle == .dark }
        if player?.path == nil {
            loadStream(videoSourceEntities.first!.urlString)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        applyOrientationSize(forLandscape: UIDevice.current.orientation.isLandscape)
    }

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if let insets = UIApplication.shared.delegate?.window??.safeAreaInsets {
            playerViewTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 0 : -insets.top
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func applyStyleToControlsView() {
        controlsView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.clipsToBounds = true
        controlsView.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: controlsView.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: controlsView.widthAnchor),
            blurView.centerYAnchor.constraint(equalTo: controlsView.centerYAnchor),
            blurView.centerXAnchor.constraint(equalTo: controlsView.centerXAnchor)
        ])

        let launchedInLandscape = view.frame.size.height < view.frame.size.width
        controlsViewWidthConstraint.constant = launchedInLandscape ? view.frame.size.height : view.frame.size.width
        if UIDevice.current.userInterfaceIdiom == .pad { controlsViewWidthConstraint.constant *= 0.7 }
        applyOrientationSize(forLandscape: launchedInLandscape)
    }

    func applyOrientationSize(forLandscape: Bool) {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        controlsView.subviews.first!.layer.cornerRadius = (forLandscape || isIpad) ? 18 : 0
        controlsViewBottomConstraint.constant = (forLandscape || isIpad) ? 22 : 0
        controlsContentBottomConstraint.constant = (forLandscape || isIpad) ? 16 : 22
    }

    func initializePlayerIfNecessary() {
        guard player == nil else { return }
        player = IVSPlayer()
        player?.delegate = self
        playerView.player = player
        print("ℹ️ Player initialized: version \(player!.version)")
        startPeriodicTimer()
    }

    func loadStream(_ urlString: String) {
        if let url = URL(string: urlString) {
            player?.load(url)
            playTapped(self)
            if videoSourceEntities.filter({ $0.urlString == urlString }).count == 0 {
                videoSourceEntities.append(SourceEntity(urlString, urlString))
                saveData()
            }
        }
    }

    func startPeriodicTimer() {
        periodicTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updatePositionalLabels),
            userInfo: nil,
            repeats: true
        )
    }

    func createAppLifetimeNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    func presentAlert(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let close = UIAlertAction(title: "Close", style: .cancel)
            close.setValue(self?.isDarkMode ?? false ? DarkThemeColors.actionSheetItem : LightThemeColors.actionSheetItem, forKey: "titleTextColor")
            alert.addAction(close)

            let attributedMessage = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
            alert.setValue(attributedMessage, forKey: "attributedMessage")
            self?.present(alert, animated: true)
        }
    }

    func presentActionSheet(title: String, actions: [UIAlertAction], sourceView: UIView) {
        DispatchQueue.main.async { [weak self] in
            let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            let close = UIAlertAction(title: "Close", style: .cancel, handler: { (action) in
                actionSheet.dismiss(animated: true)
            })
            close.setValue(self?.isDarkMode ?? false ? DarkThemeColors.actionSheetItem : LightThemeColors.actionSheetItem, forKey: "titleTextColor")
            actionSheet.addAction(close)
            actions.forEach { actionSheet.addAction($0) }
            actionSheet.popoverPresentationController?.sourceView = sourceView
            actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
            self?.present(actionSheet, animated: true)
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.value(forKey: videoSourceEntitiesSaveKey) as? Data, let savedEntities = try? PropertyListDecoder().decode([SourceEntity].self, from: data) {
            videoSourceEntities = savedEntities
        } else {
            videoSourceEntities = [
                SourceEntity("Live stream Landscape", "https://fcc3ddae59ed.us-west-2.playback.live-video.net/api/video/v1/us-west-2.893648527354.channel.DmumNckWFTqz.m3u8"),
                SourceEntity("Recorded video Landscape", "https://d6hwdeiig07o4.cloudfront.net/ivs/956482054022/cTo5UpKS07do/2020-07-13T22-54-42.188Z/OgRXMLtq8M11/media/hls/master.m3u8")
            ]
        }
    }

    func saveData() {
        if let data = try? PropertyListEncoder().encode(videoSourceEntities) {
            UserDefaults.standard.setValue(data, forKey: videoSourceEntitiesSaveKey)
        }
    }

    func removeVideoSourceEntity(at index: Int) {
        videoSourceEntities.remove(at: index)
        saveData()
    }

    @objc func updatePositionalLabels() {
        currentPositionLabel.text = player?.position.positionalTime ?? ""
        seekSlider.value = Float(player?.position.seconds ?? 0)
        bufferedRangeProgressView.progress = Float(player?.buffered.seconds ?? 0) / Float(player?.duration.seconds ?? 0)
    }

    @IBAction func playerViewTapped(_ sender: Any) {
        controlsView.isHidden = !controlsView.isHidden
        videoUrlEditButton.isHidden = !videoUrlEditButton.isHidden
    }

    @IBAction func playbackRateTapped(_ sender: Any) {
        var playbackActions: [UIAlertAction] = []
        for rate in playbackRates {
            let action = UIAlertAction(
                title: "\(rate)x",
                style: .default,
                handler: { [weak self] (_) in
                    self?.player?.playbackRate = rate
                    self?.playbackRateButton.setTitle(String(rate), for: .normal)
                }
            )
            if rate == player?.playbackRate ?? 0 {
                action.isEnabled = false
                action.setValue(isDarkMode ? DarkThemeColors.actionSheetActiveItem : LightThemeColors.actionSheetActiveItem, forKey: "titleTextColor")
            } else {
                action.setValue(isDarkMode ? DarkThemeColors.actionSheetItem : LightThemeColors.actionSheetItem, forKey: "titleTextColor")
            }
            playbackActions.append(action)
        }
        presentActionSheet(title: "Playback speed", actions: playbackActions, sourceView: playbackRateButton)
    }

    @IBAction func qualityTapped(_ sender: Any) {
        guard let player = player else { return }
        let itemColor = isDarkMode ? DarkThemeColors.actionSheetItem : LightThemeColors.actionSheetItem
        let activeItemColor = isDarkMode ? DarkThemeColors.actionSheetActiveItem : LightThemeColors.actionSheetActiveItem
        var qualityActions: [UIAlertAction] = []

        let auto = UIAlertAction(title: "Auto", style: .default, handler: { [weak self] (_) in
            self?.player?.autoQualityMode = true
        })
        auto.isEnabled = !player.autoQualityMode
        auto.setValue(player.autoQualityMode ? activeItemColor : itemColor, forKey: "titleTextColor")
        qualityActions.append(auto)

        for quality in player.qualities {
            let action = UIAlertAction(title: quality.name, style: .default, handler: { [weak self] (_) in
                self?.player?.quality = quality
            })
            let isActive = player.quality == quality && !player.autoQualityMode
            action.isEnabled = !isActive
            action.setValue(isActive ? activeItemColor : itemColor, forKey: "titleTextColor")
            qualityActions.append(action)
        }

        qualityActions.sort { (first, second) -> Bool in
            guard let firstTitle = first.title, let secondTitle = second.title else { return false }
            return firstTitle.localizedStandardCompare(secondTitle) == .orderedDescending && firstTitle.first!.isNumber
        }

        presentActionSheet(title: "Quality options", actions: qualityActions, sourceView: qualityButton)
    }

    @IBAction func playTapped(_ sender: Any) {
        player?.play()
        playButton.isHidden = true
        pauseButton.isHidden = false
    }

    @IBAction func pauseTapped(_ sender: Any) {
        player?.pause()
        pauseButton.isHidden = true
        playButton.isHidden = false
    }

    @IBAction func onSeekbarValueChanged(_ sender: Any) {
        player?.seek(to: CMTime(seconds: Double(seekSlider.value), preferredTimescale: 600))
        currentPositionLabel.text = player?.position.positionalTime
    }

    @IBAction func editVideoUrlTapped(_ sender: Any) {
        performSegue(withIdentifier: "sourceSelectView", sender: self)
    }
}

extension MainViewController: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        switch state {
        case .buffering:
            bufferIndicator.startAnimating()
            playerStateLabel.text = "Buffering..."
            playerStateLabel.textColor = UIColor.white
            break
        case .playing:
            if player.duration.isIndefinite {
                playerStateLabel.text = "● LIVE"
                playerStateLabel.textColor = UIColor.red
            } else {
                playerStateLabel.text = "◼︎ RECORDED VIDEO"
                playerStateLabel.textColor = UIColor.white
            }
            bufferIndicator.stopAnimating()
            break
        case .ended:
            playerStateLabel.text = "Ended"
            playerStateLabel.textColor = UIColor.white
            bufferIndicator.stopAnimating()
            pauseButton.isHidden = true
            playButton.isHidden = false
        case .idle, .ready:
            playerStateLabel.text = "Paused"
            playerStateLabel.textColor = UIColor.white
            bufferIndicator.stopAnimating()
            break
        @unknown default:
            print("Unknown player state '\(state)'")
        }
    }

    func player(_ player: IVSPlayer, didFailWithError error: Error) {
        presentAlert(error.localizedDescription)
    }

    func player(_ player: IVSPlayer, didChangeDuration duration: CMTime) {
        vodControlsView.isHidden = duration.isValid && duration.isIndefinite

        if duration.isValid && !duration.isIndefinite {
            durationLabel.text = duration.positionalTime
            seekSlider.maximumValue = Float(duration.seconds)
            seekSlider.setValue(0, animated: false)
        }
    }
}

extension MainViewController {
    @objc func applicationDidEnterBackground() {
        print("ℹ️ Application did enter background")
        player?.pause()
        playerView.player = nil
        periodicTimer?.invalidate()
    }

    @objc func applicationWillResignActive() {
        print("ℹ️ Application will resign active")
        player?.pause()
    }

    @objc func applicationDidBecomeActive() {
        print("ℹ️ Application did become active")
        if #available(iOS 12.0, *) { isDarkMode = traitCollection.userInterfaceStyle == .dark }
        if player?.state == .idle && player?.error == nil {
            player?.play()
        }
    }

    @objc func applicationWillEnterForeground() {
        print("ℹ️ Application will enter foreground")
        playerView.player = player
        startPeriodicTimer()
        if player?.state == .idle && player?.error == nil {
            player?.play()
        }
    }
}
