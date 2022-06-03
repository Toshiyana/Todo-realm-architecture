//
//  ViewController.swift
//  Todo-UIKit
//
//  Created by Toshiyana on 2022/06/02.
//

import UIKit
import RealmSwift

class Task: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var orderOfItem: Int = 0

    override class func primaryKey() -> String? {
        return "id"
    }
}

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var editButton: UIBarButtonItem!

    private var tasks: Results<Task>?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TaskCell.nib(), forCellReuseIdentifier: TaskCell.identifier)

        loadTasks()
        tableView.reloadData()
    }

    // MARK: - Action
    @IBAction private func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new task", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            // add new task
            let newTask = Task()
            newTask.title = textField.text!
            self.add(task: newTask)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    @IBAction private func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.isEditing = false
            editButton.title = "Edit"
        } else {
            tableView.isEditing = true
            editButton.title = "Done"
        }
    }

    private func loadTasks() {
        guard let realm = try? Realm() else { return }
        tasks = realm.objects(Task.self).sorted(byKeyPath: "orderOfItem")
    }

    private func add(task: Task) {
        guard let realm = try? Realm() else { return }
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Error adding the task. \(error)")
        }
    }

    private func delete(task: Task) {
        guard let realm = try? Realm() else { return }
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Error deleting the task. \(error)")
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        if let task = tasks?[indexPath.row] {
            cell.configure(titleText: task.title)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    // MARK: - Edit Cell
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // move cell in Editing mode
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete a task
            guard let task = tasks?[indexPath.row] else { return }
            delete(task: task)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
