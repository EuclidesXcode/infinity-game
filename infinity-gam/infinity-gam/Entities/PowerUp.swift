import SpriteKit

class PowerUp: SKNode {
    
    var type: Int = 0 // 0 = Regular, 1 = Mega Laser
    
    // Convenience init to specify type
    convenience init(type: Int) {
        self.init()
        self.type = type
        setupVisuals()
    }
    
    override init() {
        super.init()
        self.name = "powerup"
        self.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = 0b10000 
        self.physicsBody?.contactTestBitMask = GameScene.PhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
        
        // Default visuals if convenience not used immediately
        setupVisuals()
    }
    
    func setupVisuals() {
        self.removeAllChildren()
        
        // Star shape
        let path = CGMutablePath()
        let points = 5
        let outerRadius: CGFloat = 15
        let innerRadius: CGFloat = 7
        
        let angleIncrement = CGFloat.pi * 2.0 / CGFloat(points * 2)
        var currentAngle: CGFloat = -CGFloat.pi / 2.0
        
        for i in 0..<(points * 2) {
            let radius = (i % 2 == 0) ? outerRadius : innerRadius
            let x = radius * cos(currentAngle)
            let y = radius * sin(currentAngle)
            
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
            
            currentAngle += angleIncrement
        }
        path.closeSubpath()
        
        let shape = SKShapeNode(path: path)
        shape.lineWidth = 2
        shape.strokeColor = .white
        
        // Color based on type
        if type == 1 {
            shape.fillColor = .blue
            // Pulse Action (Blue/Cyan)
            let toCyan = SKAction.run { shape.fillColor = .cyan }
            let toBlue = SKAction.run { shape.fillColor = .blue }
            let wait = SKAction.wait(forDuration: 0.1)
            let seq = SKAction.sequence([toCyan, wait, toBlue, wait])
            shape.run(SKAction.repeatForever(seq))
        } else {
            shape.fillColor = .yellow 
            // Blink Action (Green/Yellow)
            let toGreen = SKAction.run { shape.fillColor = .green }
            let toYellow = SKAction.run { shape.fillColor = .yellow }
            let wait = SKAction.wait(forDuration: 0.2)
            let seq = SKAction.sequence([toGreen, wait, toYellow, wait])
            shape.run(SKAction.repeatForever(seq))
        }
        
        addChild(shape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
