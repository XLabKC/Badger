import UIKit


class ProfileCircle: UIImageView, StatusRecipient {
    var status = UserStatus.Unknown
    var user: User?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layoutView()
    }

    func setUser(user: User) {
        self.user = user
        // TODO: Set profile image
        StatusListener.sharedInstance().addRecipient(self, uid: user.uid)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutView()
    }

    func statusUpdated(uid: String, newStatus: UserStatus) {

    }

    private func layoutView() {
        self.layer.cornerRadius = self.frame.height / 2.0
        self.layer.borderWidth = (self.frame.height > 80) ? 4.0 : 2.0
    }
}