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
                ForEach(palettes.snapshot.sectionIdentifiers, id: \.self) { (sectionID: String) in
                    Section(header: Text(sectionID)) {
                        ForEach(self.palettes.snapshot[section: sectionID], id: \.self) { palette in
                            NavigationLink(
                                destination: DetailView(palette: palette),
                                label: {
                                    HStack {
                                        Color(palette.color)
                                            .cornerRadius(5)
                                            .frame(width: 30, height: 30, alignment: .leading)
                                        Text(palette.colorText)
                                    }
                                }
                            )
                        }
                        .onDelete { itemIndices in
                            let objectsToDelete = self.palettes.snapshot[section: sectionID, itemIndices: itemIndices]
                            self.dataStack.perform(
                                asynchronous: { transaction in

                                    transaction.delete(objectsToDelete)
                                },
                                completion: { _ in }
                            )
                        }
                    }
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

    @Environment(\.dataStack)
    var dataStack: DataStack
    
    @ObservedObject var palette: Palette

    @State var hue: Float = 0
    @State var saturation: Float = 0
    @State var brightness: Float = 0

    init(palette: Palette) {

        self.palette = palette
        self.hue = Float(palette.hue.value)
        self.saturation = palette.saturation.value
        self.brightness = palette.brightness.value
    }

    var body: some View {
        ZStack {
            Color(palette.color)
                .cornerRadius(20)
                .padding(20)
            VStack {
                Text(palette.colorText)
                    .navigationBarTitle(Text("Color"))
                Slider(value: $hue, in: 0.0 ... 359.0 as ClosedRange<Float>)
                Slider(value: $saturation, in: 0.0 ... 1.0 as ClosedRange<Float>)
                Slider(value: $brightness, in: 0.0 ... 0.1 as ClosedRange<Float>)
            }
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
