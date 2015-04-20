//
//  CollectionViewFlowLayout.swift
//  Quilt
//
//  Created by Caroline Begbie on 1/04/2015.
//  Copyright (c) 2015 Caroline Begbie. All rights reserved.
//

import UIKit


class CollectionViewFlowLayout: UICollectionViewFlowLayout {
  
  required init(coder: NSCoder) {
    fatalError("use init()")
  }
  
  override init() {
    super.init()
    self.itemSize = CGSize(width: 250, height: 475);
    self.scrollDirection = .Horizontal
  }
  
  
//  http://stackoverflow.com/a/22696037/359578
// sets view to be one at a time and centered

  override func targetContentOffsetForProposedContentOffset(proposedContentOffset:CGPoint, withScrollingVelocity:CGPoint) -> CGPoint {
    
    if let collectionView = self.collectionView {
      let bounds = collectionView.bounds
      let halfWidth = bounds.width * 0.5
      let proposedContentOffsetCenterX:CGFloat = proposedContentOffset.x + halfWidth
      
      
      let attributes = self.layoutAttributesForElementsInRect(bounds) as! [UICollectionViewLayoutAttributes]
      
      var candidateAttribute:UICollectionViewLayoutAttributes? = nil
      for attribute in attributes {
        if (attribute.representedElementCategory == .Cell) {
          if let candidate = candidateAttribute {
            if abs(attribute.center.x - proposedContentOffsetCenterX) <
              abs(candidate.center.x - proposedContentOffsetCenterX) {
                candidateAttribute = attribute
            }
          } else {
            candidateAttribute = attribute
          }
        }
      }
      if let candidate = candidateAttribute {
        return CGPointMake(candidate.center.x - halfWidth, proposedContentOffset.y);
      }
    }
    return CGPointZero
  }
}
