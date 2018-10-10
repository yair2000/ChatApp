// MessagesController.swift
// ChatApp (Users Screen)

import UIKit
import Firebase
import SDWebImage

class MessagesController: UITableViewController
{
    let chatID = "chatID"
    var ref: DatabaseReference!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // Manual Bar Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // New Message Button (Bar Button)
        let image = UIImage(named: "icons8-new_message")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(messageHandler))
        userStats()
        userMsgObserver()
        tableView.register(UserCell.self, forCellReuseIdentifier: chatID)
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    var messages = [MessageModel]() // an empty Array of messages
    var messagesDict = [String: MessageModel]()
    
    // This method shows the messages EACH user sent to other users
    func userMsgObserver(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let ref = Database.database().reference().child("User Messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let senderID = snapshot.key
            Database.database().reference().child("User Messages").child(uid).child(senderID).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessages(messageID: messageID)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            print(snapshot.key)
            print(self.messagesDict)
            self.messagesDict.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
    }
    
    private func fetchMessages(messageID: String){
        let messageRef = Database.database().reference().child("Messages").child(messageID)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
                let message = MessageModel(dictionary: dictionary)
                
                if let partnerID = message.partnerID(){
                    self.messagesDict[partnerID] = message
                }
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable(){ // Reduce time of chat list to show up
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reloader), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    @objc func reloader(){
        self.messages = Array(self.messagesDict.values) // Shows all messages sent to the user at once (not separately)
        self.messages.sort(by: { (msg1, msg2) -> Bool in
            return (msg1.timestamp?.intValue)! > (msg2.timestamp?.intValue)! // Sorting the chats
        })
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    // TableView Functions -> Number of messages in the cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int{
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: chatID, for: indexPath) as! UserCell
        let msgText = messages[indexPath.row]
        cell.message = msgText
        return cell
    }
    // Spacing
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat{
        return 56
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let message = messages[indexPath.row]
        
        guard let partnerID = message.partnerID() else{
            return
        }
        // Details of the messages' sender
        let ref = Database.database().reference().child("Users").child(partnerID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Sends the user to a chat log with a received-message user
            guard let dictionary = snapshot.value as? [String: Any] else{
                return
            }
            let user = UserModel(dictionary: dictionary, id: snapshot.key)
            self.userChatController(user: user)
        }, withCancel: nil)
    }
    
    // Editing TableView Cells (Deleting Conversations)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) ->Bool{
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let message = self.messages[indexPath.row]
        
        if let partnerID = message.partnerID(){
            Database.database().reference().child("User Messages").child(uid).child(partnerID).removeValue{ (err, chatRef) in
                if err != nil{ // If the chat was deleted
                    print("Failed:", err as Any)
                    return
                }
                self.messagesDict.removeValue(forKey: partnerID)
                self.attemptReloadOfTable()
            }
        }
    }
    
    @objc func messageHandler(){
        let userPickerVC = NewMessagesController.generateVC()
        userPickerVC.callback = { user in
            debugPrint(user.name ?? "no name")
            self.dismiss(animated: true, completion: nil)
        }
        userPickerVC.messagesController = self // click the user and move to "ChatController"
        let navController = UINavigationController(rootViewController: userPickerVC)
        present(navController, animated: true, completion: nil)
    }
    
    // Check if the user is online
    func userStats(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }
        else{
            userDisplay()
        }
    }
    
    func userDisplay(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return // returns 'nil' user
        }
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any]{
                let user = UserModel(dictionary: dictionary, id: snapshot.key)
                self.imgUsername(user: user)
            }
        }, withCancel: nil)
    }
    
    // Displaying the username with its profile picture
    func imgUsername(user: UserModel){
        self.navigationItem.title = user.name
        
        // A Container View (Profile Image of the logged in user)
        let titleView = UIButton()
        let profileView = UIImageView()
        profileView.sd_setImage(with: user.imageStorageRef) // Profile Image in the container view
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.contentMode = .scaleAspectFill
        profileView.layer.cornerRadius = 20
        profileView.clipsToBounds = true
        titleView.addSubview(profileView)
        
        // profileView Constraints
        profileView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true // CenterX Anchor
        profileView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        // containerView Constraints
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(nameLabel)
        
        // nameLabel Constraints
        nameLabel.leftAnchor.constraint(equalTo: profileView.rightAnchor, constant: 8).isActive = true // CenterX Anchor
        nameLabel.centerYAnchor.constraint(equalTo: profileView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true // widthAnchor
        nameLabel.heightAnchor.constraint(equalTo: profileView.heightAnchor).isActive = true

        self.navigationItem.titleView = titleView
    }
    
    func userChatController(user: UserModel){
        let chatLogController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout(){
        do{
            try Auth.auth().signOut()
        }
        catch let logoutError{
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.msgController = self
        present(loginController, animated: true, completion: nil)
        messages.removeAll()
        messagesDict.removeAll()
        tableView.reloadData()
    }
}
