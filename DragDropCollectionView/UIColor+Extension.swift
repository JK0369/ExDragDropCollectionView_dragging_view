//
//  UIColor+Extension.swift
//  DragDropCollectionView
//
//  Created by 김종권 on 2023/06/25.
//

import UIKit

extension UIColor {
    static var randomColor: UIColor {
        .init(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
}
