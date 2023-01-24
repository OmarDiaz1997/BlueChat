//
//  DatabaseManager.swift
//  BlueChat
//
//  Created by Omar Diaz on 21/01/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
        

        
}

// administrador de cuentas
extension DatabaseManager{
    
    public func userExist(with email : String,
                          completion: @escaping((Bool) -> Void)){

        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///Inserta un usuario a la base de datos
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "nombre" : user.nombre,
            "apellidos" : user.apellidos
        ])
    }
}


struct ChatAppUser{
    let nombre : String
    let apellidos : String
    let email : String
    var safeEmail : String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    //let profileImageURL : String
}
