//
//  HCFullScreenTextViewController.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-04.
//


import UIKit

class HCFullScreenTextViewController: UIViewController {

    var initialText: String = ""
    var onDone: ((String) -> Void)?

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .CDFontRegular(size: 18)
        textView.text = initialText
        view.addSubview(textView)

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(named: "HCExpand")?.withRenderingMode(.alwaysOriginal), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            textView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        
        textView.becomeFirstResponder()
    }

    @objc private func closeTapped() {
        onDone?(textView.text ?? "")
        dismiss(animated: true, completion: nil)
    }
}
