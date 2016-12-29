//
//  GameScene.swift
//  SwirlGame
//
//  Created by Techjini on 12/12/16.
//  Copyright © 2016 Techjini. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
   
    // MARK: Properties
    
    // This is marked as ! because it will not initially have a value, but pretty
    // soon after the GameScene is created it will be given a Level object, and
    // from then on it will always have one (it will never be nil again).
    var level: Level!
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let swirlsLayer = SKNode()
    let tilesLayer = SKNode()
    let newGameButton = SKSpriteNode(imageNamed: "NewGame")
    var previousMatches = Set<Chain>()
    
    // Sprite that is drawn on top of the swirl that the player is trying to swap.
    var selectionSprites = [SKSpriteNode]()
    var showAlertAction: ((Void) -> Void)?
    
    var levelTimerLabel = SKLabelNode(fontNamed: "ArialMT")
    
    //Immediately after leveTimerValue variable is set, update label's text
    var levelTimerValue: Int = 120 {
        didSet {
            levelTimerLabel.text = "Time left: \(levelTimerValue)"
        }
    }

    // MARK: Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        // Put an image on the background. Because the scene's anchorPoint is
        // (0.5, 0.5), the background image will always be centered on the screen.
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        addChild(background)
        
        newGameButton.size = CGSize(width: 100, height: 40)
        newGameButton.position = CGPoint(x: (frame.width - newGameButton.size.width)/2 , y: (frame.height - newGameButton.size.height)/2)
        newGameButton.name = "newGame"
        addChild(newGameButton)
        
        createlevelTimer()
        
        // Add a new node that is the container for all other layers on the playing
        // field. This gameLayer is also centered in the screen.
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        // The tiles layer represents the shape of the level. It contains a sprite
        // node for each square that is filled in.
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        // This layer holds the Cookie sprites. The positions of these sprites
        // are relative to the SwirlLayer's bottom-left corner.
        swirlsLayer.position = layerPosition
        gameLayer.addChild(swirlsLayer)
    }
    

    
    
    func createlevelTimer() {
        levelTimerLabel.fontColor = SKColor.white
        levelTimerLabel.fontSize = 24
        levelTimerLabel.position = CGPoint(x: 0, y: frame.size.height / 3)
        levelTimerLabel.text = "Time left: \(levelTimerValue)"
        addChild(levelTimerLabel)
        
        let wait = SKAction.wait(forDuration: 0.5) //change countdown speed here
        let block = SKAction.run({
            [unowned self] in
            
            if self.levelTimerValue > 0{
                self.levelTimerValue -= 1
            }else{
                self.removeAction(forKey: "countdown")
            }
        })
        let sequence = SKAction.sequence([wait,block])
        
        run(SKAction.repeatForever(sequence), withKey: "countdown")
    }
    
    
    // MARK: Level Setup
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                // If there is a tile at this position, then create a new tile
                // sprite and add it to the mask layer.
                if level.tileAt(column: column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointFor(column: column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func addSprites(for swirls: Set<Swirl>) {
        for swirl in swirls {
            // Create a new sprite for the cookie and add it to the swirlsLayer.
            let sprite = SKSpriteNode(imageNamed: swirl.swirlType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointFor(column: swirl.column, row: swirl.row)
            swirlsLayer.addChild(sprite)
            swirl.sprite = sprite
        }
    }
    
    
    // MARK: Point conversion
    
    // Converts a column,row pair into a CGPoint that is relative to the swirlLayer.
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self) ?? CGPoint.zero
        let node = self.atPoint(location)
        
        // If next button is touched, start transition to second scene
        if node.name == "newGame" {
            
            createlevelTimer()
           showAlertAction?()
        }
        
        // If the touch is inside a square, then this might be the start of a
        let swirlLocation = touches.first?.location(in: swirlsLayer) ?? CGPoint.zero
        // swipe motion.
        let (success, column, row) = convertPoint(swirlLocation)
        if success {
            // The touch must be on a cookie, not on an empty tile.
            if let swirl = level.swirlAt(column: column, row: row) {
                handleMatches(swirl: swirl)
            }
        }
    }
    
    
    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        // Is this a valid location within the Swirl layer? If yes,
        // calculate the corresponding row and column numbers.
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func showSelectionIndicator(for swirls: [Swirl]) {
         _ = selectionSprites.map({
            if  $0.parent != nil {
                $0.removeFromParent()
            }
        })
        selectionSprites.removeAll()
        
        
        for swirl in swirls {
        if let sprite = swirl.sprite {
            let selectionSprite = SKSpriteNode()
            let texture = SKTexture(imageNamed: swirl.swirlType.highlightedSpriteName)
            selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
            let shake = SKAction.shake(duration: 10.0)
            selectionSprite.run(shake)
            selectionSprite.run(SKAction.setTexture(texture))
            sprite.addChild(selectionSprite)
            selectionSprites.append(selectionSprite)
            selectionSprite.alpha = 1.0
        }
        }
    }
    
    func animateMatchedSwirl(for chains: Set<Chain>, completion: @escaping () -> ()) {
        for chain in chains {
            for swirl in chain.swirls {
                
                if let sprite = swirl.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                   withKey:"removing")
                    }
                }
            }
        }
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateFallingSwirlFor(columns: [[Swirl]], completion: @escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (idx, swirl) in array.enumerated() {
                let newPosition = pointFor(column: swirl.column, row: swirl.row)
                
                // The further away from the hole you are, the bigger the delay
                // on the animation.
                let delay = 0.05 + 0.15*TimeInterval(idx)
                
                let sprite = swirl.sprite!   // sprite always exists at this point
                
                // Calculate duration based on far cookie has to fall (0.1 seconds
                // per tile).
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                sprite.position = newPosition
                longestDuration = max(longestDuration, duration + delay)
                
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay)]))
            }
        }
        
        // Wait until all the Swirl have fallen down before we continue.
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateHorizontalSwirlFor(columns: [[Swirl]], completion: @escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (_ , swirl) in array.enumerated() {
                let newPosition = pointFor(column: swirl.column, row: swirl.row)
                
                // The further away from the hole you are, the bigger the delay
                // on the animation.
               // let delay = 0.05 + 0.15*TimeInterval(idx)
                
                let sprite = swirl.sprite!   // sprite always exists at this point
                
                // Calculate duration based on far cookie has to fall (0.1 seconds
                // per tile).
                //let duration = TimeInterval(((sprite.position.x - newPosition.x) / TileWidth) * 0.1)
                sprite.position = newPosition
                longestDuration = max(longestDuration, 0.01)
                let moveAction = SKAction.move(to: newPosition, duration: 0.01)
                moveAction.timingMode = .easeOut
                sprite.run(moveAction)
            }
        }
        
        // Wait until all the Swirl have fallen down before we continue.
       // run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    
    
    // This is the main loop that removes any matching Swirl and fills up the
    // holes with new Swirl. While this happens, the user cannot interact with
    // the app.
    func handleMatches(swirl: Swirl) {

        // Detect if there are any matches left.
        level.removeMatchSet = Set<Chain>()
        let matchSet = level.detectMatch(swirl: swirl)
        
        if !previousMatches.map({ Array($0.swirls) }).reduce([], +).contains(swirl) {
        previousMatches = matchSet
        showSelectionIndicator(for: matchSet.map({ Array($0.swirls) }).reduce([], +))
        return
        }
        
        previousMatches = level.removeMatches()
        
        // First, remove any matches...
        animateMatchedSwirl(for: previousMatches) {
            self.previousMatches.removeAll()
            // ...then shift down any Swirl that have a hole below them...
            let columns = self.level.fillHoles()
            let horizonatalHoles = self.level.fillRowsHorizontal()
            //let rows = self.level.fillRows()
            
            self.animateFallingSwirlFor(columns: columns) {
                self.animateHorizontalSwirlFor(columns: horizonatalHoles, completion: {
                })
                // Keep repeating this cycle until there are no more matches.
                //self.handleMatches()
            }
        }
    }

}

extension SKAction {
    class func shake(duration:CGFloat, amplitudeX:Int = 3, amplitudeY:Int = 3) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx, y:dy, duration: 0.015)
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
}
