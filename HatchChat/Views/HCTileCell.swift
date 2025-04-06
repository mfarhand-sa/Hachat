//
//  HCTileCell.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-05.
//

import UIKit
class HCTileCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
