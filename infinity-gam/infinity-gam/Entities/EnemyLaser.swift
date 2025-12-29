import SpriteKit

class EnemyLaser: SKSpriteNode {
    
    init(color: SKColor = .red, size: CGSize = CGSize(width: 4, height: 15)) {
        super.init(texture: nil, color: color, size: size)
        
        self.name = "enemyLaser"
        
        // Physics
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.enemyLaser
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
