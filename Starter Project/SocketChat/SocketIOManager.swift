//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by jiaguolin on 2017/5/24.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
  
//    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.2.1:8080")! as URL)
    
    
    let socket = SocketIOClient(socketURL: URL(string: "ws://10.0.0.106:8080")!, config: [.log(true), .forcePolling(true)])
    
    override init() {
        super.init()
    }

    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }

    func connectToServerWithNickname(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
            socket.emit("connectUser", nickname)
            socket.on("userList") { ( dataArray, ack) -> Void in
                completionHandler(dataArray[0] as? [[String: AnyObject]])
        }
        
        listenForOtherMessages()
    }
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }

    func sendMessage(message: String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }

    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as! String as AnyObject
            messageDictionary["message"] = dataArray[1] as! String as AnyObject
            messageDictionary["date"] = dataArray[2] as! String as AnyObject
            
            completionHandler(messageDictionary)
        }
    }


    func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
    
    func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }
    
    private func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0])
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userTypingNotification"), object: dataArray[0])
        }
    }
    
    
//    socket.on(clientEvent: .connect) {data, ack in
//    print("socket connected")
//    }
//    
//    socket.on("currentAmount") {data, ack in
//    if let cur = data[0] as? Double {
//    socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
//    socket.emit("update", ["amount": cur + 2.50])
//    }
//    
//    ack.with("Got your currentAmount", "dude")
//    }
//    }
//    
//    socket.connect()

}
