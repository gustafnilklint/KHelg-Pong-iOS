//
//  Step.swift
//  KHelg-Pong
//
//  Created by Petar Mataic on 27/02/15.
//  Copyright (c) 2015 Jayway. All rights reserved.
//

import Foundation
import UIKit

struct Step {
    var ball: (position: CGPoint, radius: CGFloat)
    var playerPaddle: CGRect = CGRectZero
    var opponentPaddle: CGRect = CGRectZero
    var players: (player1: (name: String, score: Int), player2: (name: String, score: Int))
    var bounds: CGSize

    init(json: [String:AnyObject]) {
        let ball = json["ball"] as! [String: AnyObject]
        let ballX = ball["x"] as! CGFloat
        let ballY = ball["y"] as! CGFloat
        let ballR = ball["radius"] as! CGFloat
        self.ball = (position: CGPointMake(ballX, ballY), radius: ballR)

        let players = json["players"] as! [String: AnyObject]
        let player1 = players["player1"] as! [String: AnyObject]
        let player2 = players["player2"] as! [String: AnyObject]
        let p1Name = player1["name"] as! String
        let p2Name = player2["name"] as! String
        let p1Score = player1["score"] as! Int
        let p2Score = player2["score"] as! Int
        self.players = (player1: (name: p1Name, score: p1Score), player2: (name: p2Name, score: p2Score))

        let bounds = json["bounds"] as! [String: AnyObject]
        let width = bounds["width"] as! CGFloat
        let height = bounds["height"] as! CGFloat
        self.bounds = CGSizeMake(width, height)

        if let playerPaddle = json["playerPaddle"] as? [String: AnyObject] {
            let playerPaddleX = playerPaddle["x"] as! CGFloat
            let playerPaddleY = playerPaddle["y"] as! CGFloat
            let playerPaddleW = playerPaddle["width"] as! CGFloat
            let playerPaddleH = playerPaddle["height"] as! CGFloat
            self.playerPaddle = CGRectMake(playerPaddleX, playerPaddleY, playerPaddleW, playerPaddleH)
        }

        if let opponentPaddle = json["remotePlayerPaddle"] as? [String: AnyObject] {
            let opponentPaddleX = opponentPaddle["x"] as! CGFloat
            let opponentPaddleY = opponentPaddle["y"] as! CGFloat
            let opponentPaddleW = opponentPaddle["width"] as! CGFloat
            let opponentPaddleH = opponentPaddle["height"] as! CGFloat
            self.opponentPaddle = CGRectMake(opponentPaddleX, opponentPaddleY, opponentPaddleW, opponentPaddleH)
        }
    }
}
