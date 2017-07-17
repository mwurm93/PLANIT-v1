//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
//
//  JRTableViewCell.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class JRTableViewCell: UITableViewCell {
    private var _bottomLineColor: UIColor?
    var bottomLineColor: UIColor? {
        get {
            return _bottomLineColor
        }
        set(bottomLineColor) {
            _bottomLineColor = bottomLineColor
            bottomLine.setImage(UIImage(color: _bottomLineColor))
        }
    }
    var isBottomLineVisible: Bool {
        get {
            return !bottomLine.isHidden
        }
        set(bottomLineVisible) {
            bottomLine.isHidden = !bottomLineVisible
        }
    }
    var isShowLastLine: Bool = false
    private var _leftOffset: CGFloat = 0.0
    var leftOffset: CGFloat {
        get {
            return _leftOffset
        }
        set(leftOffset) {
            bottomLineInsets.left = leftOffset
            bottomLineInsets = bottomLineInsets
        }
    }
    private var _bottomLineInsets = UIEdgeInsets()
    var bottomLineInsets: UIEdgeInsets {
        get {
            return _bottomLineInsets
        }
        set(bottomLineInsets) {
            _bottomLineInsets = bottomLineInsets
            leadingConstraint.constant = _bottomLineInsets.left
            trailingConstraint.constant = _bottomLineInsets.right
            bottomConstraint.constant = _bottomLineInsets.bottom()
        }
    }
    var customBackgroundView: UIView?
    var customSelectedBackgroundView: UIView?

    var bottomLine: UIImageView?
    var leadingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?

    func updateBackgroundViews(forImagePath indexPath: IndexPath, in tableView: UITableView) {
        if isBottomLineVisible && !isShowLastLine {
            let bottomLineHidden: Bool = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            setBottomLineVisible(!bottomLineHidden)
        }
        backgroundColor = nil
        backgroundView = customBackgroundView as? UIView ?? UIView()
        selectedBackgroundView = customSelectedBackgroundView
    }

    func initialSetup() {
        let scaleToFillView = UIView()
        scaleToFillView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(scaleToFillView, at: 0)
        addConstraints(JRConstraintsMakeScaleToFill(scaleToFillView, self))
        customBackgroundView = UIView()
        customBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
        customBackgroundView?.backgroundColor = JRColorScheme.itemsBackgroundColor()
        addSubview(customBackgroundView!)
        addConstraints(JRConstraintsMakeScaleToFill(customBackgroundView, scaleToFillView))
        customSelectedBackgroundView = UIView()
        customSelectedBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
        customSelectedBackgroundView?.backgroundColor = JRColorScheme.itemsSelectedBackgroundColor()
        customSelectedBackgroundView?.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        bottomLine = UIImageView()
        bottomLine?.translatesAutoresizingMaskIntoConstraints = false
        customBackgroundView?.addSubview(bottomLine!)
        leadingConstraint = JRConstraintMake(bottomLine, .leading, .equal, customBackgroundView, .leading, 1, 0)
        customBackgroundView?.addConstraint(leadingConstraint!)
        trailingConstraint = JRConstraintMake(customBackgroundView, .trailing, .equal, bottomLine, .trailing, 1, 0)
        customBackgroundView?.addConstraint(trailingConstraint!)
        bottomConstraint = JRConstraintMake(customBackgroundView, .bottom, .equal, bottomLine, .bottom, 1, 0)
        customBackgroundView?.addConstraint(bottomConstraint!)
        customBackgroundView?.addConstraint(JRConstraintMake(bottomLine, .height, .equal, nil, .notAnAttribute, 1, JRPixel()))
        bottomLine?.isHidden = true
        setLeftOffset(leftOffset)
        setBottomLineInsets(bottomLineInsets)
        setBottomLineColor(JRColorScheme.separatorLineColor())
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier as? String ?? "")
        
        initialSetup()
    
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
}