import UIKit

protocol TeamEditMemberCellDelegate: class {
    func teamEditMemberCellDeletedClicked(cell: TeamEditMemberCell)
    func teamEditMemberCell(cell: TeamEditMemberCell, isAdminChanged: Bool)
}

class TeamEditMemberCell: BorderedCell {
    private var hasAwakened = false
    private var user: User?
    private var observer: FirebaseObserver<User>?
    private var isAdminInternal = false

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var adminButton: UIButton!

    weak var delegate: TeamEditMemberCellDelegate?
    var isAdmin: Bool {
        get {
            return self.isAdminInternal
        }
        set (value) {
            self.isAdminInternal = value
            if self.hasAwakened {
                self.adminButton.selected = value
            }
        }
    }

    deinit {
        self.dispose()
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setUid(uid: String) {
        if let user = self.user? {
            if user.uid == uid {
                // Already setup.
                return
            } else {
                self.dispose()
            }
        }
        let ref = User.createRef(uid)
        self.observer = FirebaseObserver<User>(query: ref, withBlock: { user in
            self.user = user
            self.updateView()
        })
    }

    @IBAction func deleteButtonClicked(sender: AnyObject) {
        if let delegate = self.delegate? {
            delegate.teamEditMemberCellDeletedClicked(self)
        }
    }

    @IBAction func adminButtonClicked(sender: AnyObject) {
        self.isAdmin = !self.isAdmin
        if let delegate = self.delegate? {
            delegate.teamEditMemberCell(self, isAdminChanged: self.isAdmin)
        }
    }

    private func updateView() {
        if self.hasAwakened {
            if let user = self.user? {
                self.nameLabel.text = user.fullName
                self.statusLabel.text = user.statusText
                self.statusLabel.textColor = Helpers.statusToColor(user.status)
                self.adminButton.selected = self.isAdmin
            } else {
                self.statusLabel.text = ""
                self.nameLabel.text = "Loading..."
            }
            self.adminButton.selected = self.isAdminInternal
        }
    }

    private func dispose() {
        if let observer = self.observer? {
            observer.dispose()
        }
    }
}