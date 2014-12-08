class ApiKeys {
    private class func sharedInstance() -> ApiKeys {
        struct Static {
            static var instance: ApiKeys?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = ApiKeys()
        }
        return Static.instance!
    }

    let keys: [NSObject: AnyObject]

    init() {
        if let path = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist")? {
            self.keys = NSDictionary(contentsOfFile: path)!
        } else {
            println("Unable to locate: ApiKeys.plist")
            self.keys = [:]
        }

    }

    class func getGoogleClientId() -> String {
        let apiKeys = ApiKeys.sharedInstance()
        return apiKeys.keys["GoogleClientId"] as String
    }
}