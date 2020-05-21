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
enum TodoAction {
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



enum AppAction {
  //single row action, index:
  case todo(index: Int, action: TodoAction)
  //  case todoCheckboxTapped(index: Int)
  //  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {}

/**************************
 APP REDUCER
 **************************/
//hand closure to the initializer of Reducer:
let appReducer: Reducer<AppState,AppAction, AppEnvironment> = todoReducer.forEach(
  state: \AppState.todos,
  action: /AppAction.todo(index:action:),
  environment: { _ in TodoEnvironment() }
)
  .debug()

//  Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
//  switch action {
//    //business logic
//  case .todoCheckboxTapped(index: let index):
//    state.todos[index].isComplete.toggle()
//    return .none
//  case .todoTextFieldChanged(index: let index, text: let text):
//    state.todos[index].description = text
//    return .none
//  }
//}.debug()



struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        List {
          ForEachStore(
            self.store.scope(
              //get local from global
              state: \.todos, //{ $0.todos },
              //embed local into global domain
              action:  AppAction.todo(index:action:) )
          ) { todoStore in
            //below was wrapped in another WithViewStore(todoStore)...
            TodoView(store: todoStore)
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
