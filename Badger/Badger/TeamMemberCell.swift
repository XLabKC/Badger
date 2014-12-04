import UIKit

class TeamMemberCell: BorderedCell, StatusRecipient {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.hasAwakened = true
        self.setBottomBorder(.Full)
        self.setBorderColor(Color.colorize(0xE0E0E0, alpha: 1))
        if let user = self.user? {
            self.profileCircle.setUser(user)
            self.updateView()
        }
    }

    func setUser(user: User) {
        if let user = self.user? {
            StatusListener.sharedInstance().removeRecipient(self, uid: user.uid)
        }
        self.user = user
        StatusListener.sharedInstance().addRecipient(self, uid: user.uid)

        if self.hasAwakened {
            self.profileCircle.setUser(user)
            self.updateView()
        }
    }

    func getUser() -> User? {
        return self.user
    }

    func statusUpdated(uid: String, newStatus: UserStatus) {
        self.statusLabel.text = Helpers.statusToText(user, status: newStatus)
        self.statusLabel.textColor = Helpers.statusToColor(newStatus)
    }

    private func updateView() {
        if let user = self.user? {
            self.statusUpdated(user.uid, newStatus: user.status)
            self.nameLabel.text = user.fullName
            self.metaLabel.text = "Unknown" // TODO: set date
        }
    }
}
