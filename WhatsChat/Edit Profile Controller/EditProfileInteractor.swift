import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

protocol EditProfileInteracting: AnyObject {
    func confirmPressed(name: String?, email: String?, bio: String)
    func changeImage(image: UIImage)
}

final class EditProfileInteractor: EditProfileInteracting {
    private let presenter: EditProfilePresenting
    private var auth: Auth?
    private var firestore: Firestore?
    private var storage: Storage?
    private var userID: String = ""
    
    init(presenter: EditProfilePresenting) {
        self.presenter = presenter
        auth = Auth.auth()
        firestore = Firestore.firestore()
        storage = Storage.storage()
        
        if let id = auth?.currentUser?.uid {
            self.userID = id
        }
    }
    
    func confirmPressed(name: String?, email: String?, bio: String) {
        let currentUser = auth?.currentUser
        if let safeEmail = email, let safeName = name {
            currentUser?.updateEmail(to: safeEmail, completion: { error in
                if let error = error {
                    print("Email not changed")
                } else {
                    print("CHANGED EMAIL")
                    self.firestore?.collection("users")
                        .document(self.userID)
                        .updateData(["email": safeEmail, "name": safeName])
                }
            })
        }
        if bio != "" {
            firestore?.collection("users")
                .document(userID)
                .updateData(["bio": bio])
            presenter.confirmPressed()
        } else {
            print("At least change your bio to confirm changes")
        }
    }
    
    func changeImage(image: UIImage) {
        let images = storage?.reference().child("images")
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else {return}
        guard let userID = auth?.currentUser?.uid else {return}
        let imageName = ("\(userID).jpg")
        guard let profileImageRef = images?.child("profile").child(imageName) else {return}
        
        profileImageRef.putData(uploadImage, metadata: nil, completion: { (metaData, error) in
            if error == nil {
                profileImageRef.downloadURL { url, error in
                    guard let imageUrl = url?.absoluteString else {return}
                    self.firestore?.collection("users")
                        .document(userID)
                        .updateData(["imageUrl": imageUrl])
                }
            }
        })
    }
}


