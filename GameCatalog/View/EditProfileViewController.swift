//
//  EditProfileViewController.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 18/12/24.
//

import UIKit
import Photos

class EditProfileViewController: UIViewController {
    var name: String?
    var profileImage: UIImage?
    @IBOutlet weak var profileName: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    func setup() {
        profileName.text = name
        profileImageView.image = profileImage
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let newName = profileName.text {
            UserDefaults.standard.set(newName, forKey: "userName")
            if let image = profileImageView.image, let imageData = image.jpegData(compressionQuality: 0.6) {
                UserDefaults.standard.set(imageData, forKey: "profileImage")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    @IBAction func chooseImageButtonTapped(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.allowsEditing = true
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                case .denied, .restricted:
                    let alert = UIAlertController(title: "Access Denied", message: "Please enable photo library access in Settings to choose a profile image.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                case .notDetermined:
                    break
                case .limited:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
