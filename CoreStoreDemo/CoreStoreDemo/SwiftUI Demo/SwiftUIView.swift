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

@available(iOS 13.0.0, *)
struct SwiftUIView: View {
    
    @Environment(\.dataStack)
    var dataStack: DataStack

    @ObservedObject
    var palettes: LiveList<Palette>
    
    @State
    private var needsShowAlert = false

    var body: some View {
        NavigationView {
            List {
                ForEach(palettes.snapshot, id: \.self) { palette in
                    NavigationLink(
                        destination: DetailView(palette: palette),
                        label: {
                            HStack {
                                Color(palette.color)
                                    .frame(width: 30, height: 30, alignment: .leading)
                                Text(palette.colorText)
                            }
                        }
                    )
                }
                .onDelete { indices in
                    let palettes = self.palettes.snapshot[indices]
                    self.dataStack.perform(
                        asynchronous: { transaction in

                            transaction.delete(palettes)
                        },
                        completion: { _ in }
                    )
                }
            }
            .navigationBarTitle(Text("SwiftUI"))
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
                    },
                    label: {
                        Image(systemName: "plus")
                    }
                )
            )
            .alert(
                isPresented: $needsShowAlert,
                content: {
                    Alert(
                        title: Text("SwiftUI Binding Demo"),
                        message: Text("This demo shows how to bind to LiveList and to CoreStoreObject when using SwiftUI"),
                        dismissButton: .cancel(Text("OK"))
                    )
                }
            )
            .onAppear {
                
                self.needsShowAlert = true
            }
        }
        .colorScheme(.dark)
    }
}

@available(iOS 13.0.0, *)
struct DetailView: View {
    
    @ObservedObject var palette: Palette

    var body: some View {
        ZStack {
            Color(palette.color)
                .cornerRadius(20)
                .padding(20)
            Text(palette.colorText)
                .navigationBarTitle(Text("Color"))
        }
    }
}

@available(iOS 13.0.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        SwiftUIView(
            palettes: ColorsDemo.stack.liveList(
                From<Palette>()
                    .sectionBy(\.colorName)
                    .orderBy(.ascending(\.hue))
            )
        )
        .environment(\.dataStack, ColorsDemo.stack)
    }
}

#endif
