import UIKit

class TeamMemberCell: BorderedCell {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.hasAwakened = true
        self.updateView()
    }

    func setUser(user: User) {
        self.user = user
        self.updateView()
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
                self.profileCircle.setUid(user.uid)
                self.statusLabel.text = Helpers.statusToText(user, status: user.status)
                self.statusLabel.textColor = Helpers.statusToColor(user.status)
                self.nameLabel.text = user.fullName
                self.metaLabel.text = "\(user.activeTaskCount) Active Tasks"
            }
        }
    }
}
