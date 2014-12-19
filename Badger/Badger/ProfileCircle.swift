import UIKit


class ProfileCircle: UIImageView {
    var status = UserStatus.Unknown
    var user: User?
    var observer: FirebaseObserver<User>?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.layer.borderColor = Colors.UnknownStatus.CGColor
        self.layoutView()
    }

    deinit {
        self.dispose()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutView()
    }

    func setUid(uid: String) {
        if let old = self.user? {
            if old.uid == uid {
                // Already setup.
                return
            } else {
                self.dispose()
            }
        }
        let ref = User.createRef(uid)
        self.observer = FirebaseObserver<User>(query: ref, withBlock: self.userUpdated)
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

    private func dispose() {
        if let observer = self.observer? {
            observer.dispose()
        }
    }
}
