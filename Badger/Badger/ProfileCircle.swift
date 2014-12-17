import UIKit


class ProfileCircle: UIImageView, UserObserver {
    var status = UserStatus.Unknown
    var user: User?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layoutView()
    }

    deinit {
        if let user = self.user? {
            UserStore.sharedInstance().removeObserver(self, uid: user.uid)
        }
    }

    func setUid(uid: String) {
        UserStore.sharedInstance().getUser(uid, withBlock: self.setUser)
    }

    func setUser(user: User) {
        if let old = self.user? {
            // Make sure the old and new user are actually different.
            if old.uid == user.uid {
                return
            }
            UserStore.sharedInstance().removeObserver(self, uid: user.uid)
        }
        UserStore.sharedInstance().addObserver(self, uid: user.uid)
        self.userUpdated(user)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutView()
    }

    func userUpdated(newUser: User) {
        self.user = newUser
        if let imagePath = newUser.profileImages[newUser.status] {
            self.image = UIImage(named: imagePath)
        }
        self.layer.borderColor = Helpers.statusToColor(newUser.status).CGColor
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
