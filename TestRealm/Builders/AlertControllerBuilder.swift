//
//  AlertControllerBuilder.swift
//  TestRealm
//
//  Created by Alexey Turulin on 8/8/23.
//

import UIKit

final class AlertControllerBuilder {
    private let alertController: UIAlertController
    
    init(title: String, message: String) {
        alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
    }
    
    func setTextField(_ title: String?) -> AlertControllerBuilder {
        alertController.addTextField { textField in
            textField.placeholder = "List Title"
            textField.text = title
        }
        return self
    }
    
    func setTextFields(title: String?, note: String?) -> AlertControllerBuilder {
        alertController.addTextField { textField in
            textField.placeholder = "Task Title"
            textField.text = title
        }
        alertController.addTextField { textField in
            textField.placeholder = "Note Title"
            textField.text = note
        }
        return self
    }
    
    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style, handler: ((String, String) -> Void)? = nil) -> AlertControllerBuilder {
        let action = UIAlertAction(title: title, style: style) { [weak alertController] _ in
            guard let title = alertController?.textFields?.first?.text else { return }
            guard !title.isEmpty else { return }
            let note = alertController?.textFields?.last?.text
            handler?(title, note ?? "")
        }
        alertController.addAction(action)
        return self
    }
    
    func build() -> UIAlertController {
        return alertController
    }
}
