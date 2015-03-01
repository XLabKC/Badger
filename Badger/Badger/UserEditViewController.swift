import UIKit

class UserEditViewController: UITableViewController {
//    private let headerCellHeight: CGFloat = 225.0
    private let headerCellHeight: CGFloat = 40
    private let editInfoCellHeight: CGFloat = 226.0
    private let editStatusCellHeight: CGFloat = 72.0

    private var cells = [UITableViewCell?](count: 5, repeatedValue: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cells.
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        let userProfileHeaderCellNib = UINib(nibName: "UserProfileHeaderCell", bundle: nil)
        self.tableView.registerNib(userProfileHeaderCellNib, forCellReuseIdentifier: "UserProfileHeaderCell")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        let editProfileInfoCellNib = UINib(nibName: "EditProfileInfoCell", bundle: nil)
        self.tableView.registerNib(editProfileInfoCellNib, forCellReuseIdentifier: "EditProfileInfoCell")

        // Set up navigation bar.
        self.navigationItem.titleView = Helpers.createTitleLabel("Edit Profile")
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Header + Info + Free + Occupied + Unavailable
        return 5
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellForIndex(indexPath.row)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return self.headerCellHeight
        }
        if indexPath.row == 1 {
            return self.editInfoCellHeight
        }
        return self.editStatusCellHeight
    }

    @IBAction func cancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneClicked(sender: AnyObject) {

    }

    private func cellForIndex(index: Int) -> UITableViewCell {
        if let cell = self.cells[index]? {
            return cell
        }
        let user = UserStore.sharedInstance().getAuthUser()

        switch (index) {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            cell.title = "MY PROFILE"
            cell.labelColor = Color.colorize(0x929292, alpha: 1.0)
            return cell

//            let cell = tableView.dequeueReusableCellWithIdentifier("UserProfileHeaderCell") as UserProfileHeaderCell
//            cell.setUser(user)
//            self.cells[index] = cell
//            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("EditProfileInfoCell") as EditProfileInfoCell
            cell.nameLabel.text = "My Name"
            cell.logoLabel.text = "Profile Photo"
            cell.name = user.fullName
//            cell.showNameCellBackground = true
            self.cells[index] = cell
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserAvailabilityCell") as UserAvailabilityCell
            let statuses: [UserStatus] = [.Free, .Occupied, .Unavailable]
            let labels = ["Default Available Status", "Default Away Status", "Default Unavailable Status"]
            let status = statuses[index - 2]

            cell.statusTextField.text = user.textStatuses[status]
            cell.statusTextField.textColor = Helpers.statusToColor(status)
            cell.statusLabel.text = labels[index - 2]

            if status == .Unavailable {
                cell.bottomBorderStyle = "full"
            }

            self.cells[index] = cell
            return cell
        }
    }
}
