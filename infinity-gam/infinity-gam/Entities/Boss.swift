import SpriteKit

class Boss: Enemy {
    
    var bossType: Int = 0
    
    var fireInterval: TimeInterval = 1.0
    
    init(level: Int) {
        // level passed is (kills / 50). So 1, 2, 3...
        // Visual Type loops every 10
        let bossIndex = (level - 1) % 10
        
        // Difficulty Scaling: 10% compounding per level
        // HP = 300 * (1.1 ^ (level-1))
        let difficultyMultiplier = pow(1.10, Double(level - 1))
        let bossHp = Int(300.0 * difficultyMultiplier)
        
        // Fire Rate: 10% faster per level (Interval * 0.9)
        // Cap minimum interval to avoid impossible spam (e.g., 0.2s)
        let rawInterval = 1.0 * pow(0.90, Double(level - 1))
        self.fireInterval = max(0.2, rawInterval)
        
        super.init(maxKillableHp: bossHp)
        
        self.bossType = bossIndex
        self.maxHp = bossHp
        self.hp = bossHp
        self.name = "boss"
        
        // Vary Boss Size based on type
        if bossType == 9 { // Final Boss
            self.size = CGSize(width: 160, height: 120) // Hugh Mungus
        } else {
            self.size = CGSize(width: 120, height: 100)
        }
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.player | GameScene.PhysicsCategory.laser | GameScene.PhysicsCategory.laser
        self.physicsBody?.collisionBitMask = 0
        
        addBossLook()
        addHealthBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addHealthBar() {
        super.addHealthBar() // remove old
        self.removeAllChildren() // clear children including old bar
        
        let barWidth: CGFloat = 100
        let barHeight: CGFloat = 10
        
        let bg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        bg.fillColor = UIColor.red.withAlphaComponent(0.5)
        bg.strokeColor = .clear
        bg.position = CGPoint(x: 0, y: 70)
        bg.zPosition = 10
        addChild(bg)
        
        // Anchor Left
        let rect = CGRect(x: -barWidth/2, y: -barHeight/2, width: barWidth, height: barHeight)
        let fg = SKShapeNode(rect: rect)
        fg.fillColor = .purple
        fg.strokeColor = .clear
        fg.position = CGPoint(x: 0, y: 70) 
        fg.zPosition = 11
        fg.name = "hpBar"
        addChild(fg)
        self.healthBar = fg
    }
    
    func addBossLook() {
        self.color = .clear
        var grid: [[Int]] = []
        var color: SKColor = .red
        
        // 10 Distinct Designs
        switch bossType {
        case 0: // The Wall (Orange)
            color = .orange
            grid = [
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                [1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1],
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                [0,1,1,1,0,0,0,1,1,0,0,0,1,1,1,0],
                [0,0,1,0,0,0,0,1,1,0,0,0,0,1,0,0]
            ]
        case 1: // The Eye (Magenta)
            color = .magenta
            grid = [
               [0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0],
               [0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0],
               [0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0],
               [0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,0],
               [0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,0],
               [0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
               [0,0,0,1,1,1,0,0,0,0,1,1,1,0,0,0]
            ]
        case 2: // The Wasp (Yellow)
            color = .yellow
            grid = [
                [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                [0,1,0,0,0,0,1,1,1,1,0,0,0,0,1,0],
                [0,0,1,0,0,1,1,1,1,1,1,0,0,1,0,0],
                [0,0,0,1,1,1,0,1,1,0,1,1,1,0,0,0],
                [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
                [0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0]
            ]
        case 3: // The Fortress (Green)
            color = .green
            grid = [
                [1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1],
                [1,1,1,1,0,0,0,1,1,0,0,0,1,1,1,1],
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0],
                [0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0]
            ]
        case 4: // Invader King (White)
            color = .white
            grid = [
                [0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0],
                [0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0],
                [0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
                [0,1,1,0,1,1,1,0,0,1,1,1,0,1,1,0],
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                [1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1],
                [1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1]
            ]
        case 5: // Phantom (Blue)
            color = .cyan
            grid = [
                [0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0],
                [0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0],
                [0,0,1,1,1,0,0,1,1,0,0,1,1,1,0,0],
                [0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0],
                [1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1],
                [1,0,0,1,1,1,0,0,0,0,1,1,1,0,0,1]
            ]
        case 6: // Twin Cannons (Red)
            color = .red
            grid = [
                [1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1],
                [1,0,0,0,1,1,1,1,1,1,1,1,0,0,0,1],
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                [0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0],
                [0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0]
            ]
        case 7: // The Skull (Light Gray)
            color = .lightGray
            grid = [
                [0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0],
                [0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0],
                [1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1],
                [1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1],
                [1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1],
                [0,1,1,1,0,0,1,0,1,0,0,1,1,1,0,0]
            ]
        case 8: // Core Processor (Blue/White)
             color = .blue
             grid = [
                [1,1,1,1,1,1,1,1],
                [1,0,0,0,0,0,0,1],
                [1,0,1,1,1,1,0,1],
                [1,0,1,1,1,1,0,1],
                [1,0,0,0,0,0,0,1],
                [1,1,1,1,1,1,1,1]
             ]
             // Scale this one up more in textureFromGrid? Or just rely on self.size
        default: // Omega (Dark Purple) - Case 9
             color = .purple
             grid = [
                [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                [0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,0],
                [0,0,1,0,0,0,1,1,1,1,0,0,0,1,0,0],
                [0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0],
                [0,0,0,0,1,1,0,1,1,0,1,1,0,0,0,0],
                [0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0],
                [0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0]
             ]
        }
        
        if let texture = textureFromGrid(grid, color: color) {
            self.texture = texture
        }
    }
    
    override func update(dt: TimeInterval) {
        // Boss Movement: Side to Side
        let sceneWidth = self.scene?.size.width ?? 0
        
        // Initial Impulse if needed
        if (self.physicsBody?.velocity.dx == 0) && sceneWidth > 0 {
             self.physicsBody?.velocity.dx = 150
        }
        
        // Bounce logic
        if self.position.x > sceneWidth * 0.9 {
            self.physicsBody?.velocity.dx = -150
        } else if self.position.x < sceneWidth * 0.1 {
            self.physicsBody?.velocity.dx = 150
        }
        
        // Complex Firing
        fireTimer += dt
        if fireTimer > self.fireInterval { // Use scaled interval
            fireTimer = 0
            bossFire()
        }
    }
    
    func bossFire() {
        guard let scene = self.scene else { return }
        
        var angles: [CGFloat] = []
        var color: SKColor = .red
        var size = CGSize(width: 4, height: 15)
        
        switch bossType {
        case 0: // Wall: 3 streams straight
            angles = [0, 0, 0] // logic below will separate positions? No, standard logic separates angles. 
            // Need new logic for parallel streams.
            simpleFire(scene: scene, color: .orange, width: 6, count: 5, spread: 0.2)
            return
            
        case 1: // Eye: Targeted single thick beam
            let laser = EnemyLaser(color: .magenta, size: CGSize(width: 15, height: 60))
            laser.position = CGPoint(x: self.position.x, y: self.position.y - 60)
            scene.addChild(laser)
            let move = SKAction.moveTo(y: -100, duration: 1.0) // FAST
            laser.run(SKAction.sequence([move, SKAction.removeFromParent()]))
            return
            
        case 2: // Wasp: V-Shape
             simpleFire(scene: scene, color: .yellow, width: 4, count: 3, spread: 0.5)
             return
             
        case 9: // Omega: Chaos
             simpleFire(scene: scene, color: .purple, width: 10, count: 7, spread: 0.8)
             return
             
        default: // Standard Fan
             simpleFire(scene: scene, color: .cyan, width: 5, count: 5, spread: 0.4)
             return
        }
    }
    
    func simpleFire(scene: SKScene, color: SKColor, width: CGFloat, count: Int, spread: CGFloat) {
         let startAngle = -spread
         let step = (spread * 2) / CGFloat(count - 1)
         
         for i in 0..<count {
             let angle = startAngle + (step * CGFloat(i))
             let laser = EnemyLaser(color: color, size: CGSize(width: width, height: 30))
             laser.position = CGPoint(x: self.position.x, y: self.position.y - 50)
             laser.zRotation = angle // Rotate visual too
             scene.addChild(laser)
             
             let dx = sin(angle) * 1000
             let dy = -1000.0 * cos(angle)
             
             let move = SKAction.moveBy(x: dx, y: dy, duration: 2.0)
             laser.run(SKAction.sequence([move, SKAction.removeFromParent()]))
         }
    }
}
