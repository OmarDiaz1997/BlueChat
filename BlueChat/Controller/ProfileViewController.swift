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
    
    let data = ["Cerrar sesion"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        //createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
                return nil
            }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            let filename = safeEmail+"_profile_picture.png"
            let path = "images/"+filename
            let headerView  = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: self.view.width,
                                             height: 300))
            headerView.backgroundColor = .white
            let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2,
                                                      y: 75,
                                                      width: 150,
                                                      height: 150))
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .white
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth = 3
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = imageView.width/2
            headerView.addSubview(imageView)
            
            StorageManager.search.downloadURL(for: path, completion: {[weak self] result in
                switch result {
                case .success(let url):
                    self?.downloadImage(imageView: imageView, url: url)
                case .failure(let error):
                    print("Fallo la descarga del url \(error)")
                }
            })
            return headerView
        }
    
    func downloadImage(imageView: UIImageView, url: URL){
            URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
                guard let data = data, error == nil else{
                    return
                }
                
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    imageView.image = image
                }
            }).resume()
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
