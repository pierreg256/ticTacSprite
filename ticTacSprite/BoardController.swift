//
//  BoardController.swift
//  ticTacSwift
//
//  Created by Pierre Gilot on 26/09/2015.
//  Copyright © 2015 Pierre Gilot. All rights reserved.
//

import UIKit
import XCGLogger
import GameplayKit

public class Player : NSObject, GKGameModelPlayer {
    private var _id:Int = 0
    
    public class func X() -> Player {
        struct staticX {
            static let value:Player = Player(withX: true)
        }
        return staticX.value
    }
    
    public class func O() -> Player {
        struct staticO {
            static let value:Player = Player(withX: false)
        }
        return staticO.value
    }
    
    private init(withX x:Bool) {
        if x == true {
            _id = 1
        } else {
            _id = 2
        }
    }
    
    public var playerId: Int { return _id }
    public var isX: Bool { return _id == 1 }
    public var isO: Bool { return _id == 2 }
    public var opponent:Player {return (self.isX ? Player.O() : Player.X()) }
}

public func ==(lhs: Player, rhs: Player) -> Bool {
    return (lhs.playerId == rhs.playerId)
}

public enum WinningPatterns {
    case Playable
    case Line0, Line1, Line2
    case Column0, Column1, Column2
    case UpDiagonal, DownDiagonal
    case Full
}

public struct Position: Hashable, Equatable {
    var row = UInt8.max
    var column = UInt8.max
    
    public var hashValue: Int { get {
        return (Int(row)*10)+Int(column)
        }
    }
}

public class Move : NSObject, GKGameModelUpdate {
    public var pos: Position = Position()
    public var value: Int = Int.min
    
    override init() {
        super.init()
    }
    
    init(withPosition position:Position){
        self.pos = position
    }
}

public func ==(lhs: Position, rhs: Position) -> Bool {
    return ((lhs.row == rhs.row) && (lhs.column==rhs.column))
}

public class BoardController: NSObject {
    let log = XCGLogger.defaultInstance();

    private var _status = WinningPatterns.Playable
    public var status:WinningPatterns { return _status}
    private var users = [Player.X(), Player.O()]
    private var currentUser = Player.X()
    
    var board = [Position:Player]()
    
    let winningPatterns = [
        [WinningPatterns.Line0:[Position(row:0,column:0),Position(row:0,column:1),Position(row:0,column:2)]],
        [WinningPatterns.Line1:[Position(row:1,column:0),Position(row:1,column:1),Position(row:1,column:2)]],
        [WinningPatterns.Line2:[Position(row:2,column:0),Position(row:2,column:1),Position(row:2,column:2)]],
        [WinningPatterns.Column0:[Position(row:0,column:0),Position(row:1,column:0),Position(row:2,column:0)]],
        [WinningPatterns.Column1:[Position(row:0,column:1),Position(row:1,column:1),Position(row:2,column:1)]],
        [WinningPatterns.Column2:[Position(row:0,column:2),Position(row:1,column:2),Position(row:2,column:1)]],
        [WinningPatterns.UpDiagonal:[Position(row:2,column:0),Position(row:1,column:1),Position(row:0,column:2)]],
        [WinningPatterns.DownDiagonal:[Position(row:0,column:0),Position(row:1,column:1),Position(row:2,column:2)]],
    ]
    
    let scoringPatterns = [
        [Position(row:0,column:0),Position(row:0,column:1)],[Position(row:0,column:1),Position(row:0,column:2)],
        [Position(row:1,column:0),Position(row:1,column:1)],[Position(row:1,column:1),Position(row:1,column:2)],
        [Position(row:2,column:0),Position(row:2,column:1)],[Position(row:2,column:1),Position(row:2,column:2)],

        [Position(row:0,column:0),Position(row:1,column:0)],[Position(row:1,column:0),Position(row:2,column:0)],
        [Position(row:0,column:1),Position(row:1,column:1)],[Position(row:1,column:1),Position(row:2,column:1)],
        [Position(row:0,column:2),Position(row:1,column:2)],[Position(row:1,column:2),Position(row:2,column:2)],
        
        [Position(row:0,column:0),Position(row:1,column:1)],[Position(row:1,column:1),Position(row:2,column:2)],
        [Position(row:0,column:2),Position(row:1,column:1)],[Position(row:1,column:1),Position(row:2,column:0)]
    ]
    
    public func clear() {
        log.info("")
        board = [Position:Player]()
        _status = .Playable
    }
    
    public func addMove(position: Position) -> (status:Bool, message:String) {
        //log.info("")
        
        if _status != .Playable {
            return (false, "Game already finished!")
        }

        if board.count >= 9 {
            return(false, "Board Full");
        }
        
        if let _ = board[position] {
            return (false, "Position Already Taken.")
        }
        
        board[position]=currentUser
        _status = updateStatus(currentUser)
        currentUser = currentUser.opponent

        //log.info("Board status: \(status)")
        return (true, "Ok.")
    }
    
    private func cancelMove(pos: Position) -> Void {
        board.removeValueForKey(pos)
        _status = .Playable
    }
    
    public func print() {
        log.info("")
        log.debug("   0 1 2")
        for row:UInt8 in 0...2 {
            var line = " \(row) "
            for column:UInt8 in 0...2 {
                if let player = board[Position(row: row, column: column)]{
                    line += ( player.isX ? "X " : "O ")
                } else {
                    line += ". "
                }
            }
            log.debug(line)
        }
    }
    
    
    private func boardEvaluation(player:Player) -> Int16 {
        if _status == .Playable {
            log.warning("Souldnt call the evaluate function if the game is not over!")
            return 0
        }
        
        if _status == .Full {
            return 0
        }
        
        var winner:Player = (player.isX ? Player.O() : Player.X())
        switch _status {
        case .Column0, .Line0:
            if board[Position(row: 0, column: 0)] == player {
                winner = player
            }
        case .Column1, .Line1, .DownDiagonal, .UpDiagonal:
            if board[Position(row: 1, column: 1)] == player {
                winner = player
            }
        case .Column2, .Line2:
            if board[Position(row: 2, column: 2)] == player {
                winner = player
            }
        default:
            break
        }
        
        if winner == player {
            return Int16.max - (9-board.count)
        } else {
            return Int16.min + (9-board.count)
        }
    }

    public func nextRandomMove() -> Position? {
        
        if _status != .Playable {
            return nil
        }
        
        var possibleMoves = [Position]()
        
        for row:UInt8 in 0...2 {
            for column:UInt8 in 0...2 {
                if let _ = board[Position(row: row, column: column)] {
                    
                } else {
                    possibleMoves.append(Position(row: row, column: column))
                }
            }
        }
        let index = Int(arc4random_uniform(UInt32(possibleMoves.count)))
        return possibleMoves[index]
    }

    override init() {
        super.init()
        log.info("Initializing Board")
        
    }
    
    func updateStatus(lastMovePlayer: Player) -> WinningPatterns {
        for pattern in winningPatterns {
            for (patternType, matrix) in pattern {
                //log.debug("Trying pattern type \(patternType)")
                var found = 0
                for pos in matrix {
                    //log.debug("position : \((pos))")
                    if let user = board[pos] {
                        if user == lastMovePlayer {
                            found++
                        }
                    }
                }
                if found == matrix.count {
                    return patternType
                }
            }
        }
        
        if board.count >= 9 {
            return .Full
        }
        
        return .Playable
    }
    
}

extension BoardController: GKGameModel {
    /**
    * Array of instances of GKGameModelPlayers representing players within this game model. When the
    * GKMinmaxStrategist class is used to find an optimal move for a specific player, it uses this
    * array to rate the moves of that player’s opponent(s).
    */
    public var players: [GKGameModelPlayer]? { return users }
    
    /**
    * The player whose turn it is to perform an update to the game model. GKMinmaxStrategist assumes
    * that the next call to the applyGameModelUpdate: method will perform a move on behalf of this player.
    */
    public var activePlayer: GKGameModelPlayer? { return currentUser }
    
    /**
    * Returns an array of all the GKGameModelUpdates (i.e. actions/moves) that the active
    * player can undertake, with one instance of GKGameModelUpdate for each possible move.
    * Returns nil if the specified player is invalid, is not a part of the game model, or
    * if there are no valid moves available.
    */
    public func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var result=[Move]()
        for row:UInt8 in 0...2 {
            for column:UInt8 in 0...2 {
                if let _ = board[Position(row: row, column: column)] {
                    
                } else {
                    result.append(Move(withPosition: Position(row: row, column: column)))
                }
            }
        }
        return result
    }
    
    /**
    * Applies a GKGameModelUpdate to the game model, potentially resulting in a new activePlayer.
    * GKMinmaxStrategist will call this method on a copy of the primary game model to speculate
    * about possible future moves and their effects. It is assumed that calling this method performs
    * a move on behalf of the player identified by the activePlayer property.
    */
    public func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
        let move = gameModelUpdate as! Move
        board[move.pos]=currentUser
        _status = updateStatus(currentUser)
        currentUser = currentUser.opponent
    }
    
    /**
    * Returns the score for the specified player. A higher value indicates a better position for
    * the player than a lower value. Required by GKMinmaxStrategist to determine which
    * GKGameModelUpdate is the most advantageous for a given player. If the player is invalid, or
    * not a part of the game model, returns NSIntegerMin.
    */
    public func scoreForPlayer(player: GKGameModelPlayer) -> Int {
        var playerScore = 0
        var opponentScore = 0
        
        for pattern:[Position] in scoringPatterns {
            var foundPlayer = true
            var foundOpponent = true
            for pos:Position in pattern {
                if let movePlayer = board[pos] {
                    if movePlayer.playerId == player.playerId {
                        foundOpponent = false
                    } else {
                        foundPlayer = false
                    }
                } else {
                    foundOpponent = false
                    foundPlayer = false
                }
            }
            if foundPlayer == true {
                playerScore++
            }
            if foundOpponent == true {
                opponentScore++
            }
        }
        
        return playerScore - opponentScore
    }
    
    /**
    * Returns YES if the specified player has reached a win state, NO if otherwise. Note that NO does not
    * necessarily mean that the player has lost. Optionally used by GKMinmaxStrategist to improve move selection.
    */
    public func isWinForPlayer(player: GKGameModelPlayer) -> Bool {
        if _status == .Playable {
            return false
        }
        
        if _status == .Full {
            return false
        }
        
        switch _status {
        case .Column0, .Line0:
            if board[Position(row: 0, column: 0)]?.playerId == player.playerId {
                return true
            }
        case .Column1, .Line1, .DownDiagonal, .UpDiagonal:
            if board[Position(row: 1, column: 1)]?.playerId == player.playerId {
                return true
            }
        case .Column2, .Line2:
            if board[Position(row: 2, column: 2)]?.playerId == player.playerId {
                return true
            }
        default:
            return false
        }
        return false
    }
    
    /**
    * Returns YES if the specified player has reached a loss state, NO if otherwise. Note that NO does not
    * necessarily mean that the player has won. Optionally used by GKMinmaxStrategist to improve move selection.
    */
    public func isLossForPlayer(player: GKGameModelPlayer) -> Bool {
        return isWinForPlayer((player as! Player).opponent)
    }

    /**
    * Sets the data of another game model. All data should be copied over, and should not maintain
    * any pointers to the copied game state. This is used by the GKMinmaxStrategist to process
    * permutations of the game without needing to apply potentially destructive updates to the
    * primary game model.
    */
    public func setGameModel(gameModel: GKGameModel) {
        self.board = (gameModel as! BoardController).board
        self.currentUser = (gameModel as! BoardController).currentUser
        self._status = (gameModel as! BoardController)._status
    }

    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy:BoardController = BoardController()
        copy.setGameModel(self)
        return copy
    }

}

