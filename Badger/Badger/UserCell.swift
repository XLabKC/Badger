import UIKit

class UserCell: BorderedCell, StatusRecipient {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setUid(uid: String) {
        self.user = nil
        self.updateView()
        UserStore.sharedInstance().getUser(uid, withBlock: { user in
            self.setUser(user)
        })
    }

    func setUser(user: User) {
        self.user = user
        self.updateView()
    }

    func statusUpdated(uid: String, newStatus: UserStatus) {
        if let user = self.user? {
            self.statusLabel.text = Helpers.statusToText(user, status: newStatus)
            self.statusLabel.textColor = Helpers.statusToColor(newStatus)
        } else {
            self.statusLabel.text = ""
        }
    }

    private func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                self.profileCircle.setUser(user)
                self.nameLabel.text = user.fullName
                StatusListener.sharedInstance().addRecipient(self, uid: user.uid)
            } else {
                self.statusLabel.text = ""
                self.nameLabel.text = "Loading..."
            }
        }
    }
}