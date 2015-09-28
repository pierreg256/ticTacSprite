//
//  GameScene.swift
//  ticTacSprite
//
//  Created by Pierre Gilot on 28/09/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Setup the board
        let boardNode = SKSpriteNode(imageNamed: "board")
        boardNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        let size = min(screenSize.width, screenSize.height)
        boardNode.size = CGSize(width:size, height:size)
        self.addChild(boardNode)
        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Tic Tac Toe";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            print(touchedNode)
            let sprite = SKSpriteNode(imageNamed:"x")
            
            //sprite.xScale = 0.5
            //sprite.yScale = 0.5
            let mySize = min(screenSize.width, screenSize.height) / 3
            sprite.size = CGSize(width:mySize, height:mySize)
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite) 
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
