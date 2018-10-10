// LoginController.swift
// ChatApp (Login & Register Screen)

import UIKit
import Firebase

class LoginController: UIViewController
{
    var msgController: MessagesController?
    
    // Creating a ContainerView
    let inputsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    // Creating the Register Button
    let btn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 123/255, green: 15/255, blue: 40/255, alpha: 1)
        button.setTitle("Register", for: .normal)
	button.layer.cornerRadius = 16
        button.setTitleColor(UIColor.yellow, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(btnHandler), for: .touchUpInside)
        return button
    }()
    
    @objc func btnHandler(){
        if sBtns.selectedSegmentIndex == 0{
            logHandler()
        }
        else{
            regHandler()
        }
    }
    
    func logHandler(){
        guard let email = mailText.text, let pass = passText.text else{
            print("Invalid")
            return
        }
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if error != nil{
                return
            }
            self.msgController?.userDisplay()
            self.dismiss(animated: true, completion: nil)
            FlowController.shared.determineRootViewController()
        }
    }
    
    let nameText: UITextField = {
        let name = UITextField()
        name.placeholder = "Name"
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    let nameSeperator: UIView = {
        let seperator = UIView()
        seperator.backgroundColor = UIColor(red: 110, green: 110, blue: 110, alpha: 1)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        return seperator
    }()
    let mailText: UITextField = {
        let mail = UITextField()
        mail.placeholder = "Email"
        mail.translatesAutoresizingMaskIntoConstraints = false
        return mail
    }()
    let mailSeperator: UIView = {
        let seperator = UIView()
        seperator.backgroundColor = UIColor(red: 110, green: 110, blue: 110, alpha: 1)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        return seperator
    }()
    let passText: UITextField = {
        let pass = UITextField()
        pass.placeholder = "Password"
        pass.translatesAutoresizingMaskIntoConstraints = false
        pass.isSecureTextEntry = true
        return pass
    }()
    // lazy var enables the access of "self" in "addGestureRecognizer" from the "profileImage"
    lazy var profileImage: UIImageView = {
        let picture = UIImageView()
        picture.image = UIImage(named: "icons8-groups")
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.contentMode = .scaleAspectFill
        picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageHandler)))
        picture.isUserInteractionEnabled = true
        return picture
    }()
    
    // Creating the Login & Register Segments
    let sBtns: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1 // Highlighted Button ("Register")
        sc.addTarget(self, action: #selector(progressSegmentHandler), for: .valueChanged)
        return sc
    }()
    
    @objc func progressSegmentHandler(){
        // Change the button's name under the container view to one of the segment's name
        let title = (sBtns.titleForSegment(at: sBtns.selectedSegmentIndex))
        btn.setTitle(title, for: .normal)
        // Change the container view's height (login segment) ->(100=Login, 150=Register)
        containerAnchor?.constant = sBtns.selectedSegmentIndex == 0 ? 100 : 150
        
        // Login segment setup
        nameTextAnchor?.isActive = false
        nameTextAnchor = nameText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: sBtns.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextAnchor?.isActive = true
        
        // New Login Screen (mail & password only)
        mailTextAnchor?.isActive = false
        mailTextAnchor = mailText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: sBtns.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        mailTextAnchor?.isActive = true
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 25/255, green: 40/255, blue: 50/255, alpha: 1)
        view.addSubview(inputsContainer)
        view.addSubview(btn)
        view.addSubview(profileImage)
        view.addSubview(sBtns)
        progressSegmentSetup()
        containersSetup()
        registerSetup()
        profileImageSetup()
    }
    
    func progressSegmentSetup(){
        // ContainerView Constraints -> Constraints Anchors
        sBtns.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sBtns.bottomAnchor.constraint(equalTo: inputsContainer.topAnchor, constant: -12).isActive = true
        sBtns.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        sBtns.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    var containerAnchor: NSLayoutConstraint?
    var nameTextAnchor: NSLayoutConstraint?
    var mailTextAnchor: NSLayoutConstraint?
    var passTextAnchor: NSLayoutConstraint?
    func containersSetup(){
        // ContainerView Constraints -> Constraints Anchors
        inputsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        containerAnchor = inputsContainer.heightAnchor.constraint(equalToConstant: 150) // Login segement
            containerAnchor?.isActive = true
        
        inputsContainer.addSubview(nameText)
        inputsContainer.addSubview(nameSeperator)
        // "nameText" TextField Constraints
        nameText.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true // "centerXAnchor"
        nameText.topAnchor.constraint(equalTo: inputsContainer.topAnchor).isActive = true // "centerYAnchor"
        nameText.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        nameTextAnchor = nameText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
            nameTextAnchor?.isActive = true
        
        // "nameSeperator" TextField Constraints
        nameSeperator.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor).isActive = true // "centerXAnchor"
        nameSeperator.topAnchor.constraint(equalTo: nameText.bottomAnchor).isActive = true // "centerYAnchor"
        nameSeperator.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        nameSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainer.addSubview(mailText)
        inputsContainer.addSubview(mailSeperator)
        // "mailText" TextField Constraints
        mailText.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true // "centerXAnchor"
        mailText.topAnchor.constraint(equalTo: nameText.bottomAnchor).isActive = true // "centerYAnchor"
        mailText.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        mailTextAnchor = mailText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        mailTextAnchor?.isActive = true
        
        // "mailSeperator" TextField Constraints
        mailSeperator.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor).isActive = true // "centerXAnchor"
        mailSeperator.topAnchor.constraint(equalTo: mailText.bottomAnchor).isActive = true // "centerYAnchor"
        mailSeperator.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        mailSeperator.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor).isActive = true
        
        inputsContainer.addSubview(passText)
        // "passText" TextField Constraints
        passText.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true // "centerXAnchor"
        passText.topAnchor.constraint(equalTo: mailText.bottomAnchor).isActive = true // "centerYAnchor"
        passText.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        passTextAnchor = passText.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        passTextAnchor?.isActive = true
    }
    
    func registerSetup(){
        // Button Constraints // Button Constraints
        btn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btn.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor, constant: 12).isActive = true
        btn.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func profileImageSetup(){
        // Image Constraints // Button Constraints
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: sBtns.topAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

// Selecting the profile picture
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    // If the registration was successful (User Authenticated)
    @objc func regHandler(){
        guard let email = mailText.text, let pass = passText.text, let username = nameText.text else{
            print("Invalid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: pass) { (authDataResult, error) in
            if error != nil{ // Successful Registration
                print(error as Any)
                return
            }
            
            let imgName = authDataResult!.user.uid // The image's name is the user's UID
            let storageRef = Storage.storage().reference().child("Profile_Images").child("\(imgName).png")
            if let uploadData = self.profileImage.image!.jpegData(compressionQuality: 0.1){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err{
                            print(err as Any)
                        }
                        else{
                            let profileImageUrl = url?.absoluteString
                            let uid = Auth.auth().currentUser?.uid
                            let values = ["name": username, "email": email, "password": pass, "profileImageUrl": profileImageUrl]
                            self.regUser(uid: uid!, values: values as [String: Any])
                        }
                    })
                })
            }
        }
    }
    // Uploading the user's Data to the Firebase Database
    private func regUser(uid: String, values: [String: Any]){
        let ref = Database.database().reference()
        let usersReference = ref.child("Users").child(uid)
        usersReference.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: { (err, ref) in
            if err != nil{ // The User was added to the database
                print(err as Any)
                return
            }
            self.msgController?.userDisplay()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func profileImageHandler(){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info) // Local variable inserted by Swift 4.2 migrator.
        var pickedImg: UIImage?
        
        if let editImg = info["UIImagePickerControllerEditedImage"] as? UIImage{
            pickedImg = editImg
        }
        else if let originImg = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            pickedImg = originImg
        }
        // Change the image in the Login Screen
        if let selectedProfImg = pickedImg{
            profileImage.image = selectedProfImg
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
