//
//  UICollectionView+Extras.swift
//
//  Created by Binyamin Trachtman on 9/13/16.
//  Copyright © 2016 Binyamin Trachtman. All rights reserved.
//

import UIKit

public extension UICollectionView
{
    func nearestCellToCetner() -> UICollectionViewCell?
    {
        var nearstCell:UICollectionViewCell!
        var nearstCellDis = CGFloat(10000)
        
        //Get the nearst cell to the center of the collection view
        for cell in self.visibleCells
        {
            let cellRelativeOrigenX = cell.center.x - self.contentOffset.x
            let cellDis = abs(cellRelativeOrigenX - self.center.x)
            
            if cellDis < nearstCellDis
            {
                nearstCellDis = cellDis
                nearstCell = cell
            }
        }
        
        return nearstCell
    }
    
    func scrollToNearestVisibleCell()
    {
        let closestCellIndex = self.centerRowIndex()
        
        if closestCellIndex != -1 {
            self.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
       
    }
    
    func centerRowIndex() -> Int
    {
        let visibleCenterPositionOfScrollView = Float(self.contentOffset.x + (self.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<self.visibleCells.count {
            let cell = self.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
            
            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = self.indexPath(for: cell)!.row
            }
        }
        
        return closestCellIndex
        
    }
}
