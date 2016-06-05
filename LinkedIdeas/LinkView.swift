//
//  LinkView.swift
//  LinkedIdeas
//
//  Created by Felipe Espinoza Castillo on 26/03/16.
//  Copyright © 2016 Felipe Espinoza Dev. All rights reserved.
//

import Cocoa

class LinkView: NSView, CanvasElement, ArrowDrawable, ClickableView, LinkViewActions, HoveringView {
  // own
  var link: Link
  var arrowPath: NSBezierPath? { return constructArrow()?.bezierPath() }
  
  // MARK: - HoveringView
  var isHoveringView: Bool = false {
    didSet { needsDisplay = true }
  }
  
  // CanvasElement
  var canvas: CanvasView
  
  override var description: String {
    return "[LinkView][\(link.identifier)]"
  }
  
  init(link: Link, canvas: CanvasView) {
    self.link = link
    self.canvas = canvas
    super.init(frame: link.rect)
    enableTrackingArea()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - NSResponder
  
  override var acceptsFirstResponder: Bool { return true }
  
  // MARK: - NSView
  
  override func drawRect(dirtyRect: NSRect) {
    drawArrow()
    if (link.isSelected) { drawArrowBorder() }
    drawHoveringState()
  }
  
  // MARK: - ArrowDrawable
  
  func constructArrow() -> Arrow? {
    let originPoint = link.originPoint
    let targetPoint = link.targetPoint
    
    let originRect = canvas.conceptViewFor(link.origin).frame
    let targetRect = canvas.conceptViewFor(link.target).frame
    
    if let intersectionPointWithOrigin = originRect.firstIntersectionTo(targetPoint), intersectionPointWithTarget = targetRect.firstIntersectionTo(originPoint) {
      let intersectionPointWithOriginInLinkViewCoordinates = convertPoint(intersectionPointWithOrigin, fromView: canvas)
      let intersectionPointWithTargetInLinkViewCoordinates = convertPoint(intersectionPointWithTarget, fromView: canvas)
      
      return Arrow(p1: intersectionPointWithOriginInLinkViewCoordinates, p2: intersectionPointWithTargetInLinkViewCoordinates)
    } else {
      return nil
    }
  }
  
  func drawArrow() {
    link.color.set()
    arrowPath?.fill()
  }
  
  func drawArrowBorder() {
    NSColor.blackColor().set()
    arrowPath?.stroke()
  }
  
  // MARK: - Mouse Events
  
  override func mouseDown(theEvent: NSEvent) {
    sprint("mouse down")
    let point = convertPoint(theEvent.locationInWindow, fromView: nil)
    if let arrowPath = arrowPath where arrowPath.containsPoint(point) {
      click(point)
    } else {
      super.mouseDown(theEvent)
    }
  }
  
  override func mouseEntered(theEvent: NSEvent) {
    isHoveringView = true
    super.mouseEntered(theEvent)
  }
  
  override func mouseExited(theEvent: NSEvent) {
    isHoveringView = false
    super.mouseExited(theEvent)
  }
  
  // MARK: - Keyboard Events
  
  let deleteKeyCode: UInt16 = 51
  override func keyDown(theEvent: NSEvent) {
    sprint("keyDown \(theEvent.keyCode)")
    if (theEvent.keyCode == deleteKeyCode) {
      pressDeleteKey()
    } else {
      super.keyDown(theEvent)
    }
  }
  
  // MARK: - ClickableView
  
  func click(point: NSPoint) {
    canvas.unselectConcepts()
    canvas.unselectLinks()
    selectLink()
    (window?.windowController as? WindowController)?.selectedColor = link.color
  }
  
  func doubleClick(point: NSPoint) {}
  
  // MARK: - LinkViewActions
  
  func selectLink() {
    link.isSelected = true
    becomeFirstResponder()
    needsDisplay = true
  }
  
  func pressDeleteKey() {
    canvas.removeLinkView(self)
  }
}
