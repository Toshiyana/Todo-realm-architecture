//
//  TaskManager.swift
//  Todo-UIKit
//
//  Created by Toshiyana on 2022/06/04.
//

import Foundation
import RealmSwift

class TaskManager {
    static let shared = TaskManager()

    func loadTasks() -> Results<Task>? {
        guard let realm = try? Realm() else { return nil }
        return realm.objects(Task.self).sorted(byKeyPath: "orderOfItem")
    }

    func add(task: Task) {
        guard let realm = try? Realm() else { return }
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Error adding the task. \(error)")
        }
    }

    func delete(task: Task) {
        guard let realm = try? Realm() else { return }
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Error deleting the task. \(error)")
        }
    }

    func sort(tasks: Results<Task>?, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        guard let realm = try? Realm() else { return }
        do {
            try realm.write {
                let sourceItem = tasks?[sourceIndexPath.row]
                let destinationItem = tasks?[destinationIndexPath.row]

                let destinationItemOrder = destinationItem?.orderOfItem

                if sourceIndexPath.row < destinationIndexPath.row {
                    for index in sourceIndexPath.row ... destinationIndexPath.row {
                        tasks?[index].orderOfItem -= 1
                    }
                } else {
                    for index in (destinationIndexPath.row ..< sourceIndexPath.row).reversed() {
                        tasks?[index].orderOfItem += 1
                    }
                }

                guard let destOrder = destinationItemOrder else {
                    fatalError("destinationItemOrder does not exist.")
                }
                sourceItem?.orderOfItem = destOrder
            }
        } catch {
            print("Error moving the cell. \(error)")
        }
    }
}
