import GameKit

class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterManager()
    
    var viewController: UIViewController?
    var leaderboardID = "com.infinityretro.highscore" // Replace with actual ID set in App Store Connect
    
    private override init() {
        super.init()
    }
    
    func authenticateLocalPlayer(presentingVC: UIViewController) {
        self.viewController = presentingVC
        
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] (vc, error) in
            if let vc = vc {
                // Present auth view controller
                self?.viewController?.present(vc, animated: true)
            } else if localPlayer.isAuthenticated {
                print("Game Center: Authenticated")
                // Enable Game Center features if previously disabled
            } else {
                print("Game Center: Auth failed or disabled")
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func submitScore(score: Int) {
        if GKLocalPlayer.local.isAuthenticated {
             // Use new iOS 14+ API if available, or fallback
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
                if let error = error {
                    print("Error submitting score: \(error.localizedDescription)")
                } else {
                    print("Score submitted: \(score)")
                }
            }
        }
    }
    
    func showLeaderboard() {
        guard let vc = viewController else { return }
        
        let gcVC = GKGameCenterViewController(state: .leaderboards)
        gcVC.gameCenterDelegate = self
        vc.present(gcVC, animated: true, completion: nil)
    }
    
    // MARK: - Delegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
