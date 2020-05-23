//
//  SwiftUIView.swift
//  CoreStoreDemo
//
//  Created by John Rommel Estropia on 2019/10/02.
//  Copyright © 2019 John Rommel Estropia. All rights reserved.
//

#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
import Combine

import CoreStore


@available(iOS 13.0.0, *)
struct SwiftUIView: View {
    
    @Environment(\.dataStack)
    var dataStack: DataStack

    @ObservedObject
    var palettes: ListPublisher<Palette>

    var body: some View {
        NavigationView {
            List {
                ForEach(palettes.snapshot.sectionIDs, id: \.self) { (sectionID) in
                    Section(header: Text(sectionID)) {
                        ForEach(self.palettes.snapshot.items(inSectionWithID: sectionID), id: \.self) { palette in
                            NavigationLink(
                                destination: DetailView(palette: palette),
                                label: { ColorCell(palette: palette) }
                            )
                        }
                        .onDelete { itemIndices in
                            let objectIDsToDelete = self.palettes.snapshot.itemIDs(
                                inSectionWithID: sectionID,
                                atIndices: itemIndices
                            )
                            self.dataStack.perform(
                                asynchronous: { transaction in

                                    transaction.delete(objectIDs: objectIDsToDelete)
                                },
                                completion: { _ in }
                            )
                        }
                    }
                }
            }
            .navigationBarTitle(Text("SwiftUI (\(palettes.snapshot.numberOfItems) objects)"))
            .navigationBarItems(
                leading: EditButton(),
                trailing: HStack {
                    Button(
                        action: {

                            self.dataStack.perform(
                                asynchronous: { transaction in

                                    for palette in try transaction.fetchAll(From<Palette>()) {

                                        palette.hue = Palette.randomHue()
                                        palette.colorName = nil
                                    }
                                },
                                completion: { _ in }
                            )
                        },
                        label: {
                            Image(systemName: "goforward")
                        }
                    )
                    .frame(width: 30)
                    Button(
                        action: {

                            self.dataStack.perform(
                                asynchronous: { transaction in

                                    _ = transaction.create(Into<Palette>())
                                },
                                completion: { _ in }
                            )
                        },
                        label: {
                            Image(systemName: "plus")
                        }
                    )
                    .frame(width: 30)
                }
            )
            .alert(
                isPresented: $needsShowAlert,
                content: {
                    Alert(
                        title: Text("SwiftUI Binding Demo"),
                        message: Text("This demo shows how to bind to ListPublisher and to CoreStoreObject when using SwiftUI"),
                        dismissButton: .cancel(Text("OK"))
                    )
                }
            )
            .onAppear {
                
                self.needsShowAlert = true
            }
        }
    }

    @State
    private var needsShowAlert = false
}

@available(iOS 13.0.0, *)
struct ColorCell: View {

    @ObservedObject
    var palette: ObjectPublisher<Palette>

    var body: some View {
        HStack {
            Color(palette.color ?? UIColor.clear)
                .cornerRadius(5)
                .frame(width: 30, height: 30, alignment: .leading)
            Text(palette.colorText ?? "<Deleted>")
        }
    }
}

@available(iOS 13.0.0, *)
struct DetailView: View {

    @Environment(\.dataStack)
    var dataStack: DataStack

    @ObservedObject
    var palette: ObjectPublisher<Palette>

    @State var hue: Float = 0
    @State var saturation: Float = 0
    @State var brightness: Float = 0

    init(palette: ObjectPublisher<Palette>) {

        self.palette = palette
        self.hue = Float(palette.hue ?? 0)
        self.saturation = palette.saturation ?? 0
        self.brightness = palette.brightness ?? 0
    }

    var body: some View {
        ZStack {
            Color(palette.color ?? UIColor.clear)
                .cornerRadius(20)
                .padding(20)
            VStack {
                Text(palette.colorText ?? "<Deleted>")
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
            palettes: ColorsDemo.stack.publishList(
                From<Palette>()
                    .sectionBy(\.$colorName)
                    .orderBy(.ascending(\.$hue))
            )
        )
        .environment(\.dataStack, ColorsDemo.stack)
    }
}

#endif
