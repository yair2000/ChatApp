// NewMessagesController.swift
// ChatApp (Sending a new message to a user)

import UIKit
import Firebase

class NewMessagesController: UITableViewController
{
    let cellID = "userCell"
    var users = [UserModel]()
    var callback: ((UserModel) ->Void)?
    
    class func generateVC() -> NewMessagesController{
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: "UserPickerController") as! NewMessagesController
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Creating a bar buttom
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(canceler))
        fetchUsers()
    }
    
    // Fetching the usernames from Firebase Database
    func fetchUsers(){
        Database.database().reference().child("Users").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let myUser = UserModel(dictionary: dict, id: snapshot.key)
                self.users.append(myUser)
                
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func canceler(){
        dismiss(animated: true, completion: nil)
    }
    
    // Table View Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int{
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    // Spacing
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 56
    }
    var messagesController: MessagesController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        dismiss(animated: true){
            let user = self.users[indexPath.row]
            self.messagesController?.userChatController(user: user)
        }
    }
}
