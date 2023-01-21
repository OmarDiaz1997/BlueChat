//
//  RegisterViewController.swift
//  BlueChat
//
//  Created by MacbookMBA8 on 18/01/23.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UINavigationControllerDelegate {

    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let nombreField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Nombre"
        //Correcion de texto alineado a la izquierda
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let apellidosField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Apellidos"
        //Correcion de texto alineado a la izquierda
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Correo electronico"
        //Correcion de texto alineado a la izquierda
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Contrasena"
        //Correcion de texto alineado a la izquierda
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registrarButton : UIButton = {
        let button = UIButton()
        button.setTitle("Registrar", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inicio de sesión"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Registrar",
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(didTapRegister))
        registrarButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        //Se agregan subvistas
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(nombreField)
        scrollView.addSubview(apellidosField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registrarButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        //gesture.numberOfTouchesRequired = 1
        
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfilePic(){
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        
        nombreField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        apellidosField.frame = CGRect(x: 30,
                                  y: nombreField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: apellidosField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        registrarButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)

        
    }
    
    @objc private func loginButtonTapped(){
        
        nombreField.resignFirstResponder()
        apellidosField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let nombre = nombreField.text,
              let apellidos = apellidosField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !nombre.isEmpty,
              !apellidos.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else{
            altertLoginError()
            return
        }
        
        // Registro con firebase
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            guard let result = authResult, error == nil else{
                print("Error")
                return
            }
            let user = result.user
            print("Usuario creado: \(user)")
        })
        
    }
    
    func altertLoginError(){
        let alert = UIAlertController(title: "Datos no validos",
                                      message: "Debe de llenar todos los campos",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar",
                                      style: .cancel,
                                     handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Crear sesión"
        navigationController?.pushViewController(vc, animated: true)
    }
    

}


extension RegisterViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        
        return true
        
    }
    
}

extension RegisterViewController : UIImagePickerControllerDelegate {
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Imagen de perfil",
                                            message: "Seleccionar foto de perfil",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancelar",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Tomar foto",
                                            style: .default,
                                            handler: { [weak self] _ in
                                            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Seleccionar desde la galería",
                                            style: .default,
                                            handler: { [weak self] _ in
                                            self?.presentPhotoPicker()
            
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
