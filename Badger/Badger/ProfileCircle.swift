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

    func setUid(uid: String) {
        UserStore.sharedInstance().getUser(uid, withBlock: self.setUser)
    }

    func setUser(user: User) {
        if let user = self.user? {
            StatusListener.sharedInstance().removeRecipient(self, uid: user.uid)
        }
        self.user = user
        StatusListener.sharedInstance().addRecipient(self, uid: user.uid)
        self.statusUpdated(user.uid, newStatus: user.status)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutView()
    }

    func statusUpdated(uid: String, newStatus: UserStatus) {
        if let user = self.user {
            if let imagePath = user.profileImages[newStatus] {
                self.image = UIImage(named: imagePath)
            }
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        self.layer.borderColor = Helpers.statusToColor(newStatus).CGColor
        CATransaction.commit()
    }

    private func layoutView() {
        self.layer.cornerRadius = self.frame.height / 2.0
        if self.frame.height > 80 {
            self.layer.borderWidth = 4.0
        } else if self.frame.height > 60 {
            self.layer.borderWidth = 3.0
        } else {
            self.layer.borderWidth = 2.0
        }
    }
}
