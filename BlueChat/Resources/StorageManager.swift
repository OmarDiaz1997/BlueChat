//
//  StorageManager.swift
//  BlueChat
//
//  Created by MacbookMBA8 on 25/01/23.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    
    static let search = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Actualizacion de la imagen en el almacenamiento de firebase y retornos con URL String de descarga
    public func uploadProfilePicture(with data : Data, fileName : String, completion : @escaping UploadPictureCompletion){
        storage.child("images/\(fileName )").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else{
                //Error
                print("Fallo la actualizacion de datos de la imagen en firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName )").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Fallo al optener el url de descarga ")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl ))
                    return
                }
                let urlString = url.absoluteString
                print("url de descarga retornada \(urlString)")
                completion(.success(urlString))
            } )
        })
    }
    public enum StorageErrors : Error {
         case failedToUpload
         case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void ){
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
    
}
