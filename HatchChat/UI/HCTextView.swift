//
//  HCTextView.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-04.
//


import UIKit


class HCTextView: UITextView {

    public var placeholderLabel = UILabel()
    private var fixedHeightConstraint: NSLayoutConstraint?

    private let availableSizes: [CGFloat] = [14, 16, 18]
    private var currentSizeIndex: Int = 2 // Start at 18pt (the largest)
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 0.2

    /// The initial placeholder text
    var placeholder: String

    init(frame: CGRect, fixedHeight: CGFloat, placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: frame, textContainer: nil)

        placeholderLabel.alpha = 0.4
        // 1) Fix the height via an internal constraint
        translatesAutoresizingMaskIntoConstraints = false
        fixedHeightConstraint = heightAnchor.constraint(equalToConstant: fixedHeight)
        fixedHeightConstraint?.isActive = true

        // 2) Setup the placeholder label
        placeholderLabel.text = placeholder
        placeholderLabel.font = .CDFontRegular(size: 18)
        placeholderLabel.textColor = .label
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            // Right anchor just so it doesn't overflow:
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
        ])

        // 3) Configure self
        isScrollEnabled = false
        self.font = .CDFontRegular(size: 18)
        textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)

        // Hide placeholder if user had a starting text
        updatePlaceholderVisibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Call this whenever text changes to re-check dynamic font & placeholder
    func refreshDynamicFont() {
        updatePlaceholderVisibility()

        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(timeInterval: debounceInterval,
                                             target: self,
                                             selector: #selector(handleResizeCheck),
                                             userInfo: nil,
                                             repeats: false)
    }
    
    @objc private func handleResizeCheck() {
        guard let oldRange = self.selectedTextRange else { return }
        let oldOffset = self.contentOffset

        let totalHeight = bounds.height
        let neededHeight = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude)).height
        let ratio = neededHeight / totalHeight
        let indexAt18 = 2, indexAt16 = 1, indexAt14 = 0

        if ratio >= (2.0 / 3.0) {
            if currentSizeIndex == indexAt18 { currentSizeIndex = indexAt16 }
            else if currentSizeIndex == indexAt16 { currentSizeIndex = indexAt14 }
        } else if ratio <= 0.5 {
            if currentSizeIndex == indexAt14 { currentSizeIndex = indexAt16 }
            else if currentSizeIndex == indexAt16 { currentSizeIndex = indexAt18 }
        }

        UIView.animate(withDuration: 0.2) {
            self.font = UIFont.CDFontRegular(size: self.availableSizes[self.currentSizeIndex])
            let newHeight = self.sizeThatFits(CGSize(width: self.bounds.width, height: .greatestFiniteMagnitude)).height
            if self.currentSizeIndex == indexAt14 && newHeight > totalHeight {
                self.isScrollEnabled = true
            } else {
                self.isScrollEnabled = false
            }
            self.layoutIfNeeded()
        }

        // Re-set selection and content offset so the cursor remains visible
        if let newPosition = self.position(from: oldRange.start, offset: 0),
           let newRange = self.textRange(from: newPosition, to: newPosition) {
            self.selectedTextRange = newRange
        }
        self.setContentOffset(oldOffset, animated: false)
    }


    /// Show/hide placeholder label
    private func updatePlaceholderVisibility() {
        if text.isEmpty && !isFirstResponder {
            placeholderLabel.alpha = 0.4
        } else {
            placeholderLabel.alpha = 0.0
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let didBecome = super.becomeFirstResponder()
        updatePlaceholderVisibility()
        return didBecome
    }
    
    override func resignFirstResponder() -> Bool {
        let didResign = super.resignFirstResponder()
        updatePlaceholderVisibility()
        return didResign
    }

    // If text is updated programmatically, refresh
    override var text: String! {
        didSet {
            refreshDynamicFont()
        }
    }
}
