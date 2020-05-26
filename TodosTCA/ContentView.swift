//
//  ContentView.swift
//  TodosTCA
//
//  Created by Donald McAllister on 5/21/20.
//  Copyright © 2020 Donald McAllister. All rights reserved.
//

import SwiftUI
import Combine
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

//can't sort in here since only working on a single Todo
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
  case todoDelayCompleted
}

struct AppEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>  //AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>
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
    
    case .todo(index: _, action: .checkboxTapped):
      struct CancelDelayId: Hashable {} //visible only in this scope!
      
      return Effect(value: AppAction.todoDelayCompleted)
        .debounce(id: CancelDelayId(), for: 1, scheduler: environment.mainQueue) // dispatchQue is unintended side effect!!
//        .delay(for: 1, scheduler: DispatchQueue.main)
//        .eraseToEffect()
//        .cancellable(id: CancelDelayId(), cancelInFlight: true)
      
     /* second, correct approach, but cancellable has a cancelInFlight to clean up further, see above
      return .concatenate(
        Effect.cancel(id: "completion effect"), //cancel any current effect, then proceed:
        
        Effect(value: AppAction.todoDelayCompleted)
          .delay(for: 1, scheduler: DispatchQueue.main) //need to reset/cancel the 1 sec delay
          .eraseToEffect()
          .cancellable(id: "completion effect")
      )
       */
      
     /* first naive approach to DELAY:
      return Effect.fireAndForget {
        // put sorting work in here? nope it'll capture inout state
        // because we're in an escaping closure, this might mutate value at a future unknown time. We must do this delay instead through sending an Action in.
      }
      .delay(for: 1, scheduler: DispatchQueue.main)
      .eraseToEffect()
 */
      
//      state.todos = state.todos.enumerated().sorted { lhs, rhs in
//        (!lhs.element.isComplete && rhs.element.isComplete) || lhs.offset < rhs.offset
//      }
//      .map { $0.element } //pluck out element, discard the offset
      
     // return .none
      
    case .todo(index: let index, action: let action):
      //where you could layer additional todo actions
      return .none
      
    case .addButtonTapped:
      state.todos.insert(Todo(id: environment.uuid()), at: 0)
      return .none
    case .todoDelayCompleted:
      state.todos = state.todos.enumerated().sorted { lhs, rhs in
        (!lhs.element.isComplete && rhs.element.isComplete) || lhs.offset < rhs.offset
      }
        .map { $0.element } //pluck out element, discard the offset
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
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
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
