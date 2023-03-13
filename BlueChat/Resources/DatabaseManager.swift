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
    public func createNewConversation(with otherUserEmail: String, name : String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
                    let currentNamme = UserDefaults.standard.value(forKey: "name") as? String else {
                        return
                }
                let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)

                let ref = database.child("\(safeEmail)")

                ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    guard var userNode = snapshot.value as? [String: Any] else {
                        completion(false)
                        print("user not found")
                        return
                    }

                    let messageDate = firstMessage.sentDate
                    let dateString = ChatViewController.dateFormatter.string(from: messageDate)

                    var message = ""

                    switch firstMessage.kind {
                    case .text(let messageText):
                        message = messageText
                    case .attributedText(_):
                        break
                    case .photo(_):
                        break
                    case .video(_):
                        break
                    case .location(_):
                        break
                    case .emoji(_):
                        break
                    case .audio(_):
                        break
                    case .contact(_):
                        break
                    case .custom(_), .linkPreview(_):
                        break
                    }

                    let conversationId = "conversation_\(firstMessage.messageId)"

                    let newConversationData : [String : Any] = [
                        "id": conversationId,
                        "other_user_email": otherUserEmail,
                        "name": name,
                        "latest_message" : [
                            "date": dateString,
                            "message": message,
                            "is_read": false
                        ]
                    ]

                    let recipient_newConversationData: [String: Any] = [
                        "id": conversationId,
                        "other_user_email": safeEmail,
                        "name": currentNamme,
                        "latest_message": [
                            "date": dateString,
                            "message": message,
                            "is_read": false
                        ]
                    ]
                    // Update recipient conversaiton entry
                    self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                        if var conversatoins = snapshot.value as? [[String: Any]] {
                            // append
                            conversatoins.append(recipient_newConversationData)
                            self?.database.child("\(otherUserEmail)/conversations").setValue(conversatoins)
                        }
                        else {
                            // create
                            self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                        }
                    })

                    // Update current user conversation entry
                    if var conversations = userNode["conversations"] as? [[String: Any]] {
                        // conversation array exists for current user
                        // you should append
                        conversations.append(newConversationData)
                        userNode["conversations"] = conversations
                        ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            self?.finishCreatingConversation(name: name,
                                                             conversationID: conversationId,
                                                             firstMessage: firstMessage,
                                                             completion: completion)
                        })
                    }
                    else {
                        // conversation array does NOT exist
                        // create it
                        userNode["conversations"] = [
                            newConversationData
                        ]

                        ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }

                            self?.finishCreatingConversation(name: name,
                                                             conversationID: conversationId,
                                                             firstMessage: firstMessage,
                                                             completion: completion)
                        })
                    }
                })
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
