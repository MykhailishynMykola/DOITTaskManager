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
    
    private var selectedPriority: Task.Priority?
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
    
    var style: EditTaskScreenViewController.Style? {
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
        if style == .addTask {
            selectedPriority = .high
            let preselectedButton = priorityButtons.first
            preselectedButton?.backgroundColor = .gray
            preselectedButton?.setTitleColor(.white, for: .normal)
            deleteButton.isHidden = true
        }
    }
    
    private func update(with task: Task) {
        guard let style = style, style == .editTask else {
            return
        }
        titleTextView.text = task.title
        
        guard let selectedIndex = priorities.firstIndex(of: task.priority),
            priorityButtons.indices.contains(selectedIndex) else {
            return
        }
        let selectedButton = priorityButtons[selectedIndex]
        selectedButton.backgroundColor = .gray
        selectedButton.setTitleColor(.white, for: .normal)
        selectedPriority = task.priority
        
        expiredDatePicker.date = Date(timeIntervalSince1970: task.expirationDate)
    }
    
    
    
    // MARK: - Actions
    
    @IBAction private func deleteButtonPressed(_ sender: Any) {
        delegate?.layoutControllerDidAskToRemoveTask(self)
    }
    
    @IBAction private func priorityButtonPressed(_ sender: Any) {
        guard let selectedButton = sender as? UIButton else {
            return
        }
        
        priorityButtons.enumerated().forEach { index, button in
            if button === selectedButton {
                button.backgroundColor = .gray
                button.setTitleColor(.white, for: .normal)
                selectedPriority = priorities.indices.contains(index)
                    ? priorities[index]
                    : nil
                return
            }
            button.backgroundColor = .white
            button.setTitleColor(.gray, for: .normal)
        }
    }
    
    
    @IBAction private func saveButtonPressed(_ sender: Any) {
        guard let selectedPriority = selectedPriority else {
            return
        }
        delegate?.layoutController(self, didAskToSaveTaskWith: titleTextView.text, priority: selectedPriority, date: expiredDatePicker.date)
    }
    
}
