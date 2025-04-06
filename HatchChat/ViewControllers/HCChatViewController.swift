//
//  HCChatViewController.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-04.
//


import UIKit
import FittedSheets

class HCChatViewController: UIViewController {

    // MARK: - Subviews

    private let dimmingView = UIView()
    private let mainSheetView = UIView()
    private let chipsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        flowLayout.estimatedItemSize = CGSize(width: 120, height: 60)
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    private let chatTextView = HCTextView(
        frame: .zero,
        fixedHeight: 100,
        placeholder: "Start typing..."
    )

    private let previewContainer = UIView()
    private let previewImageView = UIImageView()
    private let removePreviewButton = UIButton(type: .system)
    private let imageButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)
    private let expandButton = UIButton(type: .system)

    // MARK: - Constraints
    private var mainSheetHeightConstraint: NSLayoutConstraint!
    private var mainSheetBottomConstraint: NSLayoutConstraint!
    private var isImageSheetPresent = false
    private let keyboardListener = HCKeyboardListener()
    private var mainSheetInitialHeight: CGFloat {
        return view.bounds.height * 0.25
    }
    private var mainSheetExpandedHeight: CGFloat {
        return view.bounds.height * 0.9
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .HCBackground
        self.title = "Hachat"


        setupDimmingView()
        setupMainSheet()
        setupChipsCollection()
        setupTextView()
        setupPreviewContainer()
        setupButtons()
        setupPanGesture()
        keyboardListener.delegate = self
        chipsCollectionView.dataSource = self
        chipsCollectionView.delegate = self
        chipsCollectionView.register(HCChipCell.self, forCellWithReuseIdentifier: "HCChipCell")
    }

    // MARK: - Setup

    private func setupDimmingView() {
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupMainSheet() {
        mainSheetView.backgroundColor = .HCTextViewBackground
        mainSheetView.layer.cornerRadius = 16
        mainSheetView.layer.masksToBounds = false
        mainSheetView.translatesAutoresizingMaskIntoConstraints = false
        mainSheetView.layer.shadowColor = UIColor.black.cgColor
        mainSheetView.layer.shadowOpacity = 0.1
        mainSheetView.layer.shadowOffset = CGSize(width: 0, height: -3)
        mainSheetView.layer.shadowRadius = 6
        view.addSubview(mainSheetView)

        mainSheetHeightConstraint = mainSheetView.heightAnchor.constraint(equalToConstant: mainSheetInitialHeight)
        mainSheetBottomConstraint = mainSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)

        NSLayoutConstraint.activate([
            mainSheetHeightConstraint,
            mainSheetBottomConstraint,
            mainSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupChipsCollection() {
        chipsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chipsCollectionView)

        NSLayoutConstraint.activate([
            chipsCollectionView.bottomAnchor.constraint(equalTo: mainSheetView.topAnchor, constant: -20),
            chipsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsCollectionView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupTextView() {
        chatTextView.backgroundColor = .HCTextViewBackground
        chatTextView.layer.cornerRadius = 8
        chatTextView.delegate = self
        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        mainSheetView.addSubview(chatTextView)
        NSLayoutConstraint.activate([
            chatTextView.topAnchor.constraint(equalTo: mainSheetView.topAnchor, constant: 8),
            chatTextView.leadingAnchor.constraint(equalTo: mainSheetView.leadingAnchor, constant: 16),
            chatTextView.trailingAnchor.constraint(equalTo: mainSheetView.trailingAnchor, constant: -60),
        ])
    }

    private func setupPreviewContainer() {
        previewContainer.isHidden = true
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        mainSheetView.addSubview(previewContainer)

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(previewImageView)

        removePreviewButton.setImage(UIImage(named: "remove")?.withRenderingMode(.alwaysOriginal), for: .normal)
        removePreviewButton.setTitleColor(.label, for: .normal)
        removePreviewButton.addTarget(self, action: #selector(removePreviewTapped), for: .touchUpInside)
        removePreviewButton.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(removePreviewButton)

        NSLayoutConstraint.activate([
            previewContainer.topAnchor.constraint(equalTo: chatTextView.bottomAnchor, constant: 8),
            previewContainer.leadingAnchor.constraint(equalTo: mainSheetView.leadingAnchor, constant: 16),
            previewContainer.trailingAnchor.constraint(equalTo: mainSheetView.trailingAnchor, constant: -16),
            previewContainer.heightAnchor.constraint(equalToConstant: 50),

            previewImageView.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewImageView.widthAnchor.constraint(equalTo: previewImageView.heightAnchor),

            removePreviewButton.topAnchor.constraint(equalTo: previewImageView.topAnchor, constant: -4),
            removePreviewButton.trailingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: 4),
            removePreviewButton.widthAnchor.constraint(equalToConstant: 20),
            removePreviewButton.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        previewContainer.backgroundColor = .HCTextViewBackground
    }

    private func setupButtons() {
        // Expand button (on the right edge of textView)
        expandButton.setImage(UIImage(named: "expand")?.withRenderingMode(.alwaysOriginal), for: .normal)
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        expandButton.isHidden = true  // hidden until user types
        mainSheetView.addSubview(expandButton)

        // Image button
        imageButton.setImage(UIImage(named: "image")?.withRenderingMode(.alwaysOriginal), for: .normal)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        mainSheetView.addSubview(imageButton)

        // Send button
        sendButton.setImage(UIImage(named: "send")?.withRenderingMode(.alwaysOriginal), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        mainSheetView.addSubview(sendButton)

        NSLayoutConstraint.activate([
            // Expand button
            expandButton.topAnchor.constraint(equalTo: chatTextView.topAnchor),
            expandButton.leadingAnchor.constraint(equalTo: chatTextView.trailingAnchor, constant: 4),
            expandButton.widthAnchor.constraint(equalToConstant: 32),
            expandButton.heightAnchor.constraint(equalToConstant: 32),

            // Image button
            imageButton.bottomAnchor.constraint(equalTo: mainSheetView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            imageButton.leadingAnchor.constraint(equalTo: mainSheetView.leadingAnchor, constant: 32),
            imageButton.widthAnchor.constraint(equalToConstant: 35),
            imageButton.heightAnchor.constraint(equalToConstant: 35),

            // Send button
            sendButton.centerYAnchor.constraint(equalTo: imageButton.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: mainSheetView.trailingAnchor, constant: -32),
            sendButton.widthAnchor.constraint(equalToConstant: 35),
            sendButton.heightAnchor.constraint(equalToConstant: 35),
        ])
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSheetPan(_:)))
        mainSheetView.addGestureRecognizer(panGesture)
    }

    // MARK: - Actions

    @objc private func removePreviewTapped() {
        previewContainer.isHidden = true
        previewImageView.image = nil
        previewImageView.backgroundColor = .clear
    }

    @objc private func sendButtonTapped() {
        view.endEditing(true)
        print("Send tapped. Text: \(chatTextView.text ?? "")")
    }

    @objc private func imageButtonTapped() {
        self.isImageSheetPresent = true
        view.endEditing(true)

        let tileVC = HCTilePickerViewController()
        tileVC.delegate = self

        let options = SheetOptions(
            pullBarHeight: 24,
            shouldExtendBackground: true,
            setIntrinsicHeightOnNavigationControllers: true,
            useFullScreenMode: false,
            shrinkPresentingViewController: false,
            useInlineMode: false,
            horizontalPadding: 0,
            maxWidth: nil
        )

        let startHeight: CGFloat = keyboardListener.height > 0 ? keyboardListener.height : 300
        let sheetController = SheetViewController(
            controller: tileVC,
            sizes: [.fixed(startHeight), .fullscreen],
            options: options
        )
        sheetController.minimumSpaceAbovePullBar = 44

        sheetController.didDismiss = { _ in
            self.isImageSheetPresent = false
           _ = self.chatTextView.becomeFirstResponder()
        }
        sheetController.modalTransitionStyle = .crossDissolve
        present(sheetController, animated: true)
    }

    @objc private func expandButtonTapped() {
        let fullVC = HCFullScreenTextViewController()
        fullVC.modalPresentationStyle = .custom
        fullVC.initialText = self.chatTextView.text

        fullVC.onDone = { [weak self] updatedText in
            guard let self = self else { return }
            self.chatTextView.text = updatedText
            self.chatTextView.refreshDynamicFont()
        }

        let options = SheetOptions(
            pullBarHeight: 24,
            shouldExtendBackground: true,
            setIntrinsicHeightOnNavigationControllers: true,
            useFullScreenMode: false,
            shrinkPresentingViewController: false,
            useInlineMode: false,
            horizontalPadding: 0,
            maxWidth: nil
        )

        let sheetController = SheetViewController(
            controller: fullVC,
            sizes: [.fullscreen],
            options: options
        )
        sheetController.minimumSpaceAbovePullBar = 44
        sheetController.modalTransitionStyle = .flipHorizontal
        present(sheetController, animated: true)
    }

    // MARK: - Pan to dismiss keyboard
    private var initialBottomConstant: CGFloat = 0

    @objc private func handleSheetPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view).y

        switch gesture.state {
        case .began:
            initialBottomConstant = mainSheetBottomConstraint.constant

        case .changed:
            // Only handle downward drags if keyboard is up
            guard keyboardListener.isUp, translation.y > 0 else { return }
            let drag = min(translation.y, keyboardListener.height)
            if chatTextView.text.isEmpty {
                let maxDrag = keyboardListener.height
                let progress = min(max(drag / maxDrag, 0), 1)
                chatTextView.placeholderLabel.alpha = 0.4 * progress
            }
            keyboardListener.keyboardWindow?.transform = CGAffineTransform(translationX: 0, y: drag)
            mainSheetView.transform = CGAffineTransform(translationX: 0, y: drag)
            chipsCollectionView.transform = CGAffineTransform(translationX: 0, y: drag)

        case .ended, .cancelled:
            guard keyboardListener.isUp else { return }
            let d = pow(velocity, 2) / 5000
            let finalTranslation = translation.y + (velocity >= 0 ? d : -d)
            if finalTranslation > keyboardListener.height / 2 {
                // Dismiss keyboard
                UIView.animate(withDuration: 0.3) {
                    self.keyboardListener.keyboardWindow?.transform = CGAffineTransform.identity
                    self.mainSheetView.transform = .identity
                    self.chipsCollectionView.transform = .identity
                    self.view.endEditing(true)
                    if self.chatTextView.text.isEmpty {
                         self.chatTextView.placeholderLabel.alpha = 0.4
                     }
                }
            } else {
                // Snap back
                UIView.animate(withDuration: 0.3) {
                    self.keyboardListener.keyboardWindow?.transform = CGAffineTransform.identity
                    self.mainSheetView.transform = .identity
                    self.chipsCollectionView.transform = .identity
                    if self.chatTextView.text.isEmpty {
                         self.chatTextView.placeholderLabel.alpha = 0.4
                     }
                }
            }
        default:
            break
        }
    }
}

// MARK: - UITextViewDelegate
extension HCChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        expandButton.isHidden = textView.text.isEmpty

        if let fixedTV = textView as? HCTextView {
            fixedTV.refreshDynamicFont()
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

// MARK: - HCKeyboardListenerDelegate
extension HCChatViewController: HCKeyboardListenerDelegate {
    func keyboardListener(_ listener: HCKeyboardListener, willShowWith model: HCKeyboardListener.Model) {
        guard !isImageSheetPresent else {return}
        mainSheetBottomConstraint.constant = -model.frame.height
        UIView.animate(withDuration: model.duration, delay: 0, options: model.animationOptions) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardListener(_ listener: HCKeyboardListener, willHideWith model: HCKeyboardListener.Model) {
        guard !isImageSheetPresent else {return}
        mainSheetBottomConstraint.constant = 0
        UIView.animate(withDuration: model.duration, delay: 0, options: model.animationOptions) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - TilePickerDelegate
extension HCChatViewController: TilePickerDelegate {
    func TilePickerViewController(_ picker: HCTilePickerViewController, didSelectColor color: UIColor) {
        previewContainer.isHidden = false
        previewImageView.backgroundColor = color
        previewImageView.image = nil
    }
}

// MARK: - CollectionView DataSource/DelegateFlowLayout
extension HCChatViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HCChipCell", for: indexPath) as! HCChipCell
        cell.configure(title: "Some Text", subtitle: "Some more text")
        return cell
    }

}
