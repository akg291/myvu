//
//  Constants.swift
//  HelloWorld
//
//  Created by MacPro on 16/08/2016.
//  Copyright © 2016 Aplos Inovations. All rights reserved.
//

import Foundation

struct APP_CONSTANTS {
    
    //MARK : - API LINKS
    struct API_CONSTANTS {
        let moviesContentUrl          = "/movies/all/0/25/all/all"
        let showsContentUrl           = "https://api-public.guidebox.com/v1.43/US/rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj/shows/all/0/25/all/all"
        static let BASE_URL           = "https://api-public.guidebox.com/v1.43/US/"
        static let API_TOKKEN         = "rKcbKIXDpGiF3GCCoDlhEq7u1BYp1tVj"
        static let MOVIES_CONTENT_URL = "/movies/all/"
        static let SHOWS_CONTENT_URL  = "/shows/all/"
        static let MOVIE_DETAILS_URL  = "/movie/"
        static let SHOW_DETAILS_URL   = "/show/"
        static let SOURCES            = "all"
        static let PLATFORMS          = "all"
        static let CHANNELS           = "all"
    }
    //MARK: - Keys
    struct KEY_CONSTANTS {
        static let VERIFICATION_CODE = "verification_code"
        static let USER_ID           = "user_id"
        static let TOKKEN            = "tokken"
    }
    //MARK: - Notification Keys
    struct NotificationKey {
        static let Welcome = "verification_code"
    }
    //MARK: - Directory Paths
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    //MARK: - Colors
    struct APP_COLOR {
        static let CURSOR_COLOR = 0x00bfc2
    }
}
