//
//  EditTaskLayoutViewContoller.swift
//  DOITTaskManager
//
//  Created by Nikolay Mikhailishin on 1/31/20.
//  Copyright © 2020 nikolay.mihailishin. All rights reserved.
//

import UIKit

class EditTaskLayoutViewContoller: UIViewController, EditTaskLayoutContoller {
    // MARK: - Properties
    
    
    @IBOutlet private weak var titleTextView: UITextView!
    @IBOutlet private var priorityButtons: [UIButton]!
    @IBOutlet private weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var expiredDatePicker: UIDatePicker!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private var priorities: [Task.Priority] {
        return [.high, .normal, .low]
    }
    
    
    
    // MARK: - EditTaskLayoutContoller
    
    var delegate: EditTaskLayoutContollerDelegate?
    var task: Task? {
        didSet {
            guard isViewLoaded, let task = task else { return }
            update(with: task)
        }
    }
    
    var shouldShowDeleteButton: Bool = false {
        didSet {
            guard isViewLoaded else { return }
            configureUI()
        }
    }
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    
    // MARK: - Private
    
    private func configureUI() {
        let screenWidth = DeviceInfo.screenSize.width
        let horisontalInset: CGFloat = 10
        let horisontalInsetBetweenButtons: CGFloat = 20
        let availableWidth = screenWidth - horisontalInset * 2 - horisontalInsetBetweenButtons * 2
        let buttonMaxWidth: CGFloat = availableWidth / 3
        buttonWidthConstraint.constant = buttonMaxWidth
        
        if let preselectedButton = priorityButtons.first {
            selectButton(preselectedButton)
        }
        
        deleteButton.isHidden = !shouldShowDeleteButton
    }
    
    private func update(with task: Task) {
        titleTextView.text = task.title
        
        guard let selectedIndex = priorities.firstIndex(of: task.priority),
            priorityButtons.indices.contains(selectedIndex) else {
            return
        }
        let selectedButton = priorityButtons[selectedIndex]
        selectButton(selectedButton)
        
        expiredDatePicker.date = Date(timeIntervalSince1970: task.expirationDate)
    }
    
    private func selectButton(_ selectedButton: UIButton) {
        priorityButtons.enumerated().forEach { index, button in
            if button === selectedButton {
                button.backgroundColor = .gray
                button.setTitleColor(.white, for: .normal)
                if priorities.indices.contains(index) {
                     delegate?.layoutController(self, didAskToSetPriorityTo: priorities[index])
                }
                return
            }
            button.backgroundColor = .white
            button.setTitleColor(.gray, for: .normal)
        }
    }
    
    
    
    // MARK: - Actions
    
    @IBAction private func datePickerValueChanged(_ sender: Any) {
        delegate?.layoutController(self, didAskToSetDateTo: expiredDatePicker.date.timeIntervalSince1970)
    }
    
    @IBAction private func deleteButtonPressed(_ sender: Any) {
        delegate?.layoutControllerDidAskToRemoveTask(self)
    }
    
    @IBAction private func priorityButtonPressed(_ sender: Any) {
        guard let selectedButton = sender as? UIButton else {
            return
        }
        selectButton(selectedButton)
    }
    
    @IBAction private func saveButtonPressed(_ sender: Any) {
        delegate?.layoutControllerDidAskToSaveTask(self)
    }
}



extension EditTaskLayoutViewContoller: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.layoutController(self, didAskToSetTitleTo: textView.text)
    }
}
