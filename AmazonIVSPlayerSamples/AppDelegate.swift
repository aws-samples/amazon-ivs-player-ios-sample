import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("‼️ Could not setup AVAudioSession: \(error)")
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = SamplesNavigationController(rootViewController: SamplesViewController())
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let nav = window?.rootViewController as? UINavigationController,
           let top = nav.topViewController {
            return top.supportedInterfaceOrientations
        }
        return .all
    }
}

class SamplesNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? { topViewController }
}
