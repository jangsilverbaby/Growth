//
//  ProfileInfoManager.swift
//  Growth
//
//  Created by eunae on 2021/09/30.
//

import UIKit

struct ProfileInfoKey {
    // 저장에 사용할 키
    static let profileId = "PROFILEID"
    static let profileImg = "PROFILEIMG"
    static let name = "NAME"
    static let startDate = "STARTDATE"
    static let isAlert = "ISALERT"
    static let alertCycle = "ALERTCYCLE"
    static let alertTime = "ALERTTIME"
}

// 프로필 정보를 저장, 관리하는 클래스
class ProfileInfoManager {
    var profileId: Int {
        get {
            return UserDefaults.standard.integer(forKey: ProfileInfoKey.profileId)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: ProfileInfoKey.profileId)
            ud.synchronize()
        }
    }
    
    var profileImg: UIImage? {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: ProfileInfoKey.profileImg) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account.jpg") // 이미지가 없다면 기본 이미지로
            }
        }
        set(v) {
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v!.pngData(), forKey: ProfileInfoKey.profileImg)
                ud.synchronize()
            }
        }
    }
    
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: ProfileInfoKey.name)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: ProfileInfoKey.name)
            ud.synchronize()
        }
    }
    
    var startDate: Date {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.string(forKey: ProfileInfoKey.startDate) {
                let dateString:String = _profile
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy.MM.dd"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                let date:Date = dateFormatter.date(from: dateString)!
                return date
            } else {
                return Date()
            }
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: ProfileInfoKey.startDate)
            ud.synchronize()
        }
    }
    
    var isAlert: Bool {
        get {
            return UserDefaults.standard.bool(forKey: ProfileInfoKey.isAlert)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: ProfileInfoKey.isAlert)
            ud.synchronize()
        }
    }
    
    var alertCycle: String? {
        get {
            return UserDefaults.standard.string(forKey: ProfileInfoKey.alertCycle)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: ProfileInfoKey.alertCycle)
            ud.synchronize()
        }
    }
    
    var alertTime: Date {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.string(forKey: ProfileInfoKey.alertTime) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                return dateFormatter.date(from: _profile)!
            } else {
                return Date()
            }
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: ProfileInfoKey.alertTime)
            ud.synchronize()
        }
    }
}
