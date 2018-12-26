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
    @IBOutlet weak var layout: SFCollectionViewCompactLayout!

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
        self.setupCollectionViewDelegateCompactLayout()
        self.setupCollectionViewDelegate()
        self.setupCollectionViewDataSource()
    }
}

extension ViewController: UICollectionViewDataSource {
    private func setupCollectionViewDataSource() {
        self.collectionView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        cell.titleLabel.text = "\(indexPath.item) " + self.randomString("qwertyuiopasdfghjklzxcvbnm", length: 10)
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
        let layout = SFCollectionViewCompactLayout()
        layout.delegate = self
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        self.collectionView.collectionViewLayout = layout
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let randInt = Int.random(in: 44...60)
        let randHeight = CGFloat(integerLiteral: randInt)
        let randWidth = CGFloat(integerLiteral: randInt)
        return CGSize(width: randWidth, height: randHeight)
    }
}
