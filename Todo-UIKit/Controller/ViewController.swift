//
//  ViewController.swift
//  Todo-UIKit
//
//  Created by Toshiyana on 2022/06/02.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var editButton: UIBarButtonItem!

    private var tasks: Results<Task>?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TaskCell.nib(), forCellReuseIdentifier: TaskCell.identifier)

        tasks = TaskManager.shared.loadTasks()
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
            TaskManager.shared.add(task: newTask)
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
        TaskManager.shared.sort(tasks: tasks, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete a task
            guard let task = tasks?[indexPath.row] else { return }
            TaskManager.shared.delete(task: task)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
