//
//  HCTilePickerViewController.swift
//  HatchChat
//
//  Created by Mohi Farhand on 2025-04-04.
//


import UIKit

protocol TilePickerDelegate: AnyObject {
    func TilePickerViewController(_ picker: HCTilePickerViewController, didSelectColor color: UIColor)
}

class HCTilePickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    weak var delegate: TilePickerDelegate?

    private let colors: [UIColor] = (0..<24).map { _ in
        UIColor(
            red: .random(in: 0.3...1),
            green: .random(in: 0.3...1),
            blue: .random(in: 0.3...1),
            alpha: 1
        )
    }

    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(HCTileCell.self, forCellWithReuseIdentifier: "HCTileCell")
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HCTileCell", for: indexPath) as! HCTileCell
        cell.backgroundColor = colors[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 48) / 3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.TilePickerViewController(self, didSelectColor: colors[indexPath.item])
        dismiss(animated: true)
    }
}
