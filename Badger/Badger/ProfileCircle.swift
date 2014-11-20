import UIKit


class ProfileCircle: UIImageView, StatusRecipient {
    var status = UserStatus.Unknown
    var uid: String?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layoutView()
    }

    func setUid(uid: String) {
        UserStore.sharedInstance().getUser(uid, withBlock: self.setUser)
    }

    func setUser(user: User) {
        if let uid = self.uid? {
            StatusListener.sharedInstance().removeRecipient(self, uid: uid)
        }
        self.uid = user.uid
        StatusListener.sharedInstance().addRecipient(self, uid: user.uid)
        self.statusUpdated(user.uid, newStatus: user.status)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutView()
    }

    func statusUpdated(uid: String, newStatus: UserStatus) {
        self.layer
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        self.layer.borderColor = Helpers.statusToColor(newStatus).CGColor
        CATransaction.commit()
    }

    private func layoutView() {
        self.layer.cornerRadius = self.frame.height / 2.0
        self.layer.borderWidth = (self.frame.height > 80) ? 4.0 : 2.0
    }
}