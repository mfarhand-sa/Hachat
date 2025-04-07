//
//  HCChatViewController.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-04.
//


import UIKit
import FittedSheets

class HCChatViewController: UIViewController {

    // MARK: - Constraints / State
    private var mainSheetHeightConstraint: NSLayoutConstraint!
    private var mainSheetBottomConstraint: NSLayoutConstraint!
    private var chatTextViewBottomToPreviewConstraint: NSLayoutConstraint!
    private var chatTextViewBottomToButtonsConstraint: NSLayoutConstraint!
    private var isImageSheetPresent = false
    private let keyboardListener = HCKeyboardListener()
    private var initialBottomConstant: CGFloat = 0
    


    private var mainSheetInitialHeight: CGFloat { view.bounds.height * 0.25 }
    private var mainSheetExpandedHeight: CGFloat { view.bounds.height * 0.9 }

    // MARK: - Subviews as Lazy Properties
    private lazy var dimmingView: UIView = {
        return UIView()
    }()

    private lazy var mainSheetView: UIView = {
        return UIView()
    }()

    private lazy var chipsCollectionView: UICollectionView = {
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

    private lazy var chatTextView: HCTextView = {
        let tv = HCTextView(frame: .zero, placeholder: "Start typing...")
        return tv
    }()

    private lazy var previewContainer: UIView = {
        return UIView()
    }()

    private lazy var previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()

    private lazy var removePreviewButton: UIButton = {
        let b = UIButton(type: .system)
        return b
    }()

    private lazy var imageButton: UIButton = {
        let b = UIButton(type: .system)
        return b
    }()

    private lazy var sendButton: UIButton = {
        let b = UIButton(type: .system)
        return b
    }()

    private lazy var expandButton: UIButton = {
        let b = UIButton(type: .system)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .HCBackground
        title = "Hachat"
        keyboardListener.delegate = self

        // The same setup calls remain below
        setupDimmingView()
        setupMainSheet()
        setupChipsCollection()
        setupTextView()
        setupButtons()
        setupPreviewContainer()
        setupPanGesture()

        // Keep your existing lines for hooking up the chips
        chipsCollectionView.dataSource = self
        chipsCollectionView.delegate = self
        chipsCollectionView.register(HCChipCell.self, forCellWithReuseIdentifier: "HCChipCell")
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                
                self.reloadButtonImages()

            })
        }
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
        mainSheetView.layer.cornerRadius = Constants.CornerRaduce.generalRaduce
        mainSheetView.layer.masksToBounds = false
        mainSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainSheetView.translatesAutoresizingMaskIntoConstraints = false
        mainSheetView.layer.shadowColor = UIColor.black.cgColor
        mainSheetView.layer.shadowOpacity = Constants.Shadow.shadowOpacity
        mainSheetView.layer.shadowOffset = Constants.Shadow.shadowOffset
        mainSheetView.layer.shadowRadius = Constants.Shadow.shadowRadius
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
            chipsCollectionView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setupTextView() {
        chatTextView.backgroundColor = .HCTextViewBackground
        chatTextView.layer.cornerRadius = 8
        chatTextView.delegate = self
        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        mainSheetView.addSubview(chatTextView)
        chatTextViewBottomToPreviewConstraint = chatTextView.bottomAnchor.constraint(equalTo: previewContainer.topAnchor, constant: -8)
        chatTextViewBottomToButtonsConstraint = chatTextView.bottomAnchor.constraint(equalTo: mainSheetView.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        NSLayoutConstraint.activate([
            chatTextView.topAnchor.constraint(equalTo: mainSheetView.topAnchor, constant: 8),
            chatTextView.leadingAnchor.constraint(equalTo: mainSheetView.leadingAnchor, constant: Constants.Padding.globalLeadingPadding),
            chatTextView.trailingAnchor.constraint(equalTo: mainSheetView.trailingAnchor, constant: -60),
            chatTextViewBottomToButtonsConstraint
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

        removePreviewButton.setImage(UIImage(named: "HCRemove")?.withRenderingMode(.alwaysOriginal), for: .normal)
        removePreviewButton.setTitleColor(.label, for: .normal)
        removePreviewButton.addTarget(self, action: #selector(removePreviewTapped), for: .touchUpInside)
        removePreviewButton.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.addSubview(removePreviewButton)

        NSLayoutConstraint.activate([
            previewContainer.leadingAnchor.constraint(equalTo: mainSheetView.leadingAnchor, constant: Constants.Padding.globalLeadingPadding),
            previewContainer.trailingAnchor.constraint(equalTo: mainSheetView.trailingAnchor, constant: Constants.Padding.globalTrailingPadding),
            previewContainer.heightAnchor.constraint(equalToConstant: 50),
            previewImageView.bottomAnchor.constraint(equalTo: imageButton.topAnchor,constant: -10),

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
        expandButton.setImage(UIImage(named: "HCExpand")?.withRenderingMode(.alwaysOriginal), for: .normal)
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        expandButton.isHidden = true
        mainSheetView.addSubview(expandButton)

        imageButton.setImage(UIImage(named: "HCImage")?.withRenderingMode(.alwaysOriginal), for: .normal)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        mainSheetView.addSubview(imageButton)

        sendButton.setImage(UIImage(named: "HCSend")?.withRenderingMode(.alwaysOriginal), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        mainSheetView.addSubview(sendButton)

        NSLayoutConstraint.activate([
            expandButton.topAnchor.constraint(equalTo: chatTextView.topAnchor),
            expandButton.leadingAnchor.constraint(equalTo: chatTextView.trailingAnchor, constant: 4),
            expandButton.widthAnchor.constraint(equalToConstant: Constants.ButtonSize.width),
            expandButton.heightAnchor.constraint(equalToConstant: Constants.ButtonSize.height),

            imageButton.bottomAnchor.constraint(equalTo: mainSheetView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            imageButton.leadingAnchor.constraint(equalTo: mainSheetView.leadingAnchor, constant: 32),
            imageButton.widthAnchor.constraint(equalToConstant: Constants.ButtonSize.width),
            imageButton.heightAnchor.constraint(equalToConstant: Constants.ButtonSize.height),

            sendButton.centerYAnchor.constraint(equalTo: imageButton.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: mainSheetView.trailingAnchor, constant: -32),
            sendButton.widthAnchor.constraint(equalToConstant: Constants.ButtonSize.width),
            sendButton.heightAnchor.constraint(equalToConstant: Constants.ButtonSize.height),
        ])
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSheetPan(_:)))
        mainSheetView.addGestureRecognizer(panGesture)
    }

    // MARK: - Actions

    @objc private func removePreviewTapped() {
        previewImageView.image = nil
        previewImageView.backgroundColor = .clear
        hidePreview()
    }

    @objc private func sendButtonTapped() {
        view.endEditing(true)
        print("Send tapped. Text: \(chatTextView.text ?? "")")
    }

    @objc private func imageButtonTapped() {
        isImageSheetPresent = true
        view.endEditing(true)

        let tileVC = HCTilePickerViewController()
        tileVC.delegate = self

        let options = SheetOptions(
            pullBarHeight: 24,
            shouldExtendBackground: true,
            setIntrinsicHeightOnNavigationControllers: true,
            useFullScreenMode: false,
            shrinkPresentingViewController: true,
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
        sheetController.gripColor = .label

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
        fullVC.initialText = chatTextView.text
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
        sheetController.gripColor = .label
        sheetController.minimumSpaceAbovePullBar = 44
        sheetController.modalTransitionStyle = .flipHorizontal
        present(sheetController, animated: true)
    }

    // MARK: - Pan to dismiss keyboard
    @objc private func handleSheetPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view).y

        switch gesture.state {
        case .began:
            initialBottomConstant = mainSheetBottomConstraint.constant

        case .changed:
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
            let friction = pow(velocity, 2) / 5000
            let finalDist = translation.y + (velocity >= 0 ? friction : -friction)
            if finalDist > keyboardListener.height / 2 {
                UIView.animate(withDuration: 0.3) {
                    self.keyboardListener.keyboardWindow?.transform = .identity
                    self.mainSheetView.transform = .identity
                    self.chipsCollectionView.transform = .identity
                    self.view.endEditing(true)
                    if self.chatTextView.text.isEmpty {
                        self.chatTextView.placeholderLabel.alpha = 0.4
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.keyboardListener.keyboardWindow?.transform = .identity
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
        
    private func reloadButtonImages() {
        expandButton.setImage(UIImage(named: "HXExpand")?.withRenderingMode(.alwaysOriginal), for: .normal)
        sendButton.setImage(UIImage(named: "HCSend")?.withRenderingMode(.alwaysOriginal), for: .normal)
        imageButton.setImage(UIImage(named: "HCImage")?.withRenderingMode(.alwaysOriginal), for: .normal)
        removePreviewButton.setImage(UIImage(named: "HCRemove")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func showPreview() {
        previewContainer.isHidden = false

        chatTextViewBottomToButtonsConstraint.isActive = false
        chatTextViewBottomToPreviewConstraint.isActive = true

        mainSheetHeightConstraint.constant = mainSheetInitialHeight + 60
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    func hidePreview() {
        previewContainer.isHidden = true

        chatTextViewBottomToPreviewConstraint.isActive = false
        chatTextViewBottomToButtonsConstraint.isActive = true

        mainSheetHeightConstraint.constant = mainSheetInitialHeight
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
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

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool { true }
}

// MARK: - HCKeyboardListenerDelegate
extension HCChatViewController: HCKeyboardListenerDelegate {
    func keyboardListener(_ listener: HCKeyboardListener, willShowWith model: HCKeyboardListener.Model) {
        guard !isImageSheetPresent else { return }
        mainSheetBottomConstraint.constant = -model.frame.height
        UIView.animate(withDuration: model.duration, delay: 0, options: model.animationOptions) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardListener(_ listener: HCKeyboardListener, willHideWith model: HCKeyboardListener.Model) {
        guard !isImageSheetPresent else { return }
        mainSheetBottomConstraint.constant = 0
        UIView.animate(withDuration: model.duration, delay: 0, options: model.animationOptions) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - TilePickerDelegate
extension HCChatViewController: TilePickerDelegate {
    func TilePickerViewController(_ picker: HCTilePickerViewController, didSelectColor color: UIColor) {
        previewImageView.backgroundColor = color
        previewImageView.image = nil
        showPreview()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item == 0 else { return }

        let testSnippet = "This is a sample sentence meant to test"

        chatTextView.text = (chatTextView.text ?? "") + testSnippet
        chatTextView.refreshDynamicFont()
    }

}

