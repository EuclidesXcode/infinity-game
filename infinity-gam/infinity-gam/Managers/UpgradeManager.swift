import Foundation

class UpgradeManager {
    static let shared = UpgradeManager()
    
    var kills: Int = 0
    var powerUpsCollected: Int = 0
    
    // Scaled Energy: 100 internal = 10 visual.
    var energy: Int = 100
    let maxEnergy: Int = 100
    var enemiesKilledForRegen: Int = 0
    
    var megaLaserTimer: TimeInterval = 0
    
    var damageMultiplier: Double {
        // Base increase: 5% per 5 powerups
        let base = 1.0 + (Double(powerUpsCollected / 5) * 0.05)
        if megaLaserTimer > 0 { return base * 5.0 } // Mega Laser = 5x Damage
        return base
    }
    
    // Weapon Levels
    var weaponLevel: Int {
        if powerUpsCollected >= 10 { return 3 } // Triple
        if powerUpsCollected >= 3 { return 2 } // Double
        return 1
    }
    
    private init() {}
    
    func enemyKilled() {
        kills += 1
        
        // Regen Logic: 1 Visual Point (10 internal) per 5 Kills
        enemiesKilledForRegen += 1
        if enemiesKilledForRegen >= 5 {
            enemiesKilledForRegen = 0
            if energy < maxEnergy {
                energy = min(maxEnergy, energy + 10)
            }
        }
    }
    
    func powerUpCollected() {
        powerUpsCollected += 1
    }
    
    func checkUpgrades() {
        // Debug/Validation only
        if powerUpsCollected > 0 && powerUpsCollected % 5 == 0 {
             print("Damage Increased! New Multiplier: \(damageMultiplier)")
        }
    }
    
    var hasMissiles: Bool {
        return powerUpsCollected >= 15 
    }
    
    // DPS Calculation
    func calculatePossibleDamage(duration: TimeInterval) -> Int {
        let damagePerShot = 2.0 * damageMultiplier
        let shotsPerSecond = 2.0 // Based on FireRate 0.5
        let projectiles = Double(weaponLevel)
        let dps = damagePerShot * shotsPerSecond * projectiles
        return Int(dps * duration)
    }
    
    func currentFireRate() -> TimeInterval {
        let baseRate: TimeInterval = 0.5
        let reduction = 0.02 * Double(powerUpsCollected)
        let minRate: TimeInterval = 0.18
        return max(minRate, baseRate - reduction)
    }
    
    // Returns true if player is still alive
    func takeDamage(amount: Int = 12) -> Bool {
        energy -= amount
        return energy > 0
    }
    
    func reset() {
        kills = 0
        powerUpsCollected = 0
        energy = 100
        enemiesKilledForRegen = 0
        megaLaserTimer = 0
    }
    
    func update(dt: TimeInterval) {
        if megaLaserTimer > 0 {
            megaLaserTimer -= dt
        }
    }
    
    func activateMegaLaser() {
        megaLaserTimer = 10.0 // 10 seconds of destruction
    }
}
