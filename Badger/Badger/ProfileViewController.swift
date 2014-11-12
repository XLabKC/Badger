import UIKit

class ProfileViewController: UIViewController {

    var statusHandle: UInt
    var statusRef: Firebase?
    var user: User?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        self.statusHandle = 0
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
    }

    func setUid(uid: String) {
        let uidRef = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(uid)
        uidRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.setUser(User.createUserFromSnapshot(snapshot))
        })
    }

    func setUser(user: User) {
        if let statusRef = self.statusRef? {
            statusRef.removeObserverWithHandle(statusHandle)
        }
        self.user = user
        self.updateView()

        if let uidRef = user.uidRef {
            self.statusRef = uidRef.childByAppendingPath("status")
            self.statusHandle = statusRef!.observeEventType(.Value, withBlock: { (snapshot) in
                self.setStatus(snapshot.value as String)
            })
        }
    }

    private func updateView() {
        if let user = self.user {
            if self.nameLabel != nil {
                self.nameLabel.text = user.full_name
            }
            self.setStatus(user.status)
        }
    }

    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    private func setStatus(status:String) {
        self.view.backgroundColor = Helpers.statusToColor(status)
        if self.statusLabel != nil {
            self.statusLabel.text = status
        }
    }
}
