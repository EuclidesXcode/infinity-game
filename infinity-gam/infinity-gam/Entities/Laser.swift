import SpriteKit

class Laser: SKSpriteNode {
    
    init() {
        let size = CGSize(width: 4, height: 20)
        super.init(texture: nil, color: .white, size: size)
        
        self.name = "laser"
        
        // Physics
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.laser
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.enemy
        self.physicsBody?.collisionBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
