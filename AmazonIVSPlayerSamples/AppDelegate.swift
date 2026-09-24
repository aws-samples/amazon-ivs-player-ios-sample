import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("‼️ Could not setup AVAudioSession: \(error)")
        }

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
