//
//  SharePhotoController.swift
//  DuoSnap
//
//  Created by Nasim on 10/1/17.
//  Copyright © 2017 Nasim. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage:UIImage? {
        didSet{
            self.imageView.image = selectedImage
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red:240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setUpImageAndTextViews()
    }
    
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    
    func setUpImageAndTextViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingRight: 0, paddingBottom: 8, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
    
    }
    
    @objc func handleShare(){
        guard let caption = textView.text, caption.characters.count > 0 else {return}
        guard let image = selectedImage else {return}
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        navigationItem.rightBarButtonItem?.isEnabled = false
    
    
        let fileName = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(fileName).putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image", err)
                return
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else {return}
            print("Successfully uplaoded post image",  imageUrl)
            
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String){
        guard let postImage = selectedImage else {return}
        
        guard let caption = textView.text else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB:", err)
                return
            }
            print("Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
}
