
protocol StatusRecipient: class {
    func statusUpdated(uid: String, newStatus: UserStatus)
}

class StatusListener {

    // Accesses the singleton.
    class func sharedInstance() -> StatusListener {
        struct Static {
            static var instance: StatusListener?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = StatusListener()
        }
        return Static.instance!
    }

    private var recipientCount: [String: Int] = [:]
    private var recipientsByUid: [String: [WeakRecipient]] = [:]
    private var handlesByUid: [String: UInt] = [:]
    private var ref = Firebase(url: Global.FirebaseUsersUrl)


    init() {

    }

    func addRecipient(recipient: StatusRecipient, uid: String) {
        var recipients = recipientsByUid[uid]

        if recipients == nil || recipients!.count == 0 {
            recipientsByUid[uid] = [WeakRecipient(recipient: recipient)]

            // Start listening for this status.
            let statusRef = ref.childByAppendingPath(uid).childByAppendingPath("status")
            let closure = self.statusUpdated
            handlesByUid[uid] = statusRef.observeEventType(.Value, withBlock: self.statusUpdated)
        } else {
            recipients!.append(WeakRecipient(recipient: recipient))
        }
    }

    func removeRecipient(recipient: StatusRecipient, uid: String) {
        if var recipients = recipientsByUid[uid]? {
            for (index, weakRecipient) in enumerate(recipients) {
                if weakRecipient.recipient === recipient {
                    recipients.removeAtIndex(index)
                    break
                }
            }
            if recipients.count == 0 {
                self.stopListening(uid)
            }
        }
    }

    private func statusUpdated(snapshot: FDataSnapshot!) {
        let uid = snapshot.ref.parent.name

        var status = UserStatus(rawValue: snapshot.value as String!)
        if status == nil {
            status = .Unknown
        }

        if let recipients = recipientsByUid[uid]? {
            if recipients.count > 0 {
                var valid: [WeakRecipient] = []
                for weakRecipient in recipients {
                    if let recipient = weakRecipient.recipient? {
                        recipient.statusUpdated(uid, newStatus: status!)
                        valid.append(weakRecipient)
                    }
                }
                recipientsByUid[uid] = valid

                // Check to make sure that there were at least one valid
                // listener. Otherwise, stop listening.
                if valid.count > 0 {
                    return
                }
            }
        }

        // There are no recipients, remove observer.
        self.stopListening(uid)
    }

    private func stopListening(uid: String) {
        if let handle = handlesByUid[uid]? {
            self.ref.removeObserverWithHandle(handle)
        }
    }
}


struct WeakRecipient {
    weak var recipient: StatusRecipient?
    init(recipient: StatusRecipient) {
        self.recipient = recipient
    }
}