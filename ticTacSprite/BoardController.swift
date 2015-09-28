//
//  BoardController.swift
//  ticTacSwift
//
//  Created by Pierre Gilot on 26/09/2015.
//  Copyright © 2015 Pierre Gilot. All rights reserved.
//

import UIKit
import XCGLogger

public enum Player {
    case X, O
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


public func ==(lhs: Position, rhs: Position) -> Bool {
    return ((lhs.row == rhs.row) && (lhs.column==rhs.column))
}

public class BoardController: NSObject {
    private var _status = WinningPatterns.Playable
    public var status:WinningPatterns { return _status}
    
    let log = XCGLogger.defaultInstance();
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
    
    public func clear() {
        log.info("")
        board = [Position:Player]()
        _status = .Playable
    }
    
    public func addMove(position: Position, user: Player) -> (status:Bool, message:String) {
        log.info("")
        
        if _status != .Playable {
            return (false, "Game already finished!")
        }

        if board.count >= 9 {
            return(false, "Board Full");
        }
        
        if let _ = board[position] {
            return (false, "Position Already Taken.")
        }
        
        board[position]=user
        _status = updateStatus(user)
        log.info("Board status: \(status)")
        return (true, "Ok.")
    }
    
    public func print() {
        log.info("")
        log.debug("   0 1 2")
        for row:UInt8 in 0...2 {
            var line = " \(row) "
            for column:UInt8 in 0...2 {
                if let move = board[Position(row: row, column: column)]{
                    switch move {
                    case .X :
                        line += "X "
                    default :
                        line += "O "
                    }
                } else {
                    line += ". "
                }
            }
            log.debug(line)
        }
    }
    
    public func nextMoveForPlayer(player: Player) -> Position? {
        //TODO: Find the IA algorythm I stored somewhere and code it here in Swift
        
        log.debug("")
        if _status != .Playable {
            return nil
        }
        
        return nil
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
                log.debug("Trying pattern type \(patternType)")
                var found = 0
                for pos in matrix {
                    log.debug("position : \((pos))")
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
