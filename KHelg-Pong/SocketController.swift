//
//  SocketController.swift
//  KHelg-Pong
//
//  Created by Petar Mataic on 25/02/15.
//  Copyright (c) 2015 Jayway. All rights reserved.
//

import Foundation

protocol SocketControllerDelegate: class {
    func connected(socketController: SocketController)
    func disconnected(socketController: SocketController)
    func receivedMessage(socketController: SocketController, message: String)
}

protocol SocketControllerGamingDelegate: class {
    func didStep(socketController: SocketController, step: Step)
    func gameEnded(socketController: SocketController, winner: String)
}

class SocketController {
    
    weak var delegate: SocketControllerDelegate?
    weak var gameDelegate: SocketControllerGamingDelegate?
    var socket : SocketIOClient?
    
    init(delegate: SocketControllerDelegate) {
        self.delegate = delegate
    }
    
    
    func connectTo(url: NSURL, player: String) {
        let urlString = url.absoluteString!
        println("Connecting to: \(urlString)")
        
        self.socket = SocketIOClient(socketURL: urlString)
        self.addHandlers()
        self.socket?.connect()
        
        delay(0.5) {
            self.socket?.emit("add player", ["playername" : player])
            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.connected(self)
                return
            }
        }
        
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            closure)
    }
    
    func addHandlers() {
        
        self.socket?.on("message") {[weak self] data, ack in
            if let root = data?.firstObject as? [String : AnyObject] {
                if let message = root["message"] as? String {
                    let player = root["player"] as? String
                    dispatch_async(dispatch_get_main_queue()){
                        let visualString = "\(player!): \(message)"
                        self?.delegate?.receivedMessage(self!, message: visualString)
                        return
                    }
                }
            }
        }
        
        self.socket?.on("players") { [weak self] data, ack in
            if let root = data?.firstObject as? [String : AnyObject] {
                println("players updated")
            }
        }
        
        self.socket?.on("step") {[weak self] data, ack in
            if let root = data?.firstObject as? [String: AnyObject]{
                var step = Step(json: root)
                dispatch_async(dispatch_get_main_queue()){
                    self?.gameDelegate?.didStep(self!, step: step)
                    return
                }
            }
        }
        
        self.socket?.on("winning") {[weak self] data, ack in
            if let root = data?.firstObject as? [String: AnyObject]{
                if let winner = root["winner"] as? String {
                    dispatch_async(dispatch_get_main_queue()){
                        self?.gameDelegate?.gameEnded(self!, winner: winner)
                        return
                    }
                }
            }
        }
    }

    func sendChatMessage(message : String) {
        self.socket?.emit("message", ["message" : message])
    }
    
    func disconnect() {
        self.socket?.close()
        self.socket = nil;
        dispatch_async(dispatch_get_main_queue()){
            self.delegate?.disconnected(self)
            return
        }
        
    }
    
    func beginPlaying() {
        self.socket?.emit("ready")
    }
    
    func sendStep(step : [String : AnyObject]){
        socket?.emit("move", step)
    }
    
}