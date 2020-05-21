//
//  ContentView.swift
//  TodosTCA
//
//  Created by Donald McAllister on 5/21/20.
//  Copyright © 2020 Donald McAllister. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

/**************************
 Todo Domain
 **************************/

struct Todo: Equatable, Identifiable {
  var description = ""
  let id: UUID
  var isComplete = false
}

//want a reducer to focus on domain of a single todo:
// ForEach higher order reducer to abstract away lists of states
// notice no index passed in and no "todo" preceding case name
enum TodoAction: Equatable {
  case checkboxTapped
  case textFieldChanged(String)
}

struct TodoEnvironment { }

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
  switch action {
  case .checkboxTapped:
    state.isComplete.toggle()
    return .none
  case .textFieldChanged(let text):
    state.description = text
    return .none
  }
  
}

/**************************
 Core Domain of Application
 **************************/

struct AppState: Equatable {
  var todos: [Todo] = []
}



enum AppAction: Equatable {
  //single row action, index:
  case todo(index: Int, action: TodoAction)
  case addButtonTapped
}

struct AppEnvironment {
  var uuid: () -> UUID //exact shape of uuid initializer
}

/**************************
 APP REDUCER
 **************************/
let appReducer = Reducer<AppState,AppAction, AppEnvironment>.combine(
  todoReducer.forEach(
    state: \AppState.todos,
    action: /AppAction.todo(index:action:),
    environment: { _ in TodoEnvironment() }
  ),
  Reducer { state, action, environment in
    switch action {
    case .todo(index: let index, action: let action):
      //where you could layer additional todo actions
      return .none
    case .addButtonTapped:
      state.todos.insert(Todo(id: environment.uuid()), at: 0)
      return .none
    }
  }
)
  .debug()




struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        List {
          ForEachStore(
            self.store.scope(state: \.todos, action: AppAction.todo(index:action:)),
            content: TodoView.init(store:)
          )
        }
        .navigationBarTitle("Todos")
        .navigationBarItems(trailing: Button("Add") {
          viewStore.send(.addButtonTapped)
        })
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
        environment: AppEnvironment(
          uuid: UUID.init
        )
      )
    )
  }
}

struct TodoView: View {
  let store: Store<Todo, TodoAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack {
        Button(action: { viewStore.send(.checkboxTapped) }) {
          Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(PlainButtonStyle())
        TextField("Untitled todo",
                  text: viewStore.binding(
                    get: \.description,
                    send: TodoAction.textFieldChanged
          )
        )
      }
      .foregroundColor(viewStore.isComplete ? .gray : nil)
    }
  }
}
