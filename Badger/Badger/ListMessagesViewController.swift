import UIKit

class ListMessagesViewController: UITableViewController {

    var async: FirebaseAsync?
    var messageRef: Firebase?
    var user: User?
    var tasks: [Task] = []

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setUser(user: User) {
        if let async = self.async? {
            async.detach()
        }
        if let messageRef = self.messageRef {
            messageRef.removeAllObservers()
        }
        self.user = user
        self.messageRef = Firebase(url: Global.FirebaseMessagesUrl).childByAppendingPath(user.uid)

        // Load all messages.
        self.async = FirebaseAsync.observeEventType(self.messageRef!, eventType: .ChildAdded,
            forEach: { (snapshot, isNew) -> () in
                self.tasks.append(Task.createTaskFromSnapshot(snapshot))
                if (isNew) {
                    self.tableView.reloadData()
                }
        }, afterInitial: { () -> () in
            self.tableView.reloadData()
        })

        // Listen for updates.
        self.messageRef?.observeEventType(.ChildChanged, withBlock: { snapshot in
            let updated = Task.createTaskFromSnapshot(snapshot)
            for (index, message) in enumerate(self.tasks) {
                if message.id == updated.id {
                    self.tasks[index] = updated
                    self.tableView.reloadData()
                    break
                }
            }
        })

        // Listen for removals.
        self.messageRef?.observeEventType(.ChildRemoved, withBlock: { snapshot in
            let removed = Task.createTaskFromSnapshot(snapshot)
            for (index, message) in enumerate(self.tasks) {
                if message.id == removed.id {
                    self.tasks.removeAtIndex(index)
                    self.tableView.reloadData()
                    break
                }
            }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is AddMessageViewController && self.user != nil {
            let vc = segue.destinationViewController as AddMessageViewController
            vc.setUser(self.user!)
        }
    }

    // Table View Delegates

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let calculationView = UITextView()
        calculationView.text = self.tasks[indexPath.row].content
        let size = calculationView.sizeThatFits(CGSizeMake(self.view.frame.width, CGFloat(FLT_MAX)))
        return size.height + 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as UITableViewCell
        let textView = cell.viewWithTag(100) as UITextView
        textView.text = self.tasks[indexPath.row].content
        return cell
    }


}
