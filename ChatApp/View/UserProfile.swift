// UserProfile.swift
// ChatApp (The logged in Username with its profile image)

import UIKit
import Firebase
import SDWebImage
import FirebaseStorage
import FirebaseUI

class UserProfile: UITableViewCell
{
    @IBOutlet weak var imgLabel: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    func configure(with user : UserModel){
        userLabel.text = user.name
        imgLabel.sd_setImage(with: user.imageStorageRef)
    }
}
