//
//  ViewController.swift
//  BlueChat
//
//  Created by MacbookMBA8 on 16/01/23.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        validateAuth()
    }
    
    func validateAuth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: false)
        }
    }
    
}

