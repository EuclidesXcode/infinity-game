import SpriteKit

class Missile: SKSpriteNode {
    
    weak var target: SKNode?
    
    init() {
        let size = CGSize(width: 8, height: 20)
        super.init(texture: nil, color: .cyan, size: size)
        
        self.name = "missile"
        
        // Physics
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.laser // Treat as laser for collision logic
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.enemy
        self.physicsBody?.collisionBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: TimeInterval) {
        guard let target = target, target.parent != nil else {
            // No target, fly straight
            self.position.y += CGFloat(400 * dt)
            return
        }
        
        // Homing Logic
        let speed: CGFloat = 350.0
        let dx = target.position.x - self.position.x
        let dy = target.position.y - self.position.y
        let angle = atan2(dy, dx)
        
        // Simple easing towards target angle could be better but let's do direct velocity vector
        // Rotate sprite
        self.zRotation = angle - CGFloat.pi / 2
        
        let vx = cos(angle) * speed
        let vy = sin(angle) * speed
        
        self.position.x += vx * CGFloat(dt)
        self.position.y += vy * CGFloat(dt)
    }
}
