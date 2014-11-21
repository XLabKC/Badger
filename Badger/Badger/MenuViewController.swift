import UIKit

class MenuViewController: UITableViewController {

    let logoCellHeight: CGFloat = 46.0
    let contentCellHeight: CGFloat = 72.0
    let headerCellHeight: CGFloat = 40.0

    override func viewDidLoad() {
        let userTableNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(userTableNib, forCellReuseIdentifier: "HeaderCell")
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return self.logoCellHeight
        } else if (indexPath.row == 1 || indexPath.row == 3) {
            return self.headerCellHeight
        }
        return self.contentCellHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return tableView.dequeueReusableCellWithIdentifier("LogoCell") as UITableViewCell
        } else if (indexPath.row == 1 || indexPath.row == 3) {
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            switch (indexPath.row) {
            case 1:
                cell.title = "MY PROFILE"
            case 3:
                cell.title = "MY TEAMS"
            default:
                cell.title = "SETTINGS"
            }
            return cell
        } else if (indexPath.row == 2) {
            return tableView.dequeueReusableCellWithIdentifier("MyProfileCell") as UITableViewCell
        }
        return tableView.dequeueReusableCellWithIdentifier("MyProfileCell") as UITableViewCell
    }
}