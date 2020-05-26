//
//  TodosTCATests.swift
//  TodosTCATests
//
//  Created by Donald McAllister on 5/21/20.
//  Copyright © 2020 Donald McAllister. All rights reserved.
//
import ComposableArchitecture
import XCTest
@testable import TodosTCA

class TodosTCATests: XCTestCase {
  func testCompletingTodo() {
    let store = TestStore(
      initialState: AppState(
      todos: [
        Todo(
          description: "Milk",
          id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
          isComplete: false
        )]
      ),
      reducer: appReducer,
      environment: AppEnvironment(uuid: { fatalError("unimplemented") }))
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
      },
      .receive(.todoDelayCompleted)
    )
  }
  
  func testAddTodo() {
    let store = TestStore(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")! }
      )
    )
    store.assert(
      .send(.addButtonTapped) {
        $0.todos = [
          Todo(
            description: "",
            id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!, 
            isComplete: false
          )
        ]
      }
    )
  }
  
  func testTodoSorting() {
    let store = TestStore(
      initialState: AppState(
        todos: [
          Todo(
            description: "Milk",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            isComplete: false
          ),
          Todo(
            description: "Eggs",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            isComplete: false
          )
        ]
      ),
      reducer: appReducer,
      environment: AppEnvironment(uuid: { fatalError("unimplemented") }))
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
      },
      .receive(.todoDelayCompleted) {
        $0.todos.swapAt(0, 1)
      }
    )
  }
  
  
  func testTodoSorting_Cancellation() {
    let store = TestStore(
      initialState: AppState(
        todos: [
          Todo(
            description: "Milk",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            isComplete: false
          ),
          Todo(
            description: "Eggs",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            isComplete: false
          )
        ]
      ),
      reducer: appReducer,
      environment: AppEnvironment(uuid: { fatalError("unimplemented") }))
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 0.5)
      },
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = false
      },
      .do {
        _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
      },
      .receive(.todoDelayCompleted)
      //  $0.todos.swapAt(0, 1)
      
    )
  }
}
