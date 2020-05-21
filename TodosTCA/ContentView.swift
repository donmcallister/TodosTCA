//
//  ContentView.swift
//  TodosTCA
//
//  Created by Donald McAllister on 5/21/20.
//  Copyright © 2020 Donald McAllister. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
  var description = ""
  let id: UUID
  var isComplete = false
}

/**************************
 Core Domain of Application
 **************************/

struct AppState: Equatable {
  var todos: [Todo] = []
}

enum AppAction {
  case todoCheckboxTapped(index: Int)
  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {}

/**************************
 APP REDUCER
 **************************/
//hand closure to the initializer of Reducer:
let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
    //business logic
  case .todoCheckboxTapped(index: let index):
    state.todos[index].isComplete.toggle()
    return .none
  case .todoTextFieldChanged(index: let index, text: let text):
    state.todos[index].description = text
    return .none
  }
}.debug()



struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        List {
          ForEach(Array(viewStore.state.todos.enumerated()), id: \.element.id) { index, todo in
            HStack {
              Button(action: { viewStore.send(.todoCheckboxTapped(index: index))}) {
                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
              }
                .buttonStyle(PlainButtonStyle()) //prevent entire row from being selected
              TextField("Untitled todo",
                        text: viewStore.binding(
                          get: { $0.todos[index].description },
                          send: { .todoTextFieldChanged(index: index, text: $0)}
                )
                /*.constant(todo.description)*/
              )
              //Text(todo.description)
            }
            .foregroundColor(todo.isComplete ? .gray : nil)
          }
        }
        .navigationBarTitle("Todos")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(
          todos: [
            Todo(
              description: "Milk",
              id: UUID(),
              isComplete: false
            ),
            Todo(
              description: "Eggs",
              id: UUID(),
              isComplete: false
            ),
            Todo(
              description: "Hand Soap",
              id: UUID(),
              isComplete: true
            ),
          ]
        ),
        reducer: appReducer,
        environment: AppEnvironment())
    )
  }
}
