//
//  CreateWorkoutView.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 4/11/22.
//

import Foundation
import SwiftUI
//class ObservableFunction : ObservableObject {
//    @Published var function : () -> ()
//    init(_ function : @escaping () -> ()) {
//        self.function = function
//    }
//}
//struct ActionView : View {
//    var function : ObservableFunction
//    var body : some View {
//        EmptyView()
//    }
//    init(_ function : @escaping ()->()) {
//        self.function = ObservableFunction(function)
//        self.function.function()
//    }
//}

struct CreateWorkoutView : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var selectedExercises: Array<Int> = []
    @State private var currentExerciseEditing = false
    @State var name = ""
    @State var breakLength = ""
    @State var details = ""
    @State var saveAllowed = false
    @State var showingSelectExercisesView = false
    @State var editMode : EditMode = .active
    var body: some View {
        ZStack {
            VStack{
                NavigationLink(destination:SelectExercisesView(), isActive: $showingSelectExercisesView) {  }
//                List of exercises in workout, and can add
                ZStack {
                List {
                    ForEach(viewRouter.currentWorkout.exercises) { ex in
                        Button(action:{
                            editMode = .active
                        }) { VStack(alignment: .leading) {
                            Text(ex.name).bold().foregroundColor(.primary)
                            Text(writeSecondsAsMinutes(seconds:ex.time)).foregroundColor(.primary)
                            Text(ex.details+"\n").lineLimit(2).foregroundColor(.secondary)
                        }}
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                    .listRowBackground(oppositePrimary)
                }.listStyle(PlainListStyle())
                if (viewRouter.currentWorkout.exercises.count == 0) {
                    Text("No exercises in workout")
                }
                }
//                    .environment(\.editMode, $editMode)
                VStack{
                    TextField("Name", text: self.$name)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.primary.opacity(0.2))
                        .cornerRadius(20.0)
                    TextField("Break Length (seconds)", text: self.$breakLength).foregroundColor(.primary)
                        .padding()
                        .background(Color.primary.opacity(0.2))
                        .cornerRadius(20.0)
                        .keyboardType(.decimalPad)
                    TextEditor(text: self.$details)
                        .multilineTextAlignment(.leading).foregroundColor(.primary)
                        .frame(minHeight:40)
                        .padding()
                        .background(Color.primary.opacity(0.2))
                        .cornerRadius(20.0)
                }.padding([.leading,.trailing], 40)
                
                HStack {
                    Button(action: {setCurrentWorkout();writeCurrentWorkout();navigateBack()}) {
                        Text("Save")
                          .font(.headline)
                            .foregroundColor(oppositePrimary)
                            .padding()
                          .frame(width: 150, height: 50)
                          .background(!saveAllowed ? Color.secondary : Color.primary)
                          .cornerRadius(15.0)
                    }
                    .padding(.top)
                    .disabled(!saveAllowed)
                    Button(action: {navigateBack()}) {
                        Text("Cancel")
                          .font(.headline)
                            .foregroundColor(oppositePrimary)
                            .padding()
                          .frame(width: 150, height: 50)
                          .background(Color.primary)
                          .cornerRadius(15.0)
                    }.padding(.top)
                }.onChange(of:name) {newValue in
                    setSaveAllowed()
                }.onChange(of:selectedExercises) {newValue in
                    setSaveAllowed()
                }
            }
        }.navigationTitle("Design Workout").navigationBarItems(leading: EditButton(), trailing: AnyView(Button(action: onAdd) { Image(systemName: "plus") }))
//            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        .onAppear() {
            UITextView.appearance().backgroundColor = .clear
            getCurrentWorkout()
        }
    
        
        
        
    }
    func onAdd() {
        setCurrentWorkout()
        showingSelectExercisesView = true
    }
    func onDelete(offsets: IndexSet) {
        viewRouter.currentWorkout.exercises.remove(atOffsets: offsets)
    }
    func onMove(source: IndexSet, destination: Int) {
        viewRouter.currentWorkout.exercises.move(fromOffsets: source, toOffset: destination)
    }
    func navigateBack() {
        self.presentationMode.wrappedValue.dismiss()
    }
    func setSaveAllowed() {
        saveAllowed = name != "" && selectedExercises.count > 0
    }
    func getCurrentWorkout() {
        print(viewRouter.currentWorkout.exercises)
        selectedExercises = []
        for i in viewRouter.currentWorkout.exercises {
            selectedExercises.append(i.id)
        }
        name = viewRouter.currentWorkout.name
        breakLength = String(viewRouter.currentWorkout.restTime)
        if (breakLength == "0") {
            breakLength = ""
        }
        details = viewRouter.currentWorkout.details
    }
    func setCurrentWorkout() {
//        viewRouter.currentWorkout = WorkoutAPI.Workout(id:viewRouter.currentWorkout.id,name:name,restTime:Int(breakLength) ?? 15,details:details)
//        for i in selectedExercises {
//            viewRouter.currentWorkout.exercises.append(WorkoutAPI.getExerciseById(id:i))
//        }
        viewRouter.currentWorkout.name = name
        viewRouter.currentWorkout.restTime = Int(breakLength) ?? 15
        viewRouter.currentWorkout.details = details
    }
    func writeCurrentWorkout() {
        print(WorkoutAPI.writeWorkout(&viewRouter.currentWorkout))
    }
}

