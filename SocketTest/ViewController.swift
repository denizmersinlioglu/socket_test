//
//  ViewController.swift
//  SocketTest
//
//  Created by Deniz Mersinlioğlu on 2.10.2018.
//  Copyright © 2018 mersinliogludeniz. All rights reserved.
//

import UIKit
import SwiftWebSocket

class ViewController: UIViewController {
    @IBOutlet var firstText: UITextField!
    @IBOutlet var secondText: UITextField!
    var socket: WebSocket!
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = WebSocket("wss://echo.websocket.org")
    
        socket.event.open = {
            print("opened")
        }
        
        socket.event.close = { code, reason, clean in
            print("closed")
        }
        
        socket.event.error = { error in
            print("error \(error)")
        }
        
        socket.event.message = { message in
            if let text = message as? String {
                self.handleMessage(jsonString: text)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    func handleMessage(jsonString:String){
        if let data = jsonString.data(using: String.Encoding.utf8){
            do {
                let JSON : [String:AnyObject] = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                print("We've successfully parsed the message into a Dictionary! Yay!\n\(JSON)")
                let sender : String = JSON["name"] as! String
                let message : String = JSON["message"] as! String
                let time : String = JSON["time"] as! String
                
                let alert = UIAlertController(title: "Message!", message: "\(sender)(\(time)): \(message)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } catch let error{
                print("Error parsing json: \(error)")
            }
        }
    }

    @IBAction func sendTapped(_ sender: Any) {
        var json = [String:Any]()
        json["name"] = firstText.text
        json["message"] = secondText.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        json["time"] = dateFormatter.string(from: Date())
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted);
            if let string = String(data: jsonData, encoding: String.Encoding.utf8){
                socket.send(string)
            } else {
                print("Couldn't create json string");
            }
        } catch let error {
            print("Couldn't create json data: \(error)");
        }
    }

}

