import UIKit

class ProfileControlsCell: BorderedCell {
    private var hasAwakened = false
    private var user: User?
    private var authUser: User?
    private var observer: FirebaseObserver<User>?

    @IBOutlet weak var subscribeButton: ResizedImageButton!

    deinit {
        if let observer = self.observer? {
            observer.dispose()
        }
    }

    @IBAction func subscribedPressed(sender: AnyObject) {
        if let user = self.user? {
            if let authUser = self.authUser? {
                if authUser.followingIds[user.uid] == nil {
                    // Start following user.
                    UserStore.followUser(authUser.uid, otherUid: user.uid)
                } else {
                    // Stop following user.
                    UserStore.unFollowUser(authUser.uid, otherUid: user.uid)
                }
            }
        }
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        let authUid = UserStore.sharedInstance().getAuthUid()
        self.observer = FirebaseObserver<User>(query: User.createRef(authUid), withBlock: { user in
            self.authUser = user
            self.updateView()
        })
    }

    func setUser(user: User) {
        self.user = user
        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                if let authUser = self.authUser? {
                    self.subscribeButton.selected = authUser.followingIds[user.uid] != nil
                }
            }
        }
    }
}