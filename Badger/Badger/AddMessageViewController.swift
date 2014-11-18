import UIKit

class AddMessageViewController: UIViewController {

    var user: User?

    override func viewDidLoad() {
    }

    func setUser(user: User) {
        self.user = user
    }

    @IBAction func addMessage(sender: AnyObject) {
        if let user = self.user {
            let messageRef = Firebase(url: Global.FirebaseMessagesUrl).childByAppendingPath(user.uid)
            let message = [
                "author": messageRef.authData.uid,
                "content": "Some new message content goes here",
                "open": true,
                "priority": 3
            ]
            let messageIdRef = messageRef.childByAutoId()
            let newMessageRef = Firebase(url: Global.FirebaseNewMessagesUrl).childByAppendingPath(messageIdRef.name)
            messageIdRef.setValue(message)
            newMessageRef.setValue(user.uid)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}