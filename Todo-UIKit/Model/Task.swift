//
//  Task.swift
//  Todo-UIKit
//
//  Created by Toshiyana on 2022/06/04.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var orderOfItem: Int = 0

    override class func primaryKey() -> String? {
        return "id"
    }
}
