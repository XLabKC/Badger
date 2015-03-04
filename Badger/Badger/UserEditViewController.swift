import UIKit

private enum Rows: Int {
    case ProfileHeader = 0
    case FirstName = 1
    case LastName = 2
    case Email = 3
    case Images = 4
    case StatusHeader = 5
    case FreeStatus = 6
    case OccupiedStatus = 7
    case UnavailableStatus = 8
}

class UserEditViewController: UITableViewController, InputCellDelegate {
    private let headerCellHeight: CGFloat = 40.0
    private let editImagesCellHeight: CGFloat = 154.0
    private let normalCellHeight: CGFloat = 72.0

    private var cells = [UITableViewCell?](count: 9, repeatedValue: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cells.
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        let userProfileHeaderCellNib = UINib(nibName: "UserProfileHeaderCell", bundle: nil)
        self.tableView.registerNib(userProfileHeaderCellNib, forCellReuseIdentifier: "UserProfileHeaderCell")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        let editImagesCellNib = UINib(nibName: "EditImagesCell", bundle: nil)
        self.tableView.registerNib(editImagesCellNib, forCellReuseIdentifier: "EditImagesCell")

        let textFieldCellNib = UINib(nibName: "TextFieldCell", bundle: nil)
        self.tableView.registerNib(textFieldCellNib, forCellReuseIdentifier: "TextFieldCell")

        // Set up navigation bar.
        self.navigationItem.titleView = Helpers.createTitleLabel("Edit Profile")
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Header + First Name + Last Name + Email + Images + Header + Free + Occupied + Unavailable
        return 9
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellForIndex(indexPath.row)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 5 {
            return self.headerCellHeight
        }
        if indexPath.row == 4 {
            return self.editImagesCellHeight
        }
        return self.normalCellHeight
    }

    @IBAction func cancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneClicked(sender: AnyObject) {

    }

    // InputCellDelegate: opens the next cell when the "next" key is pressed on the keyboard.
    func shouldSelectNext(cell: InputCell) {
        cell.closeKeyboard()
    }

    func cellDidBeginEditing(cell: InputCell) {
        var indexPath = NSIndexPath(forRow: self.indexForCell(cell), inSection: 0)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }

    private func cellForIndex(index: Int) -> UITableViewCell {
        if let cell = self.cells[index]? {
            return cell
        }
        let user = UserStore.sharedInstance().getAuthUser()
        let borderColor = Color.colorize(0xE1E1E1, alpha: 1.0)

        let row = Rows(rawValue: index)!
        switch (row) {
        case .ProfileHeader, .StatusHeader:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            cell.title = index == 0 ? "MY PROFILE" : "STATUSES"
            cell.labelColor = Color.colorize(0x929292, alpha: 1.0)
            self.cells[index] = cell
            return cell
        case .FirstName:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as TextFieldCell
            cell.delegate = self
            cell.label.text = "My First Name"
            cell.textField.placeholder = "First Name"
            cell.textField.text = user.firstName
            cell.textField.returnKeyType = .Done
            cell.borderColor = borderColor
            cell.topBorderStyle = "full"
            cell.bottomBorderStyle = "inset"
            self.cells[index] = cell
            return cell
        case .LastName:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as TextFieldCell
            cell.delegate = self
            cell.label.text = "My Last Name"
            cell.textField.placeholder = "Last Name"
            cell.textField.text = user.lastName
            cell.textField.returnKeyType = .Done
            cell.borderColor = borderColor
            cell.bottomBorderStyle = "inset"
            self.cells[index] = cell
            return cell
        case .Email:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as TextFieldCell
            cell.delegate = self
            cell.label.text = "Email"
            cell.textField.placeholder = "example@gmail.com"
            cell.textField.text = user.email
            cell.textField.returnKeyType = .Done
            self.cells[index] = cell
            return cell
        case .Images:
            let cell = tableView.dequeueReusableCellWithIdentifier("EditImagesCell") as EditImagesCell
            cell.logoLabel.text = "Profile Photo"
            cell.logoImage.image = UIImage(named: user.profileImages[.Free]!)
            cell.headerImage.image = UIImage(named: user.headerImage)
            self.cells[index] = cell
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as TextFieldCell
            let statuses: [UserStatus] = [.Free, .Occupied, .Unavailable]
            let labels = ["Default Available Status", "Default Away Status", "Default Unavailable Status"]
            let statusIndex = index - Rows.FreeStatus.rawValue
            let status = statuses[statusIndex]

            cell.delegate = self
            cell.textField.placeholder = "Status"
            cell.textField.text = user.textStatuses[status]
            cell.textField.textColor = Helpers.statusToColor(status)
            cell.textField.returnKeyType = .Done
            cell.label.text = labels[statusIndex]
            cell.label.textColor = Color.colorize(0x929292, alpha: 1.0)
            cell.borderColor = Color.colorize(0xE1E1E1, alpha: 1.0)


            if row == .UnavailableStatus {
                cell.bottomBorderStyle = "full"
            } else {
                cell.bottomBorderStyle = "inset"
                if row == .FreeStatus {
                    cell.topBorderStyle = "full"
                }
            }

            self.cells[index] = cell
            return cell
        }
    }

    private func indexForCell(cell: UITableViewCell) -> Int {
        let count = tableView.numberOfRowsInSection(0)

        for var i = 0; i < count; i++ {
            let cellToCheck = self.cellForIndex(i)
            if cellToCheck == cell {
                return i
            }
        }
        return -1
    }

}
