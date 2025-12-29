import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: Player!
    var lastUpdateTime: TimeInterval = 0
    var enemySpawnTimer: TimeInterval = 0
    var enemySpawnRate: TimeInterval = 2.0
    private var isGameOver: Bool = false
    
    var scoreLabel: SKLabelNode!
    // var livesLabel: SKLabelNode! (Removed)
    
    var backgroundLayer1: SKNode!
    var backgroundLayer2: SKNode!
    
    // Touch handling for drag movement
    #if canImport(UIKit)
    private var activeTouch: UITouch?
    #endif
    private var touchOffsetFromPlayer = CGPoint.zero
    
    // Physics Categories
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let player    : UInt32 = 0b1       // 1
        static let laser     : UInt32 = 0b10      // 2
        static let enemy     : UInt32 = 0b100     // 4
        static let enemyLaser: UInt32 = 0b1000    // 8
        static let powerUp   : UInt32 = 0b10000   // 16
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Reset state only if starting fresh
        UpgradeManager.shared.reset()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        setupStarfield()
        setupPlayer()
        setupHUD()
        
        // Apply Retro Shader
        self.shader = SKShader(fileNamed: "RetroShader")
        self.shouldEnableEffects = true
        
        isUserInteractionEnabled = true
        self.view?.isMultipleTouchEnabled = true
    }
    
    func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(player)
    }
    
    func setupStarfield() {
        backgroundLayer1 = createStarLayer()
        backgroundLayer1.position = CGPoint(x: 0, y: 0)
        addChild(backgroundLayer1)
        
        backgroundLayer2 = createStarLayer()
        backgroundLayer2.position = CGPoint(x: 0, y: size.height)
        addChild(backgroundLayer2)
    }
    
    func createStarLayer() -> SKNode {
        let layer = SKNode()
        let starCount = 50
        
        for _ in 0..<starCount {
            let star = SKShapeNode(rectOf: CGSize(width: 2, height: 2))
            star.fillColor = .white
            star.strokeColor = .clear
            let maxW = max(size.width, 1)
            let maxH = max(size.height, 1)
            let x = CGFloat.random(in: 0...maxW)
            let y = CGFloat.random(in: 0...maxH)
            star.position = CGPoint(x: x, y: y)
            layer.addChild(star)
        }
        return layer
    }
    
    private func safeRandomX(padding: CGFloat = 50) -> CGFloat {
        let minX = padding
        let maxX = size.width - padding
        if maxX < minX {
            // Scene too narrow; place in center
            return size.width / 2
        }
        return CGFloat.random(in: minX...maxX)
    }
    
    func updateStarfield(dt: TimeInterval) {
        let speed: CGFloat = 300.0 * CGFloat(dt)
        backgroundLayer1.position.y -= speed
        backgroundLayer2.position.y -= speed
        
        if backgroundLayer1.position.y < -size.height {
            backgroundLayer1.position.y = backgroundLayer2.position.y + size.height
        }
        
        if backgroundLayer2.position.y < -size.height {
            backgroundLayer2.position.y = backgroundLayer1.position.y + size.height
        }
    }
    
    // Local protocol to avoid ambiguous type lookup for Missile/Laser subclasses
    @objc protocol UpdatableNode {
        func update(dt: TimeInterval)
    }
    
    // MARK: - Update Loop
    var isBossActive: Bool = false
    
    override func update(_ currentTime: TimeInterval) {
        // Delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update Managers
        UpgradeManager.shared.update(dt: dt)
        updateStarfield(dt: dt)
        
        // Check for Boss Spawn Condition (Every 50 kills)
        let kills = UpgradeManager.shared.kills
        if kills > 0 && kills % 50 == 0 && !isBossActive {
             spawnBoss(index: kills / 50)
        }
        
        // Spawn Enemies (Normal) only if no boss
        if !isBossActive {
            enemySpawnTimer += dt
            if enemySpawnTimer >= enemySpawnRate {
                enemySpawnTimer = 0
                spawnEnemy()
                
                // PowerUp Spawn Chance (20%)
                if Double.random(in: 0...1) < 0.2 {
                    spawnPowerUp()
                }
                
                 // Increase difficulty
                if enemySpawnRate > 0.4 {
                    enemySpawnRate -= 0.05
                }
            }
        }
        
        // Update Player
        player.update(dt: dt)
        
        // Update Enemies & Boss
        enumerateChildNodes(withName: "enemy") { node, _ in
            if let enemy = node as? Enemy {
                enemy.update(dt: dt)
                
                // Leak Check (Enemy passed player)
                if enemy.position.y < -50 {
                    enemy.removeFromParent()
                    self.handlePlayerDamage()
                }
            }
        }
        enumerateChildNodes(withName: "boss") { node, _ in
             if let boss = node as? Boss {
                 boss.update(dt: dt)
             }
        }
        
        // Update Missiles
        enumerateChildNodes(withName: "missile") { node, _ in
            if let updatable = node as? UpdatableNode {
                updatable.update(dt: dt)
            }
        }
        
        // Remove entities off screen
        enumerateChildNodes(withName: "laser") { node, _ in
            if node.position.y > self.size.height + 50 {
                node.removeFromParent()
            }
        }
        
        enumerateChildNodes(withName: "enemyLaser") { node, _ in
            if node.position.y < -50 {
                node.removeFromParent()
            }
        }
    }
    
    func updateSpawning(dt: TimeInterval) {
        enemySpawnTimer += dt
        if enemySpawnTimer >= enemySpawnRate {
            enemySpawnTimer = 0
            spawnEnemy()
            
            // PowerUp Spawn Chance (20%)
            if Double.random(in: 0...1) < 0.2 {
                spawnPowerUp()
            }
            
             // Increase difficulty
            if enemySpawnRate > 0.4 {
                enemySpawnRate -= 0.05
            }
        }
    }
    
    func spawnEnemy() {
        let baseHP = 3
        let scaledHP = baseHP + Int(max(0, (2.0 - enemySpawnRate) * 2))
        let enemy = Enemy(maxKillableHp: scaledHP)
        let randomX = safeRandomX(padding: 50)
        enemy.position = CGPoint(x: randomX, y: size.height + 50)
        addChild(enemy)
        
        // Slower movement (was 5.5, now ~8.5 for 35% speed reduction)
        let moveDown = SKAction.moveTo(y: -100, duration: 8.5)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveDown, remove]))
    }
    
    func spawnPowerUp() {
        // 10% Chance for Mega Laser (Blue)
        let isMega = Double.random(in: 0...1) < 0.1
        let type = isMega ? 1 : 0
        
        let pu = PowerUp(type: type)
        let randomX = safeRandomX(padding: 50)
        pu.position = CGPoint(x: randomX, y: size.height + 50)
        addChild(pu)
        
        let moveDown = SKAction.moveTo(y: -100, duration: 6.0)
        let remove = SKAction.removeFromParent()
        pu.run(SKAction.sequence([moveDown, remove]))
    }
    
    // MARK: - Physics
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Laser hits Enemy
        if (firstBody.categoryBitMask & PhysicsCategory.laser != 0) &&
           (secondBody.categoryBitMask & PhysicsCategory.enemy != 0) {
            if let projectile = firstBody.node as? SKNode, let enemy = secondBody.node as? Enemy {
                laserDidHitEnemy(laser: projectile, enemy: enemy)
            }
        }
        
        // PowerUp
        if (firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
           (secondBody.categoryBitMask & PhysicsCategory.powerUp != 0) {
            if let pu = secondBody.node as? PowerUp {
                pu.removeFromParent()
                
                if pu.type == 1 {
                    // MEGA LASER
                    UpgradeManager.shared.activateMegaLaser()
                } else {
                    // Regular
                    UpgradeManager.shared.powerUpCollected()
                }
                
                SoundManager.shared.playPowerUp(scene: self)
                // Sound / Visual
                let flash = SKAction.sequence([SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.1), SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.1)])
                player.run(flash)
            }
        }
        
        // Player hits Enemy
        if (firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
           (secondBody.categoryBitMask & PhysicsCategory.enemy != 0) {
             if let player = firstBody.node as? Player, let enemy = secondBody.node as? Enemy {
                 playerDidHitEnemy(player: player, enemy: enemy)
                 // Crash sound?
                 SoundManager.shared.playExplosion(scene: self)
                 createExplosion(at: enemy.position)
             }
        }
        
        // EnemyLaser hits Player
        if (firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
           (secondBody.categoryBitMask & PhysicsCategory.enemyLaser != 0) {
             if let player = firstBody.node as? Player, let laser = secondBody.node as? EnemyLaser {
                 laser.removeFromParent()
                 handlePlayerDamage()
                 let flash = SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)])
                 player.run(flash)
             }
        }
    }
    
    func laserDidHitEnemy(laser: SKNode, enemy: Enemy) {
        laser.removeFromParent()
        
        // Calculate Damage
        let baseDmg = 4.0
        let multiplier = UpgradeManager.shared.damageMultiplier
        let damage = Int(baseDmg * multiplier)
        
        enemy.takeDamage(damage)
        enemy.takeDamage(damage)
        if enemy.hp <= 0 {
             let wasBoss = (enemy is Boss)
             
             enemy.removeFromParent()
             UpgradeManager.shared.enemyKilled()
             scoreLabel.text = "KILLS: \(UpgradeManager.shared.kills)"
             SoundManager.shared.playExplosion(scene: self)
             createExplosion(at: enemy.position)
             
             // Check/Update Regen
             player.updateBar(current: UpgradeManager.shared.energy, maxVal: UpgradeManager.shared.maxEnergy)
             
             if wasBoss {
                 isBossActive = false
                 // Boss Loot?
                 spawnPowerUp()
                 spawnPowerUp()
                 spawnPowerUp() // Reward
             }
        }
    }
    
    func playerDidHitEnemy(player: Player, enemy: Enemy) {
        enemy.removeFromParent()
        handlePlayerDamage() // Handles crash damage
    }
    
    func handlePlayerDamage() {
        let alive = UpgradeManager.shared.takeDamage()
        
        // Update Player Bar
        player.updateBar(current: UpgradeManager.shared.energy, maxVal: UpgradeManager.shared.maxEnergy)
        
        let flash = SKAction.sequence([SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1), SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.1)])
        player.run(flash) // Player runs it, not self, because it's color blend on sprite
        
        if !alive && !isGameOver {
            isGameOver = true
            gameOver()
        }
    }
    
    func spawnBoss(index: Int) {
        isBossActive = true
        
        // Warning Sound/Effect
        let label = SKLabelNode(fontNamed: "Courier-Bold")
        label.text = "BOSS INCOMING!"
        label.fontSize = 40
        label.fontColor = .red
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        label.zPosition = 100
        addChild(label)
        label.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.5), SKAction.wait(forDuration: 2.0), SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
        
        SoundManager.shared.playBossIncoming(scene: self) // Alert sound
        
        // Pass index directly (e.g. 1 for 50 kills, 2 for 100 kills)
        let boss = Boss(level: index) 
        boss.position = CGPoint(x: size.width / 2, y: size.height + 150)
        addChild(boss)
        
        // Enter Arena
        let moveIn = SKAction.moveTo(y: size.height * 0.8, duration: 4.0)
        boss.run(moveIn)
    }

    func gameOver() {
        print("Game Over")
        isUserInteractionEnabled = false
        removeAllActions()
        physicsWorld.speed = 0
        player?.removeFromParent()

        let currentKills = UpgradeManager.shared.kills
        
        // Save Last Score
        UserDefaults.standard.set(currentKills, forKey: "LastScore")
        
        let savedHigh = UserDefaults.standard.integer(forKey: "HighScore")
        if currentKills > savedHigh {
            UserDefaults.standard.set(currentKills, forKey: "HighScore")
        }
        
        GameCenterManager.shared.submitScore(score: currentKills)

        let wait = SKAction.wait(forDuration: 1.0)
        let presentMenu = SKAction.run { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let view = self.view else { return }
                let transition = SKTransition.crossFade(withDuration: 1.0)
                let menuScene = MenuScene(size: self.size)
                menuScene.scaleMode = .aspectFill
                view.presentScene(menuScene, transition: transition)
            }
        }
        run(SKAction.sequence([wait, presentMenu]))
    }
    
    func setupHUD() {
        scoreLabel = SKLabelNode(fontNamed: "Courier-Bold")
        scoreLabel.text = "KILLS: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(scoreLabel)
        
        // Lives Label Removed (Replaced by Bar on Player)
    }
    
    // updateLivesUI removed
    
    // MARK: - Touch Handling (iOS Only)
    #if canImport(UIKit)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard activeTouch == nil, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Allow control from ANYWHERE on screen
        activeTouch = touch
        let playerPoint = player.position
        touchOffsetFromPlayer = CGPoint(x: location.x - playerPoint.x, y: location.y - playerPoint.y)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = activeTouch, touches.contains(touch) else { return }
        let location = touch.location(in: self)
        var newPos = CGPoint(x: location.x - touchOffsetFromPlayer.x, y: location.y - touchOffsetFromPlayer.y)
        // Clamp to scene bounds with some padding
        let halfW = player.size.width / 2
        let halfH = player.size.height / 2
        newPos.x = max(halfW, min(size.width - halfW, newPos.x))
        newPos.y = max(halfH, min(size.height - halfH, newPos.y))
        player.position = newPos
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = activeTouch, touches.contains(touch) {
            activeTouch = nil
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = activeTouch, touches.contains(touch) {
            activeTouch = nil
        }
    }
    #endif
    
    // MARK: - Visual Effects
    func createExplosion(at position: CGPoint) {
        // Pixel Explosion: Spawn 10-15 small squares extending outwards
        for _ in 0...12 {
            let debris = SKShapeNode(rectOf: CGSize(width: 4, height: 4))
            debris.fillColor = Bool.random() ? .orange : .red
            debris.strokeColor = .clear
            debris.position = position
            addChild(debris)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 50...150)
            let dx = cos(angle) * speed
            let dy = sin(angle) * speed
            
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let group = SKAction.group([move, fade])
            let remove = SKAction.removeFromParent()
            debris.run(SKAction.sequence([group, remove]))
        }
    }

    // MARK: - WatchOS Support
    // Called by WatchContentView
    func movePlayerByCrown(offset: CGFloat) {
        guard let player = player else { return }
        
        // Offset is usually small per frame (e.g., -5.0 to +5.0)
        // Sensitivity adjustment
        let sensitivity: CGFloat = 10.0 
        let delta = offset * sensitivity
        
        var newX = player.position.x + delta
        
        // Clamp
        let halfW = player.size.width / 2
        newX = max(halfW, min(size.width - halfW, newX))
        
        player.position.x = newX
    }
}

