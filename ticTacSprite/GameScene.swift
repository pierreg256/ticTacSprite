//
//  GameScene.swift
//  ticTacSprite
//
//  Created by Pierre Gilot on 28/09/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

import SpriteKit
import XCGLogger

protocol GameSceneDelegate {
    func gameScene(gameScene:GameScene, didSelectPosition:Position)
}

class GameScene: SKScene {
    var gameController:GameSceneDelegate?
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let oTexture = SKTexture(imageNamed: "o")
    let xTexture = SKTexture(imageNamed: "x")
    
    let boardNode = SKSpriteNode(imageNamed: "board")
    let log = XCGLogger.defaultInstance()
    //let board = BoardController()
    var currentUser = Player.X


    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor(red: 141/255, green: 141/255, blue: 141/255, alpha: 1.0)
        
        // Setup the board
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
    
    private func reset() -> Void {
        //board.clear()
        for sprite in boardNode.children {
            let btn = sprite as! SKSpriteNode
            btn.texture = nil
        }
    }
    
    func presentBoardCellAt(position:Position, forUser:Player, animated:Bool) {
        let btnName = "btn-\(position.row)-\(position.column)"
        log.info("Trying to find: \(btnName)")
        let node = boardNode.children.filter { $0.name == btnName }[0]
        let sprite = node as! SKSpriteNode
        sprite.texture = (forUser.isX ? xTexture : oTexture)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            
            if (touchedNode.name?.hasPrefix("btn") != nil){
                let coord:[String] = touchedNode.name!.componentsSeparatedByString("-")
                let pos = Position(row:UInt8(coord[1])!, column:UInt8(coord[2])!)
                gameController?.gameScene(self, didSelectPosition:pos)
                
                /*let (success, message) = board.addMove(pos, user: currentUser)
                if success == true {
                    let sprite = touchedNode as! SKSpriteNode
                    if currentUser == .X {
                        sprite.texture = xTexture
                        currentUser = .O
                    } else {
                        sprite.texture = oTexture
                        currentUser = .X
                    }
                    switch board.status {
                    case .Playable:
                        //break
                        log.debug("Next move is \(board.nextMoveForPlayer(currentUser))")
                    case .Full:
                        showMessage("Nobody won... try again!")
                    default:
                        if currentUser == .O {
                            showMessage("The X's won... Hurray!")
                        } else {
                            showMessage("The O's won... Great!")
                        }
                    }
                } else {
                    log.warning(message)
                }*/
            }
        }
    }
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
