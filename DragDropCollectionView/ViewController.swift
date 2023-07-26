//
//  ViewController.swift
//  DragDropCollectionView
//
//  Created by 김종권 on 2023/06/25.
//

import UIKit

final class MyCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepare(color: nil, text: nil)
    }
    
    func prepare(color: UIColor?, text: String?) {
        contentView.backgroundColor = color
        label.text = text
    }
    
    private func setupUI() {
        clipsToBounds = true
        contentView.layer.cornerRadius = 20
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}

class ViewController: UIViewController {
    private enum Metric {
        static let cellWidth = 80.0
        static let cellHeight = 120.0
        static let horizontalInset = 20.0
    }
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "jake iOS 앱 개발 알아가기"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let mainSize = UIScreen.main.bounds
        layout.itemSize = .init(width: Metric.cellWidth, height: Metric.cellHeight)
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = .init(top: 0, left: Metric.horizontalInset, bottom: 0, right: Metric.horizontalInset)
        view.register(MyCell.self, forCellWithReuseIdentifier: "cell")
        view.dataSource = self

        view.dragDelegate = self
        view.dropDelegate = self
        view.dragInteractionEnabled = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dataSource = (0...10).map { _ in UIColor.randomColor }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(textField)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
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
        
        cell.prepare(color: dataSource[indexPath.row], text: "\(indexPath.row)")
        return cell
    }
}

extension ViewController: UICollectionViewDragDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        guard
            let targetView = (collectionView.cellForItem(at: indexPath) as? MyCell)?.contentView,
            let dragPreview = targetView.snapshotView(afterScreenUpdates: false)
        else {
            return [UIDragItem(itemProvider: NSItemProvider())]
        }
        
        let previewParameters = UIDragPreviewParameters()
        previewParameters.visiblePath = UIBezierPath(
            roundedRect: dragPreview.bounds,
            cornerRadius: targetView.layer.cornerRadius
        )
        
        dragItem.previewProvider = { () -> UIDragPreview? in
            UIDragPreview(view: dragPreview, parameters: previewParameters)
        }
        
        return [dragItem]
    }
}

extension ViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard collectionView.hasActiveDrag else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        guard coordinator.proposal.operation == .move else { return }
        move(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
    }

    private func move(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        guard
            let sourceItem = coordinator.items.first,
            let sourceIndexPath = sourceItem.sourceIndexPath
        else { return }
        
        collectionView.performBatchUpdates { [weak self] in
            self?.move(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        } completion: { finish in
            print("finish:", finish)
            coordinator.drop(sourceItem.dragItem, toItemAt: destinationIndexPath)
        }
    }

    private func move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let sourceItem = dataSource[sourceIndexPath.item]
        
        // dataSource 이동
        DispatchQueue.main.async {
            self.dataSource.remove(at: sourceIndexPath.item)
            self.dataSource.insert(sourceItem, at: destinationIndexPath.item)
            let indexPaths = self.dataSource
                .enumerated()
                .map(\.offset)
                .map { IndexPath(row: $0, section: 0) }
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: indexPaths)
            }
        }
    }
}
