//
//  AboutViewController.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 11/12/24.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configEdit()
        loadProfileData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileData()
    }

    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "About"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let attributeText = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributeText
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.layer.masksToBounds = true
    }
    private func loadProfileData() {
        if let name = UserDefaults.standard.string(forKey: "userName") {
            nameLabel.text = name
        }
        if let imageData = UserDefaults.standard.data(forKey: "profileImage") {
            if let image = UIImage(data: imageData) {
                profileImageView.image = image
            }
        }
    }
    private func configEdit() {
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(didTapEditButton)
        )
        navigationItem.rightBarButtonItem = editButton
    }
    @objc
    private func didTapEditButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController {
            editProfileVC.name = nameLabel.text
            editProfileVC.profileImage = profileImageView.image
            navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
}
