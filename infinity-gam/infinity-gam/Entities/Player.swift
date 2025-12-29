import SpriteKit

class Player: SKSpriteNode {
    
    var fireTimer: TimeInterval = 0
    var fireRate: TimeInterval = 0.5
    init() {
        _ = SKTexture(imageNamed: "player") // Should be a white square if image missing
        let color = SKColor.white
        let size = CGSize(width: 50, height: 50)
        
        super.init(texture: nil, color: color, size: size) // Procedural square
        
        self.name = "player"
        
        // Physics
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.enemy
        self.physicsBody?.collisionBitMask = 0 // Do not bounce
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        // Visual
        addRetroLook()
        setupHealthBar()
    }
    
    private var healthBarFg: SKShapeNode?
    
    func setupHealthBar() {
         let width: CGFloat = 40
         let height: CGFloat = 4
         let yOffset: CGFloat = -45
        
         // BG (Centered)
         let bg = SKShapeNode(rectOf: CGSize(width: width, height: height))
         bg.fillColor = UIColor.red.withAlphaComponent(0.5)
         bg.strokeColor = .clear
         bg.position = CGPoint(x: 0, y: yOffset)
         addChild(bg)
        
         // FG - Anchor Left
         let rect = CGRect(x: 0, y: -height/2, width: width, height: height)
         let fg = SKShapeNode(rect: rect)
         fg.fillColor = .green
         fg.strokeColor = .clear
         fg.position = CGPoint(x: -width/2, y: yOffset) // Pos at left edge
         fg.zPosition = 11
         addChild(fg)
         self.healthBarFg = fg
    }
    
    func updateBar(current: Int, maxVal: Int) {
        guard let fg = healthBarFg else { return }
        let pct = max(0, CGFloat(current) / CGFloat(maxVal))
        fg.xScale = pct
        
        // Color transition
        if pct > 0.5 { fg.fillColor = .green }
        else if pct > 0.2 { fg.fillColor = .yellow }
        else { fg.fillColor = .red }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addRetroLook() {
        // Clear any existing children (if reapplying look)
        self.removeAllChildren()
        self.color = .clear

        let selectedShip = UserDefaults.standard.integer(forKey: "SelectedShip")
        
        switch selectedShip {
        case 1: // VIPER (Triangle - Fast Look)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 25))
            path.addLine(to: CGPoint(x: 20, y: -20))
            path.addLine(to: CGPoint(x: 0, y: -10))
            path.addLine(to: CGPoint(x: -20, y: -20))
            path.closeSubpath()
            
            // Wings details
            let wingL = SKShapeNode(rectOf: CGSize(width: 4, height: 16))
            wingL.position = CGPoint(x: -18, y: -18)
            wingL.fillColor = .cyan
            
            let wingR = SKShapeNode(rectOf: CGSize(width: 4, height: 16))
            wingR.position = CGPoint(x: 18, y: -18)
            wingR.fillColor = .cyan
            
            let body = SKShapeNode(path: path)
            body.fillColor = .white
            body.strokeColor = .clear
            
            addChild(body)
            addChild(wingL)
            addChild(wingR)
            
        case 2: // HEAVY (Tank - Bulky Look)
            // Main Block
            let body = SKShapeNode(rectOf: CGSize(width: 30, height: 40), cornerRadius: 4)
            body.fillColor = .lightGray
            body.strokeColor = .white
            body.lineWidth = 2
            
            // Side Cannons
            let cannonL = SKShapeNode(rectOf: CGSize(width: 8, height: 30))
            cannonL.position = CGPoint(x: -22, y: -5)
            cannonL.fillColor = .gray
            
            let cannonR = SKShapeNode(rectOf: CGSize(width: 8, height: 30))
            cannonR.position = CGPoint(x: 22, y: -5)
            cannonR.fillColor = .gray
            
            // Cockpit
            let cockpit = SKShapeNode(rectOf: CGSize(width: 14, height: 10))
            cockpit.position = CGPoint(x: 0, y: 5)
            cockpit.fillColor = .cyan
            
            addChild(cannonL)
            addChild(cannonR)
            addChild(body)
            addChild(cockpit)
            
        default: // CLASSIC (Enterprise - Saucer Look)
            // Saucer (primary hull): an ellipse
            let saucerRect = CGRect(x: -28, y: -12, width: 56, height: 36)
            let saucerPath = CGPath(ellipseIn: saucerRect, transform: nil)
            let saucer = SKShapeNode(path: saucerPath)
            saucer.fillColor = .white
            saucer.strokeColor = .clear
            addChild(saucer)

            // Bridge dome on top of saucer
            let bridgeRect = CGRect(x: -6, y: 16, width: 12, height: 8)
            let bridgePath = CGPath(ellipseIn: bridgeRect, transform: nil)
            let bridge = SKShapeNode(path: bridgePath)
            bridge.fillColor = .white
            bridge.strokeColor = .clear
            addChild(bridge)

            // Neck connecting to secondary hull
            let neck = SKShapeNode(rectOf: CGSize(width: 8, height: 18), cornerRadius: 3)
            neck.position = CGPoint(x: 0, y: -8)
            neck.fillColor = .white
            neck.strokeColor = .clear
            addChild(neck)

            // Secondary hull (engineering hull): a rounded rectangle
            let hull = SKShapeNode(rectOf: CGSize(width: 20, height: 40), cornerRadius: 6)
            hull.position = CGPoint(x: 0, y: -28)
            hull.fillColor = .white
            hull.strokeColor = .clear
            addChild(hull)

            // Nacelle pylons (left/right)
            let pylonLeft = SKShapeNode(rectOf: CGSize(width: 6, height: 18), cornerRadius: 3)
            pylonLeft.position = CGPoint(x: -18, y: -18)
            pylonLeft.fillColor = .white
            pylonLeft.strokeColor = .clear
            addChild(pylonLeft)

            let pylonRight = SKShapeNode(rectOf: CGSize(width: 6, height: 18), cornerRadius: 3)
            pylonRight.position = CGPoint(x: 18, y: -18)
            pylonRight.fillColor = .white
            pylonRight.strokeColor = .clear
            addChild(pylonRight)

            // Nacelles (warp engines): rounded rectangles left/right
            let nacelleLeft = SKShapeNode(rectOf: CGSize(width: 12, height: 42), cornerRadius: 6)
            nacelleLeft.position = CGPoint(x: -26, y: -32)
            nacelleLeft.fillColor = .white
            nacelleLeft.strokeColor = .clear
            addChild(nacelleLeft)

            let nacelleRight = SKShapeNode(rectOf: CGSize(width: 12, height: 42), cornerRadius: 6)
            nacelleRight.position = CGPoint(x: 26, y: -32)
            nacelleRight.fillColor = .white
            nacelleRight.strokeColor = .clear
            addChild(nacelleRight)
        }
    }
    
    func update(dt: TimeInterval) {
        fireTimer += dt
        
        let currentFireRate = UpgradeManager.shared.currentFireRate()
        
        if fireTimer >= currentFireRate {
            fireTimer = 0
            fire()
        }
    }
    
    func fire() {
        guard let scene = self.scene else { return }
        
        // Audio
        SoundManager.shared.playShoot(scene: scene)
        
        // Visual Feedback: Flash ship
        let flashOut = SKAction.fadeAlpha(to: 0.5, duration: 0.05)
        let flashIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        self.run(SKAction.sequence([flashOut, flashIn]))
        
        let weaponLevel = UpgradeManager.shared.weaponLevel
        
        // Fire Logic
        if weaponLevel >= 3 {
             // Level 3+ (Triple Fan)
             createLaser(at: self.position, scene: scene, level: 3)
             createLaser(at: self.position, scene: scene, level: 3, angle: -0.2)
             createLaser(at: self.position, scene: scene, level: 3, angle: 0.2)
        } else if weaponLevel == 2 {
            // Double Shot (Left/Right)
            createLaser(at: CGPoint(x: self.position.x - 15, y: self.position.y), scene: scene, level: 2)
            createLaser(at: CGPoint(x: self.position.x + 15, y: self.position.y), scene: scene, level: 2)
        } else {
            // Single
            createLaser(at: self.position, scene: scene, level: 1)
        }
        
        // Additive Mega Laser
        if UpgradeManager.shared.megaLaserTimer > 0 {
             createLaser(at: self.position, scene: scene, level: 99)
        }
        
        // Missiles
        if UpgradeManager.shared.hasMissiles {
            spawnMissile(scene: scene)
        }
    }
    
    func spawnMissile(scene: SKScene) {
        let missile = Missile()
        missile.position = self.position
        
        // Find nearest enemy
        var nearestEnemy: SKNode?
        var minDist: CGFloat = 99999
        scene.enumerateChildNodes(withName: "enemy") { node, _ in
            let dist = hypot(node.position.x - self.position.x, node.position.y - self.position.y)
            if dist < minDist {
                minDist = dist
                nearestEnemy = node
            }
        }
        missile.target = nearestEnemy
        scene.addChild(missile)
        
        let wait = SKAction.wait(forDuration: 3.0)
        let remove = SKAction.removeFromParent()
        missile.run(SKAction.sequence([wait, remove]))
    }
    
    // Re-writing fire() completely to support modes
    func fireParameters() {
         // Placeholder removed
    }
    
    func createLaser(at position: CGPoint, scene: SKScene, level: Int, angle: CGFloat = 0) {
        let laser = Laser()
        // Style by weapon level
        switch level {
        case 1:
            laser.color = .green // Classic retro
            laser.size = CGSize(width: 4, height: 20)
        case 2:
            laser.color = .cyan
            laser.size = CGSize(width: 5, height: 25)
        case 99: // Mega Laser
            laser.color = .blue
            laser.size = CGSize(width: 20, height: 80) // BIG
        default: // 3+
            laser.color = .yellow
            laser.size = CGSize(width: 6, height: 30)
        }
        
        laser.position = position
        laser.position.y += 30
        
        // Rotate laser if angle is significant
        if angle != 0 {
            laser.zRotation = -angle
        }
        
        // Add glow effect (child node)
        let glow = SKShapeNode(circleOfRadius: laser.size.width * 1.5)
        glow.fillColor = laser.color
        glow.alpha = 0.3
        glow.strokeColor = .clear
        glow.zPosition = -1
        laser.addChild(glow)
        
        scene.addChild(laser)
        
        // Movement based on angle
        let distance: CGFloat = 1000
        let dx = distance * sin(-angle) // Negative angle for SpriteKit rotation correction? logic: 0 is up? 
        // Standard Unit Circle: 0 is Right. 
        // SpriteKit: by default nodes face Right (0). 
        // But our laser texture is vertical? Or we assume Up is movement direction?
        // Laser moves Up usually. 
        // Let's assume Angle 0 = Up. 
        // dx = dist * sin(angle)
        // dy = dist * cos(angle)
        
        let moveAction: SKAction
        if angle == 0 {
             moveAction = SKAction.moveBy(x: 0, y: distance, duration: 0.6)
        } else {
             let dx = distance * sin(-angle)
             let dy = distance * cos(angle)
             moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.6)
        }

        let remove = SKAction.removeFromParent()
        laser.run(SKAction.sequence([moveAction, remove]))
    }
}

