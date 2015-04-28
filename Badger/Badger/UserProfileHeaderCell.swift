import UIKit
import Haneke

class UserProfileHeaderCell: UITableViewCell {

    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setUser(user: User) {
        self.user = user
        self.updateView()
    }

    @IBAction func logout(sender: AnyObject) {
        Firebase(url: Global.FirebaseUrl).unauth()
    }

    private func updateView() {
        if self.hasAwakened {
            // 656x448
            if let user = self.user {
                self.nameLabel.text = user.fullName
                self.profileCircle.setUid(user.uid)
                self.statusLabel.text = user.statusText
                self.statusLabel.textColor = Helpers.statusToColor(user.status)

                // Set the header background image.
                let placeholder = UIImage(named: "DefaultBackground")
                if user.headerImage != "" {
                    let url = Helpers.getHeaderImageUrl(user.headerImage)
                    self.backgroundImage.hnk_setImageFromURL(url, placeholder: placeholder, format: nil, failure: nil, success: nil)
                } else {
                    self.backgroundImage.image = placeholder
                }
            }
        }
    }
}
