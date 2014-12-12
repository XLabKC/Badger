import UIKit

class MyProfileCell: BorderedCell, UserObserver {
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
            UserStore.sharedInstance().removeObserver(self, uid: user.uid)
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
        if let user = self.user? {
            UserStore.sharedInstance().removeObserver(self, uid: user.uid)
        }
        self.user = user
        UserStore.sharedInstance().addObserver(self, uid: user.uid)
        self.profileCircle.setUser(user)
        self.updateView()
    }

    func userUpdated(newUser: User) {
        self.user = newUser
        self.updateView()
    }

    private func updateView() {
        if self.user != nil && self.hasAwakened {
            self.statusLabel.textColor = Helpers.statusToColor(self.user!.status)
            self.statusLabel.text = Helpers.statusToText(self.user!, status: self.user!.status)
            self.nameLabel.text = self.user!.fullName
        }
    }
}
