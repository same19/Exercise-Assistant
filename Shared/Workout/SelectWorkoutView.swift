//
//  SelectWorkout.swift
//  Workout Assistant
//
//  Created by Sam Engel on 4/11/22.
//

import Foundation
import SwiftUI
struct SelectWorkoutView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    @State var allWorkouts = WorkoutAPI.getAllWorkouts()
    @State private var selectedWorkout: Int = -1
    @State private var editMode = EditMode.inactive
    @State var searchText = ""
    @State var showingCreateWorkout = false
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: CreateWorkoutView(), isActive: $showingCreateWorkout) {  }
                List(allWorkouts.filter{$0.name.contains(searchText) || searchText == ""}) { ex in
        //                Text(selectedWorkout = ex.id ? String(1+selectedWorkouts.firstIndex(of:ex.id)!) : "").frame(width:50,height:50)
                    Button(action:{
                        selectedWorkout = selectedWorkout == ex.id ? -1 : ex.id
                        setSelectedWorkout()
                    }) { VStack(alignment: .leading) {
                        Text(ex.name).bold().foregroundColor(.primary)
                        Text("Break Length: "+writeSecondsAsMinutes(seconds:ex.restTime)).foregroundColor(.primary)
                        Text(getExercisesString(ex)).lineLimit(1).foregroundColor(.secondary)
                        Text(ex.details).lineLimit(1).foregroundColor(.secondary)
                        
                    }}.listRowBackground(selectedWorkout == ex.id ? .secondary : oppositePrimary)
                    .swipeActions(edge: .leading, content: {
                        Button(action:{selectedWorkout = ex.id; setSelectedWorkout(); showingCreateWorkout = true})
                        {
                            Image(systemName:"pencil")
                        }.tint(.blue)
                    })
                    .swipeActions(edge: .trailing, content: {
                        Button(role:.destructive, action: {
                            print(WorkoutAPI.removeWorkout(ex.id)); refreshList()
                        }, label:
                                {
                            Image(systemName:"trash")
                        })
                        .tint(.red)

                    })
                        
                }
    //        .searchable(text: $searchText)
                .listStyle(PlainListStyle())
                .environment(\.editMode, $editMode)
                .onAppear() {
                    print("OnAppear")
                    refreshList()
                    getSelectedWorkout()
                }
                NavigationLink(destination:{
                    StartWorkoutView()
                }) {
                        Text("Start Workout")
                          .font(.headline)
                            .foregroundColor(oppositePrimary)
                            .padding()
                          .frame(width: 300, height: 50)
                          .background(selectedWorkout == -1 ? Color.secondary : Color.primary)
                          .cornerRadius(15.0)
                .padding(.top)
                }.disabled(selectedWorkout == -1)
    //            NavigationLink(destination:{CreateWorkoutView()}) {
                Button(action:{viewRouter.currentWorkout = .null;showingCreateWorkout = true}) {
                    Text("New Workout")
                        .font(.headline)
                        .foregroundColor(oppositePrimary)
                        .padding()
                        .frame(width: 200, height: 40)
                        .background(Color.primary)
                        .cornerRadius(15.0)
                }
                .padding()
                Spacer()
            }.navigationTitle("Select Workout").onAppear() {
                refreshList()
            }.onDisappear() {
                let _ = WorkoutAPI.saveWorkouts(allWorkouts)
            }
        }.navigationViewStyle(.stack)
    }
    func getSelectedWorkout() {
        selectedWorkout = viewRouter.currentWorkout.id
    }
    func setSelectedWorkout() {
        viewRouter.currentWorkout = WorkoutAPI.getWorkoutById(id:selectedWorkout)
    }
    func refreshList() {
        allWorkouts = WorkoutAPI.getAllWorkouts()
    }
    func getExercisesString(_ ex : WorkoutAPI.Workout)->String {
        var s = ""
        var index = 0
        for i in ex.exercises {
            if (index != 0) {
                s += " -> "
            }
            s += i.name
            index += 1
        }
        return s
    }
}
