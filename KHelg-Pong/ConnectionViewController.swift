//
//  ConnectionViewController.swift
//  KHelg-Pong
//
//  Created by Petar Mataic on 25/02/15.
//  Copyright (c) 2015 Jayway. All rights reserved.
//

import UIKit

class ConnectionViewController: UIViewController, SocketControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var playerNameField: UITextField!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var messageTextField: UITextField!{
        didSet{
            messageTextField.delegate = self
        }
    }
    @IBOutlet weak var sendButton: UIButton!
 
//    let url = NSURL(string: "ws://jaywaypongserver.herokuapp.com:80")!
//    let url = NSURL(string: "ws://10.0.112.186:3000")!
    let url = NSURL(string: "localhost:3000")!
    var socketController: SocketController!
    
    // MARK: - view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.socketController = SocketController(delegate: self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "play pong" {
            let gameViewController = segue.destinationViewController as! GameViewController
            self.socketController.beginPlaying()
            gameViewController.socket = self.socketController
        }
    }
    
    @IBAction func connect(sender: UIButton) {
        if let playerName = self.playerNameField.text {
            if  playerName != "" {
                self.socketController.connectTo(url, player: playerName)
            }
        }
        self.view.endEditing(true)
    }
    
    @IBAction func disconnect(sender: UIButton) {
        self.socketController.disconnect()
    }
    
    
    // MARK: - SocketControllerDelegate
    
    func connected(socketController: SocketController) {
        self.playButton.enabled = true
        self.disconnectButton.enabled = true
        self.connectButton.enabled = false
        
    }
    
    func disconnected(socketController: SocketController) {
        self.playButton.enabled = false
        self.disconnectButton.enabled = false
        self.connectButton.enabled = true
    }
    
    func receivedMessage(socketController: SocketController, message: String) {
        self.logTextView.text = self.logTextView.text + "\n\(message)"
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        self.sendCurrentTextAsMessage()
    }
    
    func sendCurrentTextAsMessage() {
        if self.messageTextField.text != nil{
            self.socketController.sendChatMessage(self.messageTextField.text!)
            self.messageTextField.text = ""
        }
        self.messageTextField.resignFirstResponder()
    }
    
    // MARK: - textFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.sendCurrentTextAsMessage()
        return false
    }
    
    // MARK: - Keyboard animation
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    func keyboardDidShow(notification: NSNotification) {
        if let rectValue = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardSize = rectValue.CGRectValue().size
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.bottomConstraint.constant = keyboardSize.height + 12
            })
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.bottomConstraint.constant = 12.0
        })
    }
    
}
