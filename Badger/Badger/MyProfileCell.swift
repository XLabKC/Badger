import UIKit

class MyProfileCell: BorderedCell, StatusRecipient {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        if let user = self.user {
            StatusListener.sharedInstance().removeRecipient(self, uid: user.uid)
        }
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
        self.setTopBorder(.Full)
        self.setBottomBorder(.Full)
        self.setBorderColor(Color.colorize(0x0C0C0C, alpha: 1))
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
