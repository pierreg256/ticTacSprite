//
//  GameController.swift
//  ticTacSprite
//
//  Created by Gilot, Pierre on 29/09/2015.
//  Copyright © 2015 Pierre Gilot. All rights reserved.
//

import UIKit
import XCGLogger
import GameplayKit

class GameController: GameSceneDelegate {
    private var board = BoardController()
    private var minMax = GKMinmaxStrategist()
    private var me = Player.X()
    //private var currentUser = Player.X()
    private let log = XCGLogger.defaultInstance()
    private var scene:GameScene?
    
    init() {
        log.debug("Initializing GameController")
        minMax.gameModel = board
        minMax.maxLookAheadDepth = 3
    }

    //MARK: - GameScene Delegate methods
    func gameScene(gameScene:GameScene, didSelectPosition:Position) {
        log.info("Selecting cell:\(didSelectPosition.row), \(didSelectPosition.column)")
        
        if me != board.activePlayer as! Player {
            return
        }
        
        let (success, message) = board.addMove(didSelectPosition)
        if success == true {
            gameScene.presentBoardCellAt(didSelectPosition, forUser: (board.activePlayer as! Player).opponent, animated: true)
            self.scene = gameScene
            nextTurn()
        } else {
            log.warning(message)
        }
    }
    
    private func nextTurn() {
        switch board.status {
        case .Playable:
            if me != board.activePlayer as! Player {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    //TODO: Implement AI here
                    let move:Move = self.minMax.bestMoveForPlayer(self.board.activePlayer!) as! Move
                    self.log.debug("best move: \(move.pos), \(move.value)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.board.applyGameModelUpdate(move)
                        self.scene?.presentBoardCellAt(move.pos, forUser: (self.board.activePlayer as! Player).opponent, animated: true)
                        self.nextTurn()
                    }
                }
            }
        case .Full:
            showMessage("Nobody won... try again!")
        default:
            if board.isWinForPlayer(Player.X())  {
                showMessage("The X's won... Hurray!")
            } else {
                showMessage("The O's won... Great!")
            }
        }
    }
    
    private func showMessage(message:String) -> Void {
        let alert = UIAlertController(title: "Game Over!", message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (okSelected) -> Void in
            self.log.debug("Ok Selected")
            self.reset()
        }
        alert.addAction(okButton)
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.presentViewController(alert, animated: true, completion: nil)
            // topController should now be your topmost view controller
        }
    }
    
    private func reset() {
        board.clear()
        
    }
}

