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
    
}

struct AppEnvironment {}

/**************************
        APP REDUCER
 **************************/
//hand closure to the initializer of Reducer:
let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
        //business logic
    }
}



struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.state.todos) { todo in
                        Text(todo.description)
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
                            isComplete: false
                        ),
                    ]
                ),
                reducer: appReducer,
                environment: AppEnvironment())
        )
    }
}
