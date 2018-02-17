//
//  Category.swift
//  Todoey
//
//  Created by cn on 2/16/18.
//  Copyright © 2018 nicolinihome. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    var items = List<Item>()
}
