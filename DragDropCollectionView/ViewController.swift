//
//  ViewController.swift
//  DragDropCollectionView
//
//  Created by 김종권 on 2023/06/25.
//

import UIKit

final class MyCell: UICollectionViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        prepare(color: nil)
    }
    
    func prepare(color: UIColor?) {
        contentView.backgroundColor = color
    }
}

class ViewController: UIViewController {
    private enum Metric {
        static let cellWidth = 80.0
        static let cellHeight = 120.0
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let mainSize = UIScreen.main.bounds
        layout.itemSize = .init(width: Metric.cellWidth, height: Metric.cellHeight)
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(MyCell.self, forCellWithReuseIdentifier: "cell")
        view.dataSource = self
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dataSource = (0...10).map(String.init)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Metric.cellHeight)
        ])
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MyCell
        else { return UICollectionViewCell() }
        
        var randomColor: CGFloat {
            CGFloat(drand48())
        }
        cell.prepare(color: UIColor(red: randomColor, green: randomColor, blue: randomColor, alpha: 1.0))
        return cell
    }
}
