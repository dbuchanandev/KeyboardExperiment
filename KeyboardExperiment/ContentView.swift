//
//  ContentView.swift
//  KeyboardExperiment
//
//  Created by Donavon Buchanan on 3/30/23.
//

import Combine
import SwiftUI

// MARK: - KeyboardObserver
class KeyboardObserver: ObservableObject {
  // MARK: Internal
  @Published var isVisible: Bool = false

  // MARK: Private
  private var cancellables = Set<AnyCancellable>()

  init() {
    observeKeyboard()
  }

  private func observeKeyboard() {
    NotificationCenter.default
      .publisher(for: UIWindow.keyboardWillShowNotification)
      .sink { notification in
        // match keyboard animation
        withAnimation {
          self.isVisible = true
        }
      }
      .store(in: &cancellables)

    NotificationCenter.default
      .publisher(for: UIWindow.keyboardWillHideNotification)
      .sink { _ in
        // match keyboard animation
        withAnimation {
          self.isVisible = false
        }
      }
      .store(in: &cancellables)
  }
}

struct ContentView: View {
  @StateObject private var keyboard = KeyboardObserver()
  @FocusState private var textFieldFocus
  @State private var text = ""

  // Make the button animate nicely
  @Namespace private var toolbarNamespace
  let buttonGeoID = "rightToolbarButtonID"
  let toolbarGeoID = "toolbarID"

  var body: some View {
    VStack {
      TextField("Text Field", text: $text)
        .focused($textFieldFocus)
        .padding()
      Text("keyboard.isVisible = \(keyboard.isVisible.description)")
      Spacer()
      toolbar
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  var toolbar: some View {
    Rectangle()
      .fillSwitch(first: materialFill, second: colorFill, enabled: keyboard.isVisible)
      .frame(height: 64)
      .overlay(alignment: .trailing) {
        swappedButton()
          .padding(.trailing)
      }
      .matchedGeometryEffect(id: toolbarGeoID, in: toolbarNamespace)
  }


  @ViewBuilder
  func swappedButton() -> some View {
    if keyboard.isVisible {
      Button {
        textFieldFocus = false
      } label: {
        Image(systemName: "chevron.down")
          .foregroundColor(.white)
          .padding()
          .background {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.blue)
              .matchedGeometryEffect(id: buttonGeoID, in: toolbarNamespace)
          }
      }
    } else {
      Button {
        // some action
      } label: {
        Text("Button")
          .foregroundColor(.white)
          .padding()
          .background {
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.blue)
              .matchedGeometryEffect(id: buttonGeoID, in: toolbarNamespace)
          }
      }
    }
  }

  let materialFill = Material.ultraThin
  let colorFill = Color.gray

}

fileprivate extension Rectangle {
  // F + S generics because they might not be the same underlying types even
  // if they both conform to ShapeStyle
  @ViewBuilder
  func fillSwitch<F: ShapeStyle, S: ShapeStyle>(first: F, second: S, enabled: Bool) -> some View {
    if enabled {
      self.fill(first)
    } else {
      self.fill(second)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
