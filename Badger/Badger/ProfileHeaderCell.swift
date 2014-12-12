import UIKit

class ProfileHeaderCell: UITableViewCell, UserObserver {

    private var uid: String?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUser(user: User) {
        if let uid = self.uid? {
            UserStore.sharedInstance().removeObserver(self, uid: uid)
        }
        self.uid = user.uid
        UserStore.sharedInstance().addObserver(self, uid: user.uid)

        self.setStatusLabel(user.status)
        if let nameLabel = self.nameLabel? {
            nameLabel.text = user.fullName
        }
        if let profileCircle = self.profileCircle? {
            profileCircle.setUser(user)
        }
        // TODO: Set profile and background images.
    }

    func userUpdated(newUser: User) {
        self.setStatusLabel(newUser.status)
    }

    private func setStatusLabel(status: UserStatus) {
        if let label = self.statusLabel? {
            label.text = Helpers.statusToText(nil, status: status)
            label.textColor = Helpers.statusToColor(status)
        }
    }
}
