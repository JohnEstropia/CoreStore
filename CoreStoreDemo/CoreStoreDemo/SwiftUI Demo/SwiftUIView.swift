//
//  SwiftUIView.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2019/10/02.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

#if canImport(SwiftUI)

import SwiftUI
import CoreStore

@available(iOS 13.0, *)
struct DataStackEnvironment: EnvironmentKey {

    static let defaultValue = ColorsDemo.stack
}


@available(iOS 13.0.0, *)
extension EnvironmentValues {

    var dataStack: DataStack {
        get {
            return self[DataStackEnvironment.self]
        }
        set {
            self[DataStackEnvironment.self] = newValue
        }
    }
}

@available(iOS 13.0.0, *)
struct SwiftUIView: View {
    
    @Environment(\.dataStack) var dataStack: DataStack

    @ObservedObject var palettes: LiveList<Palette>

    var body: some View {
        NavigationView {
            List {
                ForEach(palettes.snapshot, id: \.self) { palette in
                    NavigationLink(
                        destination: DetailView(palette: palette)
                    ) {
                        HStack {
                            Color(palette.color)
                                .frame(width: 30, height: 30, alignment: .leading)
                            Text(palette.colorText)
                        }
                    }
                }.onDelete { indices in
                    let palettes = self.palettes.snapshot[indices]
                    self.dataStack.perform(
                        asynchronous: { transaction in

                            palettes.forEach(transaction.delete(_:))
                        },
                        completion: { _ in }
                    )
                }
            }
            .navigationBarTitle(Text("Master"))
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(
                    action: {

                        self.dataStack.perform(
                            asynchronous: { transaction in

                                let palette = transaction.create(Into<Palette>())
                                palette.setInitialValues(in: transaction)
                            },
                            completion: { _ in }
                        )
                }
                ) {
                    Image(systemName: "plus")
                }
            )
        }
    }
}

@available(iOS 13.0.0, *)
struct DetailView: View {
    @ObservedObject var palette: Palette

    var body: some View {
        HStack {
            EmptyView()
                .foregroundColor(.init(palette.color))
            Text(palette.colorText)
                .navigationBarTitle(Text("Detail"))
        }
    }
}

@available(iOS 13.0.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView(
            palettes: DataStackEnvironment.defaultValue.liveList(
                From<Palette>()
                    .orderBy(.ascending(\.hue))
            )
        )
    }
}

#endif
