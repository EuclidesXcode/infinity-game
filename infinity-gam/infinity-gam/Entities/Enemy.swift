import SpriteKit

class Enemy: SKSpriteNode {
    
    var hp: Int = 1
    var maxHp: Int = 1
    var type: Int = 0
    var healthBar: SKShapeNode?
    
    // Custom Init based on difficulty cap
    // Custom Init based on difficulty cap
    init(maxKillableHp: Int) {
        // Decoupled Logic:
        // 1. Type is random (Visual Variety)
        // 2. HP is based on maxKillableHp input (Difficulty Control)
        
        // Random visual type (0 to 19)
        // We can weight it slightly if we want, but full random is best for "seeing other enemies"
        self.type = Int.random(in: 0...19)
        
        // Stats Logic
        // Use maxKillableHp directly for HP to control difficulty
        let baseHp = Double(maxKillableHp)
        
        // "Diminuir a vida dos inimigos em 30%" (0.7)
        // "Aumentar a energia dos inimigos em 20%" (1.2)
        // 0.7 * 1.2 = 0.84
        let finalHealth = max(1.0, baseHp * 0.84)
        
        self.maxHp = Int(finalHealth)
        self.hp = self.maxHp
        
        let size = CGSize(width: 40, height: 40)
        super.init(texture: nil, color: .white, size: size) 
        
        self.name = "enemy"
        
        // Physics
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.player | GameScene.PhysicsCategory.laser | GameScene.PhysicsCategory.laser // Missile is laser cat
        self.physicsBody?.collisionBitMask = 0
        
        addRetroLook()
        addHealthBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addHealthBar() {
        let barWidth: CGFloat = 40
        let barHeight: CGFloat = 4
        
        let bg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        bg.fillColor = .red
        bg.strokeColor = .clear
        bg.position = CGPoint(x: 0, y: 30)
        bg.zPosition = 10
        addChild(bg)
        
        let fg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
        fg.fillColor = .green
        fg.strokeColor = .clear
        fg.position = CGPoint(x: 0, y: 30) // Same pos, will scale x
        fg.zPosition = 11
        fg.name = "hpBar"
        addChild(fg)
        self.healthBar = fg
    }
    
    func updateHealthBar() {
        guard let bar = self.healthBar else { return }
        let pct = CGFloat(hp) / CGFloat(maxHp)
        bar.xScale = max(0, pct)
    }
    
    // Pixel Art Logic
    func addRetroLook() {
        self.removeAllChildren()
        addHealthBar() // Re-add health bar since we clear children
        
        let color: SKColor = .white
        
        // Define Patterns (1 = pixel, 0 = empty)
        // 11x8 Grids (roughly)
        var grid: [[Int]] = []
        
        if type <= 3 {
             // Crab-like
             grid = [
                [0,0,1,0,0,0,0,0,1,0,0],
                [0,0,0,1,0,0,0,1,0,0,0],
                [0,0,1,1,1,1,1,1,1,0,0],
                [0,1,1,0,1,1,1,0,1,1,0],
                [1,1,1,1,1,1,1,1,1,1,1],
                [1,0,1,1,1,1,1,1,1,0,1],
                [1,0,1,0,0,0,0,0,1,0,1],
                [0,0,0,1,1,0,1,1,0,0,0]
             ]
        } else if type <= 7 {
            // Squid-like
            grid = [
                [0,0,0,1,1,1,1,1,0,0,0],
                [0,0,1,1,1,1,1,1,1,0,0],
                [0,1,1,1,1,1,1,1,1,1,0],
                [0,1,0,1,1,1,1,1,0,1,0],
                [1,1,1,1,1,1,1,1,1,1,1],
                [0,0,1,0,1,0,1,0,1,0,0],
                [0,1,0,0,1,0,1,0,0,1,0],
                [0,0,1,0,0,0,0,0,1,0,0]
            ]
        } else if type <= 11 {
            // Octopus-like
            grid = [
                [0,0,0,0,1,1,1,0,0,0,0],
                [0,0,0,1,1,1,1,1,0,0,0],
                [0,0,1,1,1,1,1,1,1,0,0],
                [0,1,1,0,1,1,1,0,1,1,0],
                [1,1,1,1,1,1,1,1,1,1,1],
                [1,0,1,1,1,1,1,1,1,0,1],
                [1,0,1,0,0,0,0,0,1,0,1],
                [0,0,0,1,0,0,0,1,0,0,0]
            ]
        } else {
            // UFO / Tank
            grid = [
                [0,0,0,0,1,1,1,0,0,0,0],
                [0,0,0,1,1,1,1,1,0,0,0],
                [0,1,1,1,1,1,1,1,1,1,0],
                [1,1,0,1,1,1,1,1,0,1,1],
                [1,1,1,1,1,1,1,1,1,1,1],
                [0,0,1,0,1,0,1,0,1,0,0],
                [0,1,0,1,0,1,0,1,0,1,0],
                [1,0,1,0,0,0,0,0,1,0,1]
            ]
        }
        
        // Generate Texture from Grid
        if let texture = textureFromGrid(grid, color: color) {
            self.texture = texture
            self.size = CGSize(width: 44, height: 32) // Scale up slightly
        }
    }
    
    // Core Graphics Texture Generation
    func textureFromGrid(_ grid: [[Int]], color: SKColor) -> SKTexture? {
        let rows = grid.count
        let cols = grid[0].count
        let scale = 1 // Draw 1x1 pixels, sprite scales up
        
        let size = CGSize(width: cols * scale, height: rows * scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0) // 0 = device scale
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Context setup
        context.setFillColor(color.cgColor)
        context.setAllowsAntialiasing(false) // Hard pixels
        
        for (r, rowData) in grid.enumerated() {
            for (c, val) in rowData.enumerated() {
                if val == 1 {
                    // Coordinates: Core Graphics starts top-left usually for UIGraphics, 
                    // but we draw rects from top down as per grid
                    let rect = CGRect(x: c * scale, y: r * scale, width: scale, height: scale)
                    context.fill(rect)
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            let texture = SKTexture(image: image)
            texture.filteringMode = .nearest // Keep pixels script
            return texture
        }
        return nil
    }
    
    var fireTimer: TimeInterval = 0
    var fireRate: TimeInterval = 2.0
    
    func update(dt: TimeInterval) {
        // Shooting Logic
        if type >= 8 {
            fireTimer += dt
            if fireTimer >= fireRate {
                fireTimer = 0
                fireRate = Double.random(in: 1.5...3.0)
                fire()
            }
        }
    }
    
    func fire() {
        guard let scene = self.scene else { return }
        
        // Color based on type
        var laserColor: UIColor = .red
        if type > 15 { laserColor = .purple }
        else if type > 12 { laserColor = .orange }
        
        let laser = EnemyLaser(color: laserColor)
        laser.position = self.position
        laser.position.y -= 30
        scene.addChild(laser)
        
        // Shoot downwards FASTER (30% faster than previous 2.0s duration -> ~1.4s)
        let moveEnd = CGPoint(x: self.position.x, y: -100)
        let move = SKAction.move(to: moveEnd, duration: 1.4)
        let remove = SKAction.removeFromParent()
        laser.run(SKAction.sequence([move, remove]))
    }
    
    func takeDamage(_ amount: Int) {
        hp -= amount
        updateHealthBar()
        
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.05)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        self.run(SKAction.sequence([fadeOut, fadeIn]))
    }
}
