import SpriteKit
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    var backgroundMusicPlayer: AVAudioPlayer?
    
    // Pre-load actions
    // Note: SpriteKit searches the bundle. If "sounds" is a folder reference, use "sounds/file.mp3".
    let shootSound = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
    let powerUpSound = SKAction.playSoundFileNamed("powerup.mp3", waitForCompletion: false)
    let enemyShootSound = SKAction.playSoundFileNamed("enemy_shoot.mp3", waitForCompletion: false)
    
    private init() {
        // Configure Audio Session to allow mixing and playback even if silent switch is on
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    func startBackgroundMusic() {
        // If already playing, don't restart
        if backgroundMusicPlayer?.isPlaying == true { return }
        
        // Try to find the file
        // Assumes "ambient.mp3" is in the main bundle (or 'sounds' folder added as group)
        if let bundlePath = Bundle.main.path(forResource: "ambient", ofType: "mp3") {
            let url = URL(fileURLWithPath: bundlePath)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1 // Infinite
                backgroundMusicPlayer?.volume = 0.5 // Background, not too loud
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not load background music: \(error)")
            }
        } else {
            // Check specific 'sounds' folder path if needed, though Bundle.main.path typically finds it in Groups
            print("ambient.mp3 not found in Bundle")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func playShoot(scene: SKScene) {
        scene.run(shootSound)
    }
    
    func playExplosion(scene: SKScene) {
        scene.run(explosionSound)
    }
    
    func playPowerUp(scene: SKScene) {
        scene.run(powerUpSound)
    }
    
    func playEnemyShoot(scene: SKScene) {
        scene.run(enemyShootSound)
    }
    
    // New Boss Sound
    let bossIncomingSound = SKAction.playSoundFileNamed("boss_incoming.m4a", waitForCompletion: false)
    
    func playBossIncoming(scene: SKScene) {
        scene.run(bossIncomingSound)
    }
}
