//
//  ViewController.swift
//  damo
//
//  Created by systec on 2019/7/3.
//  Copyright © 2019 systec. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBAction func register() {
        let sip_domain = UnsafeMutablePointer<Int8>(mutating: ("hk.systec-pbx.net" as NSString).utf8String);
        let sip_user = UnsafeMutablePointer<Int8>(mutating: ("00000000000001E6" as NSString).utf8String);
        let sip_passwd = UnsafeMutablePointer<Int8>(mutating: ("063283" as NSString).utf8String);
        account_registered(sip_domain, sip_user, sip_passwd)
    }
    
    @IBAction func unrefister() {
        account_unregistered()
    }
    
    @IBAction func answer() {
        
    }
    
    @IBAction func makeCall() {
        accMakeCall()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        incoming_call = incomingCallback(accId: callId:);
    }
}
private func accMakeCall(){
    let name = UnsafeMutablePointer<Int8>(mutating: ("hello" as NSString).utf8String);
    let sipid = UnsafeMutablePointer<Int8>(mutating: ("00000000000000F3" as NSString).utf8String);
    let sip_server = UnsafeMutablePointer<Int8>(mutating: ("hk.systec-pbx.net" as NSString).utf8String);
    make_call(name, sipid, sip_server);
}

private func incomingCallback(accId : Int32, callId : Int32){
    print("this is a swift function! acc_id=\(accId) call_id=\(callId)");
    answer(callId);
}
