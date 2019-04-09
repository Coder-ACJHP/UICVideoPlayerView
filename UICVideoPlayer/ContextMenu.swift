//
//  ContextMenu.swift
//  UICVideoPlayer
//
//  Created by akademobi5 on 9.04.2019.
//  Copyright © 2019 Onur Işık. All rights reserved.
//

import UIKit

class ContextMenu: UIView, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var shadowView: UIView!
    private var contextMenu: UIView!
    private let contextMenuHeight: CGFloat = 250
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    
    private lazy var keyWindowFrame: CGRect = {
        if let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow.frame
        }
        return .zero
    }()
    
    private let cellId = "customCellId"
    private var settingList = [
        Setting(image: #imageLiteral(resourceName: "quality"), kind: .Quality, name: "Video quality . Auto(720px)"),
        Setting(image: #imageLiteral(resourceName: "playbackSpeed"), kind: .PlayBackSpeed, name: "Playback speed"),
        Setting(image: #imageLiteral(resourceName: "caption"), kind: .Captions, name: "Captions"),
        Setting(image: #imageLiteral(resourceName: "report"), kind: .Report, name: "Report"),
        Setting(image: #imageLiteral(resourceName: "help"), kind: .Help, name: "Help & feedback"),
        Setting(image: #imageLiteral(resourceName: "cancel"), kind: .Cancel, name: "Cancel & dismiss"),
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        shadowView = UIView(frame: keyWindow.bounds)
        shadowView.tag = 1000
        shadowView!.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        shadowView!.addGestureRecognizer(tapGesture)
        keyWindow.addSubview(shadowView!)
        
        contextMenu = UIView(frame: CGRect(x: 0, y: keyWindowFrame.height, width: keyWindowFrame.width, height: 0))
        contextMenu.backgroundColor = .white
        shadowView.addSubview(contextMenu)
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        contextMenu.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: keyWindowFrame.width, height: self.contextMenuHeight)
        collectionView.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showContextMenu() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseIn,
                       animations: {
                        let contextMenuFrame = CGRect(x: 0, y: self.keyWindowFrame.height - self.contextMenuHeight, width: self.keyWindowFrame.width, height: self.contextMenuHeight)
                        self.contextMenu.frame = contextMenuFrame
        }, completion: nil)
    }
    
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        guard let tappedView = gestureRecognizer.view else { return }
        
        if tappedView.tag == shadowView.tag {
            removeContextMenu()
        }
    }
    
    
    fileprivate func removeContextMenu() {
    
        UIView.transition(with: shadowView,
                          duration: 0.3,
                          options: .curveEaseOut,
                          animations: {
                            
                            self.contextMenu.frame = CGRect(x: 0,
                                                            y: self.keyWindowFrame.height,
                                                            width: self.keyWindowFrame.width,
                                                            height: 0)
                            self.shadowView.alpha = 0
        }) { (_) in
            self.shadowView.removeFromSuperview()
        }
    }
    
    // Best comparition way to detect tapped view (for subviews)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingCell
        cell.setting = settingList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! SettingCell
        if selectedCell.setting.kind == .Cancel {
            removeContextMenu()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: keyWindowFrame.width, height: contextMenuHeight / CGFloat(settingList.count) - 7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 10, left: 0, bottom: 0, right: 0)
    }
}

enum SettingKind: String {
    case Quality = "Quality"
    case Captions = "Captions"
    case Report = "Report"
    case Help = "Help & feedback"
    case PlayBackSpeed = "Playback speed"
    case Cancel = "Cancel & dismiss"
}

struct Setting {
    var image: UIImage!
    var kind: SettingKind!
    var name: String?
}

class SettingCell: UICollectionViewCell {
    
    var setting: Setting! {
        didSet {
            imageView.image = setting.image?.withRenderingMode(.alwaysTemplate)
            nameLabel.text = setting.name
        }
    }
    
    private lazy var darkestGray = UIColor.init(white: 0.30, alpha: 1.0)
    
    override var isSelected: Bool {
        didSet {
            imageView.tintColor = isSelected ? .white : darkestGray
            nameLabel.textColor = isSelected ? .white : .black
            backgroundColor = isSelected ? .lightGray : .clear
        }
    }
    
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.tintColor = darkestGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        nameLabel = UILabel(frame: .zero)
        nameLabel.textColor = .black
        nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
