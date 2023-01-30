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
        
    static func safeEmail(emailAddress : String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
        
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
    public func insertUser(with user: ChatAppUser, completion: @escaping(Bool) -> Void ){
        database.child(user.safeEmail).setValue([
            "nombre" : user.nombre,
            "apellidos" : user.apellidos
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("La escritura en la base de datos a fallado")
                completion(false)
                return
            }
            /*Agregar referencias de un nuevo contacto*/
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String : String]]{
                    //Vincular usuario al diccionario
                    let newElement = [
                        "name": user.nombre+" " + user.apellidos,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }else{
                    //Crear arreglo para rellenar lista de contactos
                    let newCollection : [[String : String]] = [
                        ["name": user.nombre+" " + user.apellidos,
                         "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
    }
    
}


// MARK: - Enviar mensajes / conversaciones

extension DatabaseManager {
    
    ///Crear una nueva conversacion con correo electronico y envio del primer mensaje
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
    }
    
    /// Recuoera y retorna todas las conversaciones del usuario en base al correo electronico
    public func getAllConversations(for email: String, completion: @escaping(Result<String, Error>) -> Void){
        
    }
    
    ///Optener todos los mensajes de una conversacion
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<String, Error>) -> Void){
        
    }
    
    ///Enviar mensajes con destino de conversacion y mensaje
    public func sendMessage(to conversation: String, message: Message, completion: @escaping(Result<String, Error>) -> Void){
        
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
    var profilePictureFileName : String{
        return "\(safeEmail)_profile_picture.png "
    }
}
