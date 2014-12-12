import UIKit

class TeamMemberCell: BorderedCell, UserObserver {
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

    deinit {
        if let user = self.user? {
            UserStore.sharedInstance().removeObserver(self, uid: user.uid)
        }
    }

    func setUser(user: User) {
        if let user = self.user? {
            UserStore.sharedInstance().removeObserver(self, uid: user.uid)
        }
        UserStore.sharedInstance().addObserver(self, uid: user.uid)
        if self.hasAwakened {
            self.profileCircle.setUser(user)
        }
    }

    func getUser() -> User? {
        return self.user
    }

    func userUpdated(newUser: User) {
        self.user = newUser
        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                self.statusLabel.text = Helpers.statusToText(user, status: user.status)
                self.statusLabel.textColor = Helpers.statusToColor(user.status)
                self.nameLabel.text = user.fullName
                self.metaLabel.text = "\(user.activeTasks) Active Tasks"
            }
        }
    }
}
