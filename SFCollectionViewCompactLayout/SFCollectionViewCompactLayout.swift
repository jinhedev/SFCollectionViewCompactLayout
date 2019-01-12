//
//  SFCollectionViewCompactLayout.swift
//  SFCollectionViewCompactLayout
//
//  Created by rightmeow on 12/20/18.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import UIKit

public protocol SFCollectionViewDelegateCompactLayout: UICollectionViewDelegate {
  // warning: support for mixed alignment is still under development
  @available(iOS 6.0, *)
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, isLeftAlignedAt section: Int) -> Bool
  
  @available(iOS 6.0, *)
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
  
  @available(iOS 6.0, *)
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSectionAt section: Int) -> CGFloat
  
  @available(iOS 6.0, *)
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSectionAt section: Int) -> CGFloat
}

extension SFCollectionViewDelegateCompactLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize.zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}

@available(iOS 6.0, *)
open class SFCollectionViewCompactLayout: UICollectionViewLayout {
  weak var delegate: SFCollectionViewDelegateCompactLayout?
  private var layoutAttributesMap = [IndexPath: UICollectionViewLayoutAttributes]()
  
  override open func invalidateLayout() {
    self.layoutAttributesMap.removeAll()
    super.invalidateLayout()
  }
  
  override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = self.collectionView else { return false }
    return newBounds.width != collectionView.bounds.width
  }
  
  override open var collectionViewContentSize: CGSize {
    // default: contentSize == .zero
    guard let collectionView = self.collectionView else { return .zero }
    let contentWidth = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
    let contentHeight: CGFloat = 0
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  // FIXME: use collectionViewContentSize for calculation, otherwise contentInset.right is always going to be wrong
  override open func prepare() {
    super.prepare()
    if self.layoutAttributesMap.isEmpty == true, let collectionView = self.collectionView, let delegate = self.delegate {
      var currentXOffset: CGFloat
      var currentYOffset: CGFloat
      var maxYOffset: CGFloat
      let topContentInset = collectionView.contentInset.top
      let bottomContentInset = collectionView.contentInset.bottom // FIXME: how to implement this???
      let leftContentInset = collectionView.contentInset.left
      let rightContentInset = collectionView.contentInset.right
      
      let sections = [Int](0 ... collectionView.numberOfSections - 1)
      for section in sections {
        let isLeftAligned = delegate.collectionView(collectionView, layout: self, isLeftAlignedAt: section)
        let lineSpacing = delegate.collectionView(collectionView, layout: self, lineSpacingForSectionAt: section)
        let interitemSpacing = delegate.collectionView(collectionView, layout: self, interitemSpacingForSectionAt: section)
        let itemsCount = collectionView.numberOfItems(inSection: section)
        let indexPaths = [Int](0 ..< itemsCount).map { IndexPath(item: $0, section: section) }
        currentYOffset = topContentInset + lineSpacing
        maxYOffset = currentYOffset
        
        if isLeftAligned {
          currentXOffset = leftContentInset + interitemSpacing // resetting x coordinate for every new section from the left
          indexPaths.forEach { indexPath in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let size = delegate.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
            
            // the origin starts from the top left corner of a UIKit object
            let nextXOffset = currentXOffset + size.width + interitemSpacing
            if nextXOffset + rightContentInset <= collectionView.frame.width {
              attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              self.layoutAttributesMap[indexPath] = attributes
              
              currentXOffset = nextXOffset // shift x coordinate to the right by (size.width)
            } else {
              currentXOffset = collectionView.contentInset.left + interitemSpacing // reset currentXOffset for the next row
              currentYOffset = maxYOffset + lineSpacing // set new height (new "row")
              maxYOffset = currentYOffset
              
              // Handle edge case when size.width > collectionView.width - (2*interitemspacing) - (contentInset.left + contentInset.right)
              if size.width > (collectionView.frame.width - (2 * interitemSpacing) - collectionView.contentInset.left - collectionView.contentInset.right) {
                // signal warning
                print("\(Date()): \(self.description) the item width must be less than the width of the UICollectionView minum the section insets left and right values, minus the content insets left and right values.")
                print("\(Date()): \(self.description) Please check the values returned by the delegate.")
                let maxWidth = collectionView.frame.width - (2 * interitemSpacing) - collectionView.contentInset.left - collectionView.contentInset.right
                attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: maxWidth, height: size.height)
              } else {
                attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              }
              self.layoutAttributesMap[indexPath] = attributes
              currentXOffset += size.width + interitemSpacing
            }
            // check and update max height in this row
            if maxYOffset < currentYOffset + size.height {
              // if maxYOffset is smaller, set it to the new max
              maxYOffset = currentYOffset + size.height
            }
          }
        } else {
          currentXOffset = collectionView.frame.width - interitemSpacing - collectionView.contentInset.right // resetting x coordinate for every new section from the left
          
          indexPaths.forEach { (indexPath) in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let size = delegate.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
            
            // the right-aligned origin starts from top right corner
            let nextXOffset = currentXOffset - size.width - interitemSpacing
            if nextXOffset > 0 {
              currentXOffset = currentXOffset - size.width // shift x coordinate to the left by (size.width)
              attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              self.layoutAttributesMap[indexPath] = attributes
              
              currentXOffset -= interitemSpacing
              // check for max height in this row
              if maxYOffset < currentYOffset + size.height {
                // if maxYOffset is smaller, set it to the new max
                maxYOffset = currentYOffset + size.height
              }
            } else {
              currentXOffset = self.collectionViewContentSize.width - interitemSpacing
              currentYOffset = maxYOffset + lineSpacing // set new height for new "row"
              maxYOffset = currentYOffset
              
              let nextXOffset = currentXOffset - size.width
              currentXOffset = nextXOffset
              
              attributes.frame = CGRect(x: currentXOffset, y: currentYOffset, width: size.width, height: size.height)
              self.layoutAttributesMap[indexPath] = attributes
              
              currentXOffset -= interitemSpacing
              if maxYOffset < currentYOffset + size.height {
                maxYOffset = currentYOffset + size.height
              }
            }
          }
        }
      }
    }
  }
  
  override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return self.layoutAttributesMap.values.filter { rect.intersects($0.frame) }
  }
  
  override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return self.layoutAttributesMap[indexPath]
  }
}
