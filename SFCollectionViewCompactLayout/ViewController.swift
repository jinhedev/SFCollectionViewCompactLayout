//
//  ViewController.swift
//  SFCollectionViewCompactLayout
//
//  Created by rightmeow on 12/20/18.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var tapButton: UIBarButtonItem!
  @IBOutlet weak var collectionView: UICollectionView!
  var flowLayout: UICollectionViewFlowLayout!
  var compactLayout: SFCollectionViewCompactLayout!
  
  @IBAction func tapButtonTapped(_ sender: UIBarButtonItem) {
    print(123)
  }
  
  private func randomString(_ range: String, length: Int) -> String {
    if range.isEmpty {
      return ""
    }
    var result = ""
    for _ in 0 ..< length {
      let randChar = range.randomElement()!
      result.append(randChar)
    }
    return result
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    self.collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    self.setupCollectionViewDelegateCompactLayout()
//    self.setupCollectionViewDelegateFlowLayout()
    self.setupCollectionViewDelegate()
    self.setupCollectionViewDataSource()
  }
}

extension ViewController: UICollectionViewDataSource {
  private func setupCollectionViewDataSource() {
    self.collectionView.dataSource = self
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
    cell.titleLabel.text = "sec: \(indexPath.section), item: \(indexPath.item)"
    cell.backgroundColor = .red
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 13
  }
}

extension ViewController: UICollectionViewDelegate {
  private func setupCollectionViewDelegate() {
    self.collectionView.delegate = self
  }
}

extension ViewController: SFCollectionViewDelegateCompactLayout {
  private func setupCollectionViewDelegateCompactLayout() {
    self.compactLayout = SFCollectionViewCompactLayout()
    self.compactLayout.delegate = self
    self.collectionView.collectionViewLayout = self.compactLayout
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, isLeftAlignedAt section: Int) -> Bool {
    return true
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let randHeight = CGFloat(integerLiteral: Int.random(in: 44...128))
    let randWidth = CGFloat(integerLiteral: Int.random(in: 44...128))
    let maxWidth = collectionView.frame.width
    return CGSize(width: randWidth, height: randHeight)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
}

//extension ViewController: UICollectionViewDelegateFlowLayout {
//  private func setupCollectionViewDelegateFlowLayout() {
//    self.flowLayout = UICollectionViewFlowLayout()
//    self.collectionView.collectionViewLayout = self.flowLayout
//  }
//
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//    let randHeight = CGFloat(integerLiteral: Int.random(in: 44...128))
//    let randWidth = CGFloat(integerLiteral: Int.random(in: 44...128))
//    let maxWidth = collectionView.frame.width
//    return CGSize(width: maxWidth, height: randHeight)
//  }
//
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//    return 8
//  }
//
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//    return 8
//  }
//}
