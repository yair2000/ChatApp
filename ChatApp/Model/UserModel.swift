// User.swift
// ChatApp

import UIKit
import Firebase

struct UserModel
{
    let id: String
    let name: String?
    let email: String?
    let profileImageUrl: String?
    
    var imageStorageRef: StorageReference{
        get{
            // Profile image name
            return Storage.storage().reference().child("Profile_Images").child("\(self.id).png")
        }
    }
    
    init(dictionary: [String: Any], id: String){
        self.id = id
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        return
    }
}
