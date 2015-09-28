//
//  GameScene.swift
//  ticTacSprite
//
//  Created by Pierre Gilot on 28/09/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

import SpriteKit
import XCGLogger

class GameScene: SKScene {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let oTexture = SKTexture(imageNamed: "o")
    let xTexture = SKTexture(imageNamed: "x")
    
    let log = XCGLogger.defaultInstance()
    let board = BoardController()
    var currentUser = Player.X


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
        let shift = (screenSize.height - size) / 4
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) + size/2 + shift);
        self.addChild(myLabel)
        
        let btnSize = CGSize(width: boardNode.size.width/3, height: size/3)
        
        let btn1 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn1.name = "btn-1-1"
        btn1.position = CGPoint(x: 0, y: 0)
        boardNode.addChild(btn1)
        
        let btn2 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn2.name = "btn-1-0"
        btn2.position = CGPoint(x: btn1.position.x-btn1.size.width, y: btn1.position.y)
        boardNode.addChild(btn2)

        let btn3 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn3.name = "btn-1-2"
        btn3.position = CGPoint(x: btn1.position.x+btn1.size.width, y: btn1.position.y)
        boardNode.addChild(btn3)

        let btn4 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn4.name = "btn-0-0"
        btn4.position = CGPoint(x: btn1.position.x-btn1.size.width, y: btn1.position.y+btn1.size.width)
        boardNode.addChild(btn4)
        
        let btn5 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn5.name = "btn-0-1"
        btn5.position = CGPoint(x: btn1.position.x, y: btn1.position.y+btn1.size.width)
        boardNode.addChild(btn5)
        
        let btn6 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn6.name = "btn-0-2"
        btn6.position = CGPoint(x: btn1.position.x+btn1.size.width, y: btn1.position.y+btn1.size.width)
        boardNode.addChild(btn6)
        
        let btn7 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn7.name = "btn-2-0"
        btn7.position = CGPoint(x: btn1.position.x-btn1.size.width, y: btn1.position.y-btn1.size.width)
        boardNode.addChild(btn7)
        
        let btn8 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn8.name = "btn-2-1"
        btn8.position = CGPoint(x: btn1.position.x, y: btn1.position.y-btn1.size.width)
        boardNode.addChild(btn8)
        
        let btn9 = SKSpriteNode(color: UIColor.clearColor(), size: btnSize)
        btn9.name = "btn-2-2"
        btn9.position = CGPoint(x: btn1.position.x+btn1.size.width, y: btn1.position.y-btn1.size.width)
        boardNode.addChild(btn9)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            
            if (touchedNode.name?.hasPrefix("btn") != nil){
                print(touchedNode.name)
                let coord:[String] = touchedNode.name!.componentsSeparatedByString("-")
                let pos = Position(row:UInt8(coord[1])!, column:UInt8(coord[2])!)
                let (success, message) = board.addMove(pos, user: currentUser)
                if success == true {
                    let sprite = touchedNode as! SKSpriteNode
                    if currentUser == .X {
                        sprite.texture = xTexture
                        currentUser = .O
                    } else {
                        sprite.texture = oTexture
                        currentUser = .X
                    }
                    
                } else {
                    log.warning(message)
                }
            }
            //let sprite = SKSpriteNode(imageNamed:"x")
            
            //sprite.xScale = 0.5
            //sprite.yScale = 0.5
            //let mySize = min(screenSize.width, screenSize.height) / 3
            //sprite.size = CGSize(width:mySize, height:mySize)
            //sprite.position = location2
            
            //let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            //sprite.runAction(SKAction.repeatActionForever(action))
            
            //touchedNode.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
