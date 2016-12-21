//
//  GameViewController.swift
//  SwirlGame
//
//  Created by Techjini on 12/12/16.
//  Copyright © 2016 Techjini. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var scene: GameScene!
    
    var level: Level!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Load the level.
        level = Level(filename: "Level_0")
        scene.level = level
        
        scene.addTiles()
        
        scene.showAlertAction = {[weak self] Void in
            //Show Alert
            let alertController = UIAlertController(title: "Alert", message: "Are you want to restart the game?", preferredStyle: .alert)
            let okAlertAction = UIAlertAction(title: "Yes", style: .default, handler: { action  in
                self?.scene.swirlsLayer.removeAllChildren()
                self?.shuffle()
            })
            let cancelAlertAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(cancelAlertAction)
            alertController.addAction(okAlertAction)
            self?.present(alertController, animated: true, completion: nil)
        }
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Start the game.
        beginGame()
    
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Game functions
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        // Fill up the level with new swirl, and create sprites for them.
        let newSwirl = level.shuffle()
        scene.addSprites(for: newSwirl)
    }
    
    
    func beginNextTurn() {
       // level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
    }

}
