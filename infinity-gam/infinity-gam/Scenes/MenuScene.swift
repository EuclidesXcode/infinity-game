import SpriteKit

class MenuScene: SKScene {
    
    var backgroundLayer1: SKNode!
    var backgroundLayer2: SKNode!
    
    var shipNodes: [SKShapeNode] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        setupTitle()
        setupHighScore()
        setupShipSelection()
        setupStartButton()
        setupStarfield()
        
        // Apply retro shader to menu as well
        self.shader = SKShader(fileNamed: "RetroShader")
        self.shouldEnableEffects = true
        
        // Start Music
        SoundManager.shared.startBackgroundMusic()
    }
    
    func setupTitle() {
        let titleLabel = SKLabelNode(fontNamed: "Courier-Bold")
        titleLabel.text = "INFINITY RETRO"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.8) // Moved Up
        addChild(titleLabel)
        
        let subLabel = SKLabelNode(fontNamed: "Courier")
        subLabel.text = "SHOOTER"
        subLabel.fontSize = 30
        subLabel.fontColor = .lightGray
        subLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75) // Moved Up
        addChild(subLabel)
    }
    
    func setupHighScore() {
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        let lastScore = UserDefaults.standard.integer(forKey: "LastScore")
        
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.text = "RECORD: \(highScore)"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .yellow
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.9)
        addChild(scoreLabel)
        
        let lastScoreLabel = SKLabelNode(fontNamed: "Courier")
        lastScoreLabel.text = "LAST: \(lastScore)"
        lastScoreLabel.fontSize = 20
        lastScoreLabel.fontColor = .white
        lastScoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.86) // Below Record
        addChild(lastScoreLabel)
    }
    
    func setupStartButton() {
        let startLabel = SKLabelNode(fontNamed: "Courier-Bold")
        startLabel.text = "[ START GAME ]"
        startLabel.fontSize = 32
        startLabel.fontColor = .green
        startLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.25) // Moved Down well below ships
        startLabel.name = "startButton"
        addChild(startLabel)
        
        let gcLabel = SKLabelNode(fontNamed: "Courier-Bold")
        gcLabel.text = "[ LEADERBOARD ]"
        gcLabel.fontSize = 24
        gcLabel.fontColor = .cyan
        gcLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.15) // Moved Down
        gcLabel.name = "gcButton"
        addChild(gcLabel)
        
        // Pulse animation
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        startLabel.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn])))
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
    
    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval = 1.0 / 60.0
        updateStarfield(dt: dt)
    }
    
    func setupShipSelection() {
        let label = SKLabelNode(fontNamed: "Courier")
        label.text = "SELECT SHIP"
        label.fontSize = 20
        label.fontColor = .cyan
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        addChild(label)
        
        let currentSelection = UserDefaults.standard.integer(forKey: "SelectedShip")
        
        let spacing: CGFloat = 80
        let startX = size.width / 2 - spacing
        
        for i in 0...2 {
            let node = SKShapeNode(rectOf: CGSize(width: 40, height: 40), cornerRadius: 4)
            node.position = CGPoint(x: startX + (CGFloat(i) * spacing), y: size.height * 0.48)
            node.lineWidth = 2
            node.name = "ship_\(i)"
            
            // Highlight selected
            if i == currentSelection {
                node.strokeColor = .green
                node.fillColor = SKColor.green.withAlphaComponent(0.3)
            } else {
                node.strokeColor = .white
                node.fillColor = .clear
            }
            
            // Add mini visual inside
            let visual = createMiniShipVisual(type: i)
            visual.position = CGPoint(x: 0, y: 0)
            node.addChild(visual)
            
            addChild(node)
            shipNodes.append(node)
        }
    }
    
    func createMiniShipVisual(type: Int) -> SKShapeNode {
        let path = CGMutablePath()
        switch type {
        case 1: // Viper (Triangle)
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: 10, y: -10))
            path.addLine(to: CGPoint(x: 0, y: -5))
            path.addLine(to: CGPoint(x: -10, y: -10))
            path.closeSubpath()
        case 2: // Bomber (Square/Bulk)
            path.addRect(CGRect(x: -12, y: -12, width: 24, height: 24))
            path.addRect(CGRect(x: -16, y: -8, width: 4, height: 16)) // Wings
            path.addRect(CGRect(x: 12, y: -8, width: 4, height: 16))
        default: // Enterprise (Saucer)
            path.addEllipse(in: CGRect(x: -12, y: -8, width: 24, height: 16))
            path.addRect(CGRect(x: -4, y: -15, width: 8, height: 8))
        }
        
        let shape = SKShapeNode(path: path)
        shape.fillColor = .white
        shape.strokeColor = .clear
        return shape
    }
    
    func updateSelection(index: Int) {
        UserDefaults.standard.set(index, forKey: "SelectedShip")
        
        for (i, node) in shipNodes.enumerated() {
            if i == index {
                node.strokeColor = .green
                node.fillColor = SKColor.green.withAlphaComponent(0.3)
                // Pulse effect
                let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
                node.run(SKAction.sequence([scaleUp, scaleDown]))
            } else {
                node.strokeColor = .white
                node.fillColor = .clear
            }
        }
        
        SoundManager.shared.playShoot(scene: self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            // Check ship selection
            if let name = node.name, name.starts(with: "ship_") {
                if let index = Int(name.components(separatedBy: "_").last ?? "0") {
                    updateSelection(index: index)
                }
            } else if let parentName = node.parent?.name, parentName.starts(with: "ship_") {
                 if let index = Int(parentName.components(separatedBy: "_").last ?? "0") {
                    updateSelection(index: index)
                }
            }
            
            if node.name == "startButton" {
                startGame()
            }
            
            if node.name == "gcButton" {
                SoundManager.shared.playShoot(scene: self)
                GameCenterManager.shared.showLeaderboard()
            }
        }
    }
    


    
    func startGame() {
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 1.0)
        view?.presentScene(scene, transition: transition)
    }
}
