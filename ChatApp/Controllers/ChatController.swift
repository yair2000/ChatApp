// ChatController.swift
// ChatApp (Chat Screen)

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    // This shows the user's name at "ChatController" after you clicked on it
    var user: UserModel?{
        didSet{
            navigationItem.title = user?.name
            msgExtractor()
        }
    }
    
    var messages = [MessageModel]()
    
    // Shows the meesages each user received
    func msgExtractor(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else{
            return // Returns the current logged in user
        }
        let userMessagesRef = Database.database().reference().child("User Messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (msgSnapshot) in
            let messageID = msgSnapshot.key
            let msgRef = Database.database().reference().child("Messages").child(messageID)
            msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let messageDict = snapshot.value as? [String: Any] else{
                    return
                }
                self.messages.append(MessageModel(dictionary: messageDict))
                DispatchQueue.main.async{
                    self.collectionView?.reloadData() // Filters the messages
                    
                    // Scrolling in the chat controller
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    // This mwthod sends the messages to Firebase Database
    lazy var msgInputer: UITextField = {
        let msgSender = UITextField()
        msgSender.placeholder = "Enter Message"
        msgSender.translatesAutoresizingMaskIntoConstraints = false
        msgSender.delegate = self
        return msgSender
    }()
    
    let msgID = "msgID"
    override func viewDidLoad(){
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UserChatCell.self, forCellWithReuseIdentifier: msgID)
        collectionView?.keyboardDismissMode = .interactive
        inputComponentSetup() // Container View
        //keyboardSetup()
    }
    
    func inputComponentSetup(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // containerView Contraints
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true // CenterX Anchor
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true // CenterY Anchor
        //containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor) // CenterY Anchor
        //containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Send Media Button
        let mediaBtn = UIImageView()
        mediaBtn.image = UIImage(named: "icons8-gallery")
        mediaBtn.isUserInteractionEnabled = true
        mediaBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediaSender)))
        mediaBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mediaBtn)
        
        // mediaBtn Contraints
        mediaBtn.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true // CenterX Anchor -> The button is on the bottom left side of the screen
        mediaBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mediaBtn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        mediaBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Send Button
        let sendBtn = UIButton(type: .system)
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.addTarget(self, action: #selector(textMessageSender), for: .touchUpInside)
        view.addSubview(sendBtn)
        
        // sendBtn Contraints
        sendBtn.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true // CenterX Anchor -> The button is on the bottom right side of the screen
        sendBtn.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendBtn.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendBtn.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // Text Field -> Sending messages
        view.addSubview(msgInputer)
        
        // msgInputer Contraints
        msgInputer.leftAnchor.constraint(equalTo: mediaBtn.rightAnchor, constant: 8).isActive = true // CenterX Anchor -> The text field is on the bottom left side of the screen
        msgInputer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        msgInputer.rightAnchor.constraint(equalTo: sendBtn.leftAnchor).isActive = true // Width Anchor
        msgInputer.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // Seperator
        let lineSeperator = UIView()
        lineSeperator.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 1)
        lineSeperator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineSeperator)
        
        // lineSeperator Contraints
        lineSeperator.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true // CenterX Anchor
        lineSeperator.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        lineSeperator.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        lineSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    // Collection View Functions
    // Shows the number of sent meesages of each user
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) ->Int{
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->UICollectionViewCell{
        let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: msgID, for: indexPath) as! UserChatCell
        let message = messages[indexPath.item]
        msgCell.textView.text = message.text
        
        // The chat bubbles' color method
        cellSetup(msgCell: msgCell, message: message)
        
        // Modifying the buubleView's Width
        if let msgText = message.text{ // Text Message
            msgCell.bubbleWidthAnchor?.constant = bubbleFrame(text: msgText).width + 32
            msgCell.textView.isHidden = false
        }
        else if message.imageUrl != nil{ // Image Message
            msgCell.bubbleWidthAnchor?.constant = 200
            msgCell.textView.isHidden = true
        }
        return msgCell
    }
    
    private func cellSetup(msgCell: UserChatCell, message: MessageModel){
        if let profileImageUrl = self.user?.profileImageUrl{
            msgCell.profileImageView.imgCache(profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid{
            // Blue Bubble (Outcoming)
            msgCell.bubbleView.backgroundColor = UIColor.blue
            msgCell.textView.textColor = UIColor.white
            msgCell.profileImageView.isHidden = true
            msgCell.bubbleViewRightAnchor?.isActive = true
            msgCell.bubbleViewLeftAnchor?.isActive = false
        }
        else{
            // Gray Bubble (Incoming)
            msgCell.bubbleView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            msgCell.textView.textColor = UIColor.black
            msgCell.profileImageView.isHidden = false
            msgCell.bubbleViewRightAnchor?.isActive = false
            msgCell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let imgMessage = message.imageUrl{ // The Bubble View of an image message
            msgCell.imageMessage.imgCache(imgMessage)
            msgCell.imageMessage.isHidden = false
            msgCell.bubbleView.backgroundColor = UIColor.clear
        }
        else{
            msgCell.imageMessage.isHidden = true
        }
    }
    
    // Changes the messages' size when you rotate the device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator){
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) ->CGSize{
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text{
            height = bubbleFrame(text: text).height + 20
        }
        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
            height = CGFloat(imageHeight / imageWidth * 200) // calculation of the image cell
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    // Height of the message cell (Related to "UserChatCell")
    private func bubbleFrame(text: String) ->CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    // This method uploads media
    @objc func mediaSender(){
        let mediaSender = UIImagePickerController()
        mediaSender.allowsEditing = true
        mediaSender.delegate = self
        //mediaSender.sourceType = .camera
        mediaSender.sourceType = .photoLibrary
        //mediaSender.sourceType = .savedPhotosAlbum
        present(mediaSender, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info) // Local variable inserted by Swift 4.2 migrator.
        var pickedImg: UIImage?
        
        if let editImg = info["UIImagePickerControllerEditedImage"] as? UIImage{
            pickedImg = editImg
        }
        else if let originImg = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            pickedImg = originImg
        }
        
        if let selectedImg = pickedImg{
            uploadImageToFirebase(image: selectedImg)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImageToFirebase(image: UIImage){ // Sending images to Firebase
        let imgName = NSUUID().uuidString
        let imgRef = Storage.storage().reference().child("Message_Images").child("\(imgName).png")
        if let uploadData = image.jpegData(compressionQuality: 0.1){
            imgRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil{
                    print("Failed to upload image:", error as Any)
                    return
                }
                print(imgRef.downloadURL(completion: { (url, err) in
                    if err != nil{
                        print(err as Any)
                        return
                    }
                    else{
                        let imageUrl = url?.absoluteString
                        self.imageMessageSender(imageUrl: imageUrl!, image: image)
                    }
                }))
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    // This method uploads the message's details
    @objc func textMessageSender(){
        let ref = Database.database().reference().child("Messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970 // When the message was sent
        let values = ["text": msgInputer.text!, "sender": fromId as Any, "receiver": toId as Any, "time": timestamp]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error as Any)
                return
            }
            
            // "User Messages" References
            let msgSenderRef = Database.database().reference().child("User Messages").child(fromId!).child(toId!)
            let textID = childRef.key
            msgSenderRef.updateChildValues([textID: self.msgInputer.text as Any])
            let msgReceiverRef = Database.database().reference().child("User Messages").child(toId!).child(fromId!)
            msgReceiverRef.updateChildValues([textID: self.msgInputer.text as Any])
            self.msgInputer.text = nil // After sending a message, the message field is cleared
        }
    }
    
    // This method uploads the image message's details
    private func imageMessageSender(imageUrl: String, image: UIImage){
        let properties: [String: Any] = ["imageUrl": imageUrl, "imageHeight": image.size.height, "imageWidth": image.size.width]
        messageSender(properties: properties)
    }
    
    private func messageSender(properties: [String: Any]){
        let ref = Database.database().reference().child("Messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970 // When the message was sent
        var values: [String: Any] = ["sender": fromId as Any, "receiver": toId as Any, "time": timestamp]
        properties.forEach({values[$0] = $1}) // $0 ->Key, $1 ->Value
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error as Any)
                return
            }
            self.msgInputer.text = nil // After sending a message, the message field is cleared
            
            // "User Messages" References
            let msgSenderRef = Database.database().reference().child("User Messages").child(fromId!).child(toId!)
            let imageID = childRef.key
            msgSenderRef.updateChildValues([imageID: properties])
            let msgReceiverRef = Database.database().reference().child("User Messages").child(toId!).child(fromId!)
            msgReceiverRef.updateChildValues([imageID: properties])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) ->Bool{
        textMessageSender()
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) ->[String: Any]{
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
