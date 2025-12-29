import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Game Center Auth
        GameCenterManager.shared.authenticateLocalPlayer(presentingVC: self)
        
        // Configure the view
        if let view = self.view as! SKView? {
            // Create the scene
            // We use a size consistent with modern iPhones but the scene will scale
            let scene = MenuScene(size: CGSize(width: 750, height: 1334))
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // view.showsFPS = true
            // view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
