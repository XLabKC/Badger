import UIKit

class UserCell: BorderedCell, UserObserver {
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
        if let user = self.user? {
            UserStore.sharedInstance().removeObserver(self, uid: user.uid)
        }
        self.user = user
        UserStore.sharedInstance().addObserver(self, uid: user.uid)
        if self.hasAwakened {
            self.profileCircle.setUser(user)
            self.updateView()
        }
    }

    func userUpdated(newUser: User) {
        self.user = newUser
        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                self.nameLabel.text = user.fullName
                self.statusLabel.text = Helpers.statusToText(user, status: user.status)
                self.statusLabel.textColor = Helpers.statusToColor(user.status)
            } else {
                self.statusLabel.text = ""
                self.nameLabel.text = "Loading..."
            }
        }
    }
}