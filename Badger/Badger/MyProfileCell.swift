import UIKit

class MyProfileCell: BorderedCell {
    private var hasAwakened = false
    private var user: User?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setUser(user: User) {
        self.user = user
        self.profileCircle.setUid(user.uid)
        self.updateView()
    }

    private func updateView() {
        if self.user != nil && self.hasAwakened {
            self.statusLabel.textColor = Helpers.statusToColor(self.user!.status)
            self.statusLabel.text = self.user!.statusText
            self.nameLabel.text = self.user!.fullName
        }
    }
}
