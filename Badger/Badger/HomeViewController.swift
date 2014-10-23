import UIKit

class HomeViewController: UITableViewController {

    let profileTableCell: ProfileTableCell

    required init(coder aDecoder: NSCoder) {
        let nib = UINib(nibName: "ProfileTableCell", bundle: nil)
        profileTableCell = nib.instantiateWithOwner(nil, options: nil)[0] as ProfileTableCell
        profileTableCell.setup()
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "UserTableCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "UserTableCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Table View Delegates

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            if let window = self.view.window? {
                return window.frame.height
            }
        }
        return 44
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return profileTableCell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableCell", forIndexPath: indexPath) as UITableViewCell
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

}
