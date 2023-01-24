//
//  ProfileViewController.swift
//  BlueChat
//
//  Created by MacbookMBA8 on 18/01/23.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    @IBOutlet var tableView : UITableView!
    
    let data = ["Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

}


extension ProfileViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionSheet = UIAlertController(title: "Confirmación",
                                  message: "¿Desea cerrar sesión?",
                                  preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cerrar sesión",
                                      style: .destructive, handler: {[weak self] _ in
            guard let strongSelf = self else { return  }
            
            do{
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                
                strongSelf.present(nav, animated: true)
            }
            catch{
                print("Fallo el cierre de sesion")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar",
                                            style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true)
        

    }
}
