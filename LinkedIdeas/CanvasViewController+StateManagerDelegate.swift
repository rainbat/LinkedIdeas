//
//  CanvasViewController+StateManagerDelegate.swift
//  LinkedIdeas
//
//  Created by Felipe Espinoza Castillo on 16/02/2017.
//  Copyright © 2017 Felipe Espinoza Dev. All rights reserved.
//

import Cocoa

// MARK: - CanvasViewController+StateManagerDelegate

extension CanvasViewController: StateManagerDelegate {
  func transitionSuccesfull() {
    reRenderCanvasView()
  }

  func transitionedToNewConcept(fromState: CanvasState) {
    guard case .newConcept(let point) = currentState else {
      return
    }

    commonTransitionBehavior(fromState)

    showTextField(atPoint: point)
  }

  func transitionedToCanvasWaiting(fromState: CanvasState) {
    commonTransitionBehavior(fromState)
  }

  func transitionedToCanvasWaitingSavingConcept(fromState: CanvasState, point: NSPoint, text: NSAttributedString) {
    dismissTextField()
    let _ = saveConcept(text: text, atPoint: point)
  }

  func transitionedToSelectedElement(fromState: CanvasState) {
    commonTransitionBehavior(fromState)

    guard case .selectedElement(let element) = currentState else {
      return
    }

    select(elements: [element])
  }

  func transitionedToMultipleSelectedElements(fromState: CanvasState) {
    commonTransitionBehavior(fromState)

    guard case .multipleSelectedElements(let elements) = currentState else {
      return
    }

    select(elements: elements)
  }

  func transitionedToSelectedElementSavingChanges(fromState: CanvasState) {
    guard case .selectedElement(var element) = currentState else {
      return
    }
    element.attributedStringValue = textField.attributedStringValue
    dismissTextField()

    transitionedToSelectedElement(fromState: fromState)
  }

  func transitionedToEditingElement(fromState: CanvasState) {
    commonTransitionBehavior(fromState)

    guard case .editingElement(var element) = currentState else {
      return
    }

    element.isEditable = true

    showTextField(atPoint: element.point, text: element.attributedStringValue)
  }

  func transitionedToCanvasWaitingDeletingElements(fromState: CanvasState) {
    commonTransitionBehavior(fromState)

    switch fromState {
    case .selectedElement(let element):
      guard let concept = element as? Concept else {
        return
      }
      let linksToRemove = document.links.filter { $0.origin == concept || $0.target == concept }
      for link in linksToRemove {
        document.remove(link: link)
      }
      document.remove(concept: concept)
    case .multipleSelectedElements(let elements):
      for element in elements {
        guard let concept = element as? Concept else {
          continue
        }
        let linksToRemove = document.links.filter { $0.origin == concept || $0.target == concept }
        for link in linksToRemove {
          document.remove(link: link)
        }
        document.remove(concept: concept)
      }
    default:
      break
    }
  }

  private func commonTransitionBehavior(_ fromState: CanvasState) {
    switch fromState {
    case .newConcept:
      dismissTextField()
    case .editingElement(var element):
      element.isEditable = false
      dismissTextField()
    case .selectedElement(let element):
      unselect(elements: [element])
      dismissConstructionArrow()
    case .multipleSelectedElements(let elements):
      unselect(elements: elements)
    default:
      break
    }
  }
}
