//
//  GameViewController.swift
//  KHelg-Pong
//
//  Created by Petar Mataic on 25/02/15.
//  Copyright (c) 2015 Jayway. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, SocketControllerGamingDelegate {
    
    var socket : SocketController? {
        didSet {
            self.socket?.gameDelegate = self
        }
    }
    
    var first = true
    
    var steeringTimer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pong"
        self.winnerLabel.text = "Waiting for opponent"
        self.spinner.startAnimating()
    }
    
    
    var accumulatedPos : CGFloat = 0
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var p1Label: UILabel!
    @IBOutlet weak var p2Label: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var touchPad: UIView!
    @IBOutlet weak var pongView: PongView!

    deinit {
        println("will be removed")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.steeringTimer?.invalidate()
        self.steeringTimer = nil;
        self.socket?.gameDelegate = nil;
        self.socket = nil;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.first = true
    }
    
    func didStep(socketController: SocketController, step: Step){
        self.winnerLabel.text = ""
        if  first == true{
            first = false
            self.spinner.stopAnimating()
            self.steeringTimer = NSTimer.scheduledTimerWithTimeInterval(1/30, target: self, selector: Selector("runTimer"), userInfo: nil, repeats: true)
        }
        self.p1Label.text = "\(step.players.player1.name): \(step.players.player1.score)"
        self.p2Label.text = "\(step.players.player2.name): \(step.players.player2.score)"
        
        self.pongView.step = step
    }
    
    func gameEnded(socketController: SocketController, winner: String) {
        self.winnerLabel.text = "Game Over \n\(winner) won!"
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        var pos = sender.translationInView(touchPad)
        self.accumulatedPos += pos.x
        sender.setTranslation(CGPointZero, inView: touchPad)
    }
    
    func runTimer() {
        if accumulatedPos != 0 {
            let theMove = ["paddle": ["x": self.accumulatedPos, "y": 0]]
            self.socket?.sendStep(theMove)
            self.accumulatedPos = 0
        }
    }
    
    
}
