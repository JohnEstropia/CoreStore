#if canImport(SwiftUI) && canImport(AppKit)

import AppKit
import Combine
import SwiftUI
import XCTest

@testable
import CoreStore


@MainActor
private final class ObjectPublisherModel: ObservableObject {
    
    @Published var objectPublisher: ObjectPublisher<TestEntity1>?
    
    init(_ objectPublisher: ObjectPublisher<TestEntity1>?) {
        
        self.objectPublisher = objectPublisher
    }
}


@MainActor
private final class ListPublisherModel: ObservableObject {
    
    @Published var listPublisher: ListPublisher<TestEntity1>
    
    init(_ listPublisher: ListPublisher<TestEntity1>) {
        
        self.listPublisher = listPublisher
    }
}


private struct SignalView<Value: Equatable>: View {
    
    let value: Value
    let report: (Value) -> Void
    
    
    var body: some View {
        
        SwiftUI.Color.clear
            .frame(width: 1, height: 1)
            .onChange(of: self.value, initial: true) { _, value in
                
                self.report(value)
            }
    }
}


@MainActor
private struct ObjectStateHarness: View {
    
    @ObservedObject var model: ObjectPublisherModel
    
    let report: (String) -> Void
    
    @ObjectState
    private var object: ObjectSnapshot<TestEntity1>?
    
    init(
        model: ObjectPublisherModel,
        report: @escaping (String) -> Void
    ) {
        
        self.model = model
        self.report = report
        self._object = .init(model.objectPublisher)
    }
    
    
    var body: some View {
        
        SignalView(
            value: self.object?.testString ?? "<nil>",
            report: self.report
        )
    }
}


@MainActor
private struct ListStateHarness: View {
    
    @ObservedObject var model: ListPublisherModel
    
    let report: (String) -> Void
    
    @ListState
    private var list: ListSnapshot<TestEntity1>
    
    init(
        model: ListPublisherModel,
        report: @escaping (String) -> Void
    ) {
        
        self.model = model
        self.report = report
        self._list = .init(model.listPublisher)
    }
    
    
    var body: some View {
        
        SignalView(
            value: listSignature(self.list),
            report: self.report
        )
    }
}


@MainActor
private struct ObjectReaderHarness: View {
    
    @ObservedObject var model: ObjectPublisherModel
    
    let report: (String) -> Void
    
    
    var body: some View {
        
        ObjectReader(
            self.model.objectPublisher,
            keyPath: \.testString,
            content: { value in
                
                SignalView(
                    value: value ?? "<nil>",
                    report: self.report
                )
            },
            placeholder: {
                
                SignalView(
                    value: "<placeholder>",
                    report: self.report
                )
            }
        )
    }
}


@MainActor
private struct ListReaderHarness: View {
    
    @ObservedObject var model: ListPublisherModel
    
    let report: (String) -> Void
    
    
    var body: some View {
        
        ListReader(self.model.listPublisher) { list in
            
            SignalView(
                value: listSignature(list),
                report: self.report
            )
        }
    }
}


@MainActor
private func listSignature(_ list: ListSnapshot<TestEntity1>) -> String {
    
    let ids = list.map {
        
        String($0.testEntityID?.intValue ?? -1)
    }
    .joined(separator: ",")
    return ids.isEmpty ? "<empty>" : ids
}


// MARK: - SwiftUIReaderStateTests

@MainActor
final class SwiftUIReaderStateTests: BaseTestDataTestCase {
    
    @objc
    dynamic func test_ThatObjectState_RebindsWhenPublisherChanges() {
        
        self.prepareStack { stack in
            
            self.prepareTestDataForStack(stack)
            
            let firstPublisher = self.objectPublisher(withID: 101, in: stack)
            let secondPublisher = self.objectPublisher(withID: 102, in: stack)
            let model = ObjectPublisherModel(firstPublisher)
            
            let initialExpectation = self.expectation(description: "initial")
            let swappedExpectation = self.expectation(description: "swapped")
            let finalExpectation = self.expectation(description: "final")
            let staleExpectation = self.expectation(description: "stale")
            staleExpectation.isInverted = true
            
            var didSeeInitial = false
            var didSeeSwapped = false
            var didSeeFinal = false
            var values: [String] = []
            
            let window = self.host(
                ObjectStateHarness(model: model) { value in
                    
                    values.append(value)
                    switch value {
                        
                    case "nil:TestEntity1:1" where !didSeeInitial:
                        didSeeInitial = true
                        initialExpectation.fulfill()
                        
                    case "nil:TestEntity1:2" where !didSeeSwapped:
                        didSeeSwapped = true
                        swappedExpectation.fulfill()
                        
                    case "new-bound" where !didSeeFinal:
                        didSeeFinal = true
                        finalExpectation.fulfill()
                        
                    case "old-bound":
                        staleExpectation.fulfill()
                        
                    default:
                        break
                    }
                }
            )
            
            self.wait(for: [initialExpectation], timeout: 10)
            
            model.objectPublisher = secondPublisher
            self.wait(for: [swappedExpectation], timeout: 10)
            
            self.updateObjectString(withID: 101, to: "old-bound", in: stack)
            self.updateObjectString(withID: 102, to: "new-bound", in: stack)
            self.wait(for: [finalExpectation, staleExpectation], timeout: 10)
            
            XCTAssertFalse(values.contains("old-bound"))
            withExtendedLifetime(window, {})
        }
    }
    
    @objc
    dynamic func test_ThatListState_RebindsWhenPublisherChanges() {
        
        self.prepareStack { stack in
            
            self.prepareTestDataForStack(stack)
            
            let firstPublisher = self.listPublisher(matching: true, in: stack)
            let secondPublisher = self.listPublisher(matching: false, in: stack)
            let model = ListPublisherModel(firstPublisher)
            
            let initialExpectation = self.expectation(description: "initial")
            let swappedExpectation = self.expectation(description: "swapped")
            let finalExpectation = self.expectation(description: "final")
            let staleExpectation = self.expectation(description: "stale")
            staleExpectation.isInverted = true
            
            var didSeeInitial = false
            var didSeeSwapped = false
            var didSeeFinal = false
            var values: [String] = []
            
            let window = self.host(
                ListStateHarness(model: model) { value in
                    
                    values.append(value)
                    switch value {
                        
                    case "101,103,105" where !didSeeInitial:
                        didSeeInitial = true
                        initialExpectation.fulfill()
                        
                    case "102,104" where !didSeeSwapped:
                        didSeeSwapped = true
                        swappedExpectation.fulfill()
                        
                    case "102,104,108" where !didSeeFinal:
                        didSeeFinal = true
                        finalExpectation.fulfill()
                        
                    case "101,103,105,107":
                        staleExpectation.fulfill()
                        
                    default:
                        break
                    }
                }
            )
            
            self.wait(for: [initialExpectation], timeout: 10)
            
            model.listPublisher = secondPublisher
            self.wait(for: [swappedExpectation], timeout: 10)
            
            self.insertObject(withID: 107, string: "old-list", boolean: true, in: stack)
            self.insertObject(withID: 108, string: "new-list", boolean: false, in: stack)
            self.wait(for: [finalExpectation, staleExpectation], timeout: 10)
            
            XCTAssertFalse(values.contains("101,103,105,107"))
            withExtendedLifetime(window, {})
        }
    }
    
    @objc
    dynamic func test_ThatObjectReaders_RebindAndShowCustomPlaceholders() {
        
        self.prepareStack { stack in
            
            self.prepareTestDataForStack(stack)
            
            let firstPublisher = self.objectPublisher(withID: 101, in: stack)
            let secondPublisher = self.objectPublisher(withID: 102, in: stack)
            let model = ObjectPublisherModel(firstPublisher)
            
            let initialExpectation = self.expectation(description: "initial")
            let swappedExpectation = self.expectation(description: "swapped")
            let placeholderExpectation = self.expectation(description: "placeholder")
            let staleExpectation = self.expectation(description: "stale")
            staleExpectation.isInverted = true
            
            var didSeeInitial = false
            var didSeeSwapped = false
            var didSeePlaceholder = false
            var values: [String] = []
            
            let window = self.host(
                ObjectReaderHarness(model: model) { value in
                    
                    values.append(value)
                    switch value {
                        
                    case "nil:TestEntity1:1" where !didSeeInitial:
                        didSeeInitial = true
                        initialExpectation.fulfill()
                        
                    case "nil:TestEntity1:2" where !didSeeSwapped:
                        didSeeSwapped = true
                        swappedExpectation.fulfill()
                        
                    case "<placeholder>" where !didSeePlaceholder:
                        didSeePlaceholder = true
                        placeholderExpectation.fulfill()
                        
                    case "old-reader":
                        staleExpectation.fulfill()
                        
                    default:
                        break
                    }
                }
            )
            
            self.wait(for: [initialExpectation], timeout: 10)
            
            model.objectPublisher = secondPublisher
            self.wait(for: [swappedExpectation], timeout: 10)
            
            self.deleteObject(withID: 102, in: stack)
            self.updateObjectString(withID: 101, to: "old-reader", in: stack)
            self.wait(for: [placeholderExpectation, staleExpectation], timeout: 10)
            
            XCTAssertFalse(values.contains("old-reader"))
            withExtendedLifetime(window, {})
        }
    }
    
    @objc
    dynamic func test_ThatListReaders_RebindWhenPublisherChanges() {
        
        self.prepareStack { stack in
            
            self.prepareTestDataForStack(stack)
            
            let firstPublisher = self.listPublisher(matching: true, in: stack)
            let secondPublisher = self.listPublisher(matching: false, in: stack)
            let model = ListPublisherModel(firstPublisher)
            
            let initialExpectation = self.expectation(description: "initial")
            let swappedExpectation = self.expectation(description: "swapped")
            let finalExpectation = self.expectation(description: "final")
            let staleExpectation = self.expectation(description: "stale")
            staleExpectation.isInverted = true
            
            var didSeeInitial = false
            var didSeeSwapped = false
            var didSeeFinal = false
            var values: [String] = []
            
            let window = self.host(
                ListReaderHarness(model: model) { value in
                    
                    values.append(value)
                    switch value {
                        
                    case "101,103,105" where !didSeeInitial:
                        didSeeInitial = true
                        initialExpectation.fulfill()
                        
                    case "102,104" where !didSeeSwapped:
                        didSeeSwapped = true
                        swappedExpectation.fulfill()
                        
                    case "102,104,110" where !didSeeFinal:
                        didSeeFinal = true
                        finalExpectation.fulfill()
                        
                    case "101,103,105,109":
                        staleExpectation.fulfill()
                        
                    default:
                        break
                    }
                }
            )
            
            self.wait(for: [initialExpectation], timeout: 10)
            
            model.listPublisher = secondPublisher
            self.wait(for: [swappedExpectation], timeout: 10)
            
            self.insertObject(withID: 109, string: "old-reader", boolean: true, in: stack)
            self.insertObject(withID: 110, string: "new-reader", boolean: false, in: stack)
            self.wait(for: [finalExpectation, staleExpectation], timeout: 10)
            
            XCTAssertFalse(values.contains("101,103,105,109"))
            withExtendedLifetime(window, {})
        }
    }
    
    
    // MARK: Private
    
    private func host<Content: View>(_ view: Content) -> NSWindow {
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 8, height: 8),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: view)
        window.contentView?.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        return window
    }
    
    private func objectPublisher(
        withID identifier: Int,
        in stack: DataStack
    ) -> ObjectPublisher<TestEntity1> {
        
        let object = try! stack.fetchOne(
            From<TestEntity1>(),
            Where<TestEntity1>(
                #keyPath(TestEntity1.testEntityID),
                isEqualTo: NSNumber(value: identifier)
            )
        )!
        return stack.publishObject(object)
    }
    
    private func listPublisher(
        matching boolean: Bool,
        in stack: DataStack
    ) -> ListPublisher<TestEntity1> {
        
        return stack.publishList(
            From<TestEntity1>(),
            Where<TestEntity1>(
                #keyPath(TestEntity1.testBoolean),
                isEqualTo: NSNumber(value: boolean)
            ),
            OrderBy<TestEntity1>(.ascending(#keyPath(TestEntity1.testEntityID)))
        )
    }
    
    private func updateObjectString(
        withID identifier: Int,
        to string: String,
        in stack: DataStack
    ) {
        
        try! stack.perform(
            synchronous: { transaction in
                
                let object = try transaction.fetchOne(
                    From<TestEntity1>(),
                    Where<TestEntity1>(
                        #keyPath(TestEntity1.testEntityID),
                        isEqualTo: NSNumber(value: identifier)
                    )
                )!
                object.testString = string
            }
        )
    }
    
    private func deleteObject(
        withID identifier: Int,
        in stack: DataStack
    ) {
        
        try! stack.perform(
            synchronous: { transaction in
                
                let object = try transaction.fetchOne(
                    From<TestEntity1>(),
                    Where<TestEntity1>(
                        #keyPath(TestEntity1.testEntityID),
                        isEqualTo: NSNumber(value: identifier)
                    )
                )!
                transaction.delete(object)
            }
        )
    }
    
    private func insertObject(
        withID identifier: Int,
        string: String,
        boolean: Bool,
        in stack: DataStack
    ) {
        
        try! stack.perform(
            synchronous: { transaction in
                
                let object = transaction.create(Into<TestEntity1>())
                object.testEntityID = NSNumber(value: identifier)
                object.testString = string
                object.testBoolean = NSNumber(value: boolean)
            }
        )
    }
}

#endif
