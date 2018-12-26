//
//  SFCollectionViewCompactLayout.swift
//  SFCollectionViewCompactLayout
//
//  Created by rightmeow on 12/20/18.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import UIKit

protocol SFCollectionViewDelegateCompactLayout: UICollectionViewDelegate {
  // warning: support for mixed alignment is still under development
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, isLeftAlignedAt section: Int) -> Bool
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
}

extension SFCollectionViewDelegateCompactLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize.zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}

class SFCollectionViewCompactLayout: UICollectionViewLayout {
  weak var delegate: SFCollectionViewDelegateCompactLayout?
  
  var lineSpacing: CGFloat = 0
  
  var interitemSpacing: CGFloat = 0
  
  private var scrollDirection: UICollectionView.ScrollDirection = UICollectionView.ScrollDirection.vertical // default: UICollectionViewScrollDirectionVertical
  
  private var layoutAttributesMap = [IndexPath: UICollectionViewLayoutAttributes]()
  
  override func invalidateLayout() {
    self.layoutAttributesMap.removeAll()
    super.invalidateLayout()
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = self.collectionView else { return false }
    return newBounds.width != collectionView.bounds.width
  }
  
  override var collectionViewContentSize: CGSize {
    // default contentSize == .zero
    get {
      guard let collectionView = self.collectionView, collectionView.frame != .zero else { return .zero }
      let contentWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
      let contentHeight: CGFloat = 0
      return CGSize(width: contentWidth, height: contentHeight)
    }
  }
  
  override func prepare() {
    super.prepare()
    if self.layoutAttributesMap.isEmpty == true, let collectionView = self.collectionView, let delegate = self.delegate {
      var currentXOffset: CGFloat = self.interitemSpacing
      var currentYOffset: CGFloat = self.lineSpacing
      var maxYOffset: CGFloat = 0
      
      let sections = [Int](0 ... collectionView.numberOfSections - 1)
      for section in sections {
        let isLeftAligned = delegate.collectionView(collectionView, layout: self, isLeftAlignedAt: section)
        let itemsCount = collectionView.numberOfItems(inSection: section)
        let indexPaths = [Int](0 ..< itemsCount).map { IndexPath(item: $0, section: section) }
        if isLeftAligned {
          currentXOffset = collectionView.contentInset.left + self.interitemSpacing // resetting x coordinate for every new section from the left
          indexPaths.forEach { indexPath in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let size = delegate.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
            
            // the origin starts from the top left corner of a UIKit object
            let nextXOffset = size.width + self.interitemSpacing + currentXOffset
            if nextXOffset < self.collectionViewContentSize.width {
              attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              self.layoutAttributesMap[indexPath] = attributes
              
              currentXOffset = nextXOffset // shift x coordinate to the right by (size.width)
              // check for max height in this row
              if maxYOffset < currentYOffset + size.height {
                // if maxYOffset is smaller, set it to the new max
                maxYOffset = currentYOffset + size.height
              }
            } else {
              currentXOffset = self.interitemSpacing // reset currentXOffset for the next row
              currentYOffset = maxYOffset + self.lineSpacing // set new height (new "row")
              maxYOffset = currentYOffset
              
              attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              self.layoutAttributesMap[indexPath] = attributes
              
              let nextXOffset = size.width + self.interitemSpacing + currentXOffset
              currentXOffset = nextXOffset
              if maxYOffset < currentYOffset + size.height {
                // if maxYOffset is smaller, set it to the new max
                maxYOffset = currentYOffset + size.height
              }
            }
          }
        } else {
          currentXOffset = self.collectionViewContentSize.width - self.interitemSpacing // resetting x coordinate for every new section from the right
          indexPaths.forEach { (indexPath) in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let size = delegate.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
            
            // the right-aligned origin starts from top right corner
            let nextXOffset = currentXOffset - size.width - self.interitemSpacing
            if nextXOffset > 0 {
              currentXOffset = currentXOffset - size.width // shift x coordinate to the left by (size.width)
              attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              self.layoutAttributesMap[indexPath] = attributes
              
              currentXOffset -= self.interitemSpacing
              // check for max height in this row
              if maxYOffset < currentYOffset + size.height {
                // if maxYOffset is smaller, set it to the new max
                maxYOffset = currentYOffset + size.height
              }
            } else {
              currentXOffset = self.collectionViewContentSize.width - self.interitemSpacing
              currentYOffset = maxYOffset + self.lineSpacing // set new height for new "row"
              maxYOffset = currentYOffset
              
              let nextXOffset = currentXOffset - size.width
              currentXOffset = nextXOffset
              
              attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              self.layoutAttributesMap[indexPath] = attributes
              
              currentXOffset -= self.interitemSpacing
              if maxYOffset < currentYOffset + size.height {
                maxYOffset = currentYOffset + size.height
              }
            }
          }
        }
      }
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return self.layoutAttributesMap.values.filter { rect.intersects($0.frame) }
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return self.layoutAttributesMap[indexPath]
  }
}
