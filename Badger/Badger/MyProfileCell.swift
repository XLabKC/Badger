import UIKit

class MyProfileCell: UITableViewCell, StatusRecipient {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    deinit {
        if let user = self.user {
            StatusListener.sharedInstance().removeRecipient(self, uid: user.uid)
        }
    }

    func setUser(user: User) {
        StatusListener.sharedInstance().addRecipient(self, uid: user.uid)
        self.user = user
        self.profileCircle.setUser(user)
        self.updateView()
    }

    func statusUpdated(uid: String, newStatus: UserStatus) {
        self.statusLabel.textColor = Helpers.statusToColor(newStatus)
        self.statusLabel.text = Helpers.statusToText(self.user, status: newStatus)
    }

    private func updateView() {
        if self.user != nil && self.hasAwakened {
            self.statusUpdated(self.user!.uid, newStatus: self.user!.status)
            self.nameLabel.text = self.user!.fullName
        }
    }
}
