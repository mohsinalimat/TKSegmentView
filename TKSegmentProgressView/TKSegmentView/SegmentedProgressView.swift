//
//  SegmentedProgressView.swift
//  Pods
//
//  Created by Sapozhnik Ivan on 12/05/17.
//
//

import UIKit

public class TKSegmentProgressView: UIView, ProgressBarElementViewDelegate {
    
    public weak var delegate: ProgressBarDelegate?
    
    override public var frame: CGRect {
        didSet {
            redraw()
        }
    }
    
    public var progressTintColor: UIColor? {
        didSet {
            redraw()
        }
    }
    
    public var trackTintColor: UIColor? {
        didSet {
            redraw()
        }
    }
    
    public var itemSpace: Double? {
        didSet {
            redraw()
        }
    }
    
    public var items: [ProgressItem]? {
        didSet {
            redraw()
        }
    }

    public var isAutoProgress: Bool = false

    var elementViews: [SegmentView] = []

    var currentIndex: Int = 0

    public init(withItems items: [ProgressItem]!) {
        self.items = items
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    fileprivate func redraw() {
        clear()
        draw()
    }
    
    fileprivate func clear() {
        
        elementViews.removeAll()
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    fileprivate func draw() {
        
        let items = self.items ?? [ProgressItem(withDuration: 6) { print("finished 0") }]
        
        let horizontalSpace: Double = itemSpace ?? 6.0
        
        var elementWidth = ((Double(bounds.width) + horizontalSpace) / Double(items.count))
        elementWidth -= horizontalSpace
        
        if elementWidth <= 0 { return }
        
        var xOffset: Double = 0.0
        
        for item in items {
            
            let elementView = SegmentView(withItem: item)
            elementView.progressTintColor = self.progressTintColor
            elementView.trackTintColor = self.trackTintColor
            elementView.delegate = self
            elementView.frame = CGRect(x: xOffset, y: 0, width: elementWidth, height: Double(bounds.height))
            elementView.drawEmpty()
            self.addSubview(elementView)
            elementViews.append(elementView)
            xOffset += elementWidth + horizontalSpace
        }
        
        let elementView = elementViews[0]
        delegate?.progressBar(willDisplayItemAtIndex: 0)
        elementView.animate()
    }


    public func selectItem(at index: Int) {

        if index >= currentIndex {
            currentIndex = index
        }

        for (indx, elementview)in elementViews.enumerated() {
            if index == indx {
                elementview.animate()
                delegate?.progressBar(willDisplayItemAtIndex: index)
                currentIndex = index
            } else if indx < currentIndex {
                elementview.drawFilled()
            } else {
                elementview.drawEmpty()
            }
        }
    }


    public func progressBar(didFinishWithElement element: SegmentView) {
        
        let elements = self.items ?? [ProgressItem(withDuration: 6) { print("finished 0") }]
        
        if var index = elementViews.index(of: element) {
            
            delegate?.progressBar(didDisplayItemAtIndex: index)

            if isAutoProgress {
                index += 1
                if index < elements.count {
                    let elementView = elementViews[index]
                    delegate?.progressBar(willDisplayItemAtIndex: index)
                    currentIndex = index
                    elementView.animate()
                }
            }
        }
    }
}
