//
//  WatchContentView.swift
//  infinity-gam
//
//  INSTRUCTIONS:
//  1. Add this file to your 'Watch App' target.
//  2. Make sure GameScene.swift, Player.swift, etc., are also checked for the Watch App target.
//

import SwiftUI
import SpriteKit

#if os(watchOS)
struct WatchContentView: View {
    
    @State private var crownValue: Float = 0.0
    @State private var scene: GameScene?
    
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: setupScene(size: proxy.size))
                .focusable()
                .digitalCrownRotation($crownValue, from: -Double.infinity, through: Double.infinity, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
                .onChange(of: crownValue) { newValue in
                    // Calculate delta logic or absolute logic
                    // Here we assume delta based on change, but digitalCrownRotation gives absolute value by default if not reset.
                    // A better approach for continuous steering:
                    // We need the *difference* since last frame, or mapped position.
                    // For an infinite runner, mapped position (0...1) is hard because scrolling is infinite.
                    // Let's use the 'difference' hack.
                }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func setupScene(size: CGSize) -> SKScene {
        if let scene = scene { return scene }
        
        let newScene = GameScene(size: size)
        newScene.scaleMode = .aspectFill
        
        // Store reference to update via crown
        // Note: In SwiftUI, Views are structs (immutable). We need a class wrapper or strict ordering.
        // Actually, SpriteView keeps the scene alive.
        
        // Problem: 'onChange' is inside the Struct, needs to communicate with 'newScene'.
        // We can use a binding or reference.
        
        // Valid approach:
        self.scene = newScene // Error: modifying state during build? No.
        return newScene
    }
}

// IMPROVED VERSION WITH COORDINATOR
struct WatchGameView: View {
    @State private var crownOffset: CGFloat = 0.0
    // We use a small hacks: pass a closure or object to the scene?
    
    // Simplest approach: Use a wrapper class that holds the scene
    class SceneHolder: ObservableObject {
        var scene: GameScene
        init(size: CGSize) {
            scene = GameScene(size: size)
            scene.scaleMode = .aspectFill
        }
    }
    
    @StateObject var holder = SceneHolder(size: WKInterfaceDevice.current().screenBounds.size)
    
    var body: some View {
        SpriteView(scene: holder.scene)
            .focusable()
            .digitalCrownRotation($crownOffset, from: -99999, through: 99999, sensitivity: .high, isContinuous: true, isHapticFeedbackEnabled: true)
            .onChange(of: crownOffset) { oldValue, newValue in
                // Calculate delta
                let delta = newValue - oldValue
                holder.scene.movePlayerByCrown(offset: delta)
            }
            .ignoresSafeArea()
    }
}
#endif
