//
//  CreateExerciseView.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 4/12/22.
//

import Foundation
import SwiftUI

struct CreateExerciseView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var name = ""
    @State private var mins = ""
    @State private var sec = ""
    @State private var details = ""
    @State var saveAllowed = false
    var body: some View {
        NavigationView {
        ScrollView{
//            Text("Customize Exercise")
//                .font(.largeTitle).foregroundColor(.primary)
//                .padding(20)
            VStack(alignment: .leading, spacing: 15) {
                TextField("Name", text: self.$name)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.primary.opacity(0.2))
                    .cornerRadius(20.0)
                HStack {
                    TextField("Min", text: self.$mins).foregroundColor(.primary)
                        .padding()
                        .background(Color.primary.opacity(0.2))
                        .cornerRadius(20.0)
                        .keyboardType(.decimalPad)
                    Text(":")
                    TextField("Sec", text: self.$sec).foregroundColor(.primary)
                        .padding()
                        .background(Color.primary.opacity(0.2))
                        .cornerRadius(20.0)
                        .keyboardType(.decimalPad)
                }
                TextEditor(text: self.$details)
                    .multilineTextAlignment(.leading).foregroundColor(.primary)
                    .frame(minHeight:80)
                    .padding()
                    .background(Color.primary.opacity(0.2))
                    .cornerRadius(20.0)
            }
            .padding(25)
            HStack {
                Button(action: {saveExercise();viewRouter.hidePopup()}) {
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
                Button(action: {viewRouter.hidePopup()}) {
                    Text("Cancel")
                      .font(.headline)
                        .foregroundColor(oppositePrimary)
                        .padding()
                      .frame(width: 150, height: 50)
                      .background(Color.primary)
                      .cornerRadius(15.0)
                }.padding(.top)
            }
        }.navigationTitle("Customize Exercise").navigationBarBackButtonHidden(true).navigationBarItems(
            leading:Button(action: {withAnimation {viewRouter.hidePopup()}}) { Text("Cancel") },
            trailing: Button(action: {saveExercise();withAnimation {viewRouter.hidePopup()}}) { Text("Save") }.disabled(!saveAllowed))
        
        .onAppear() {
            UITextView.appearance().backgroundColor = .clear
            name = viewRouter.currentExercise.name
            mins = String(Int(viewRouter.currentExercise.time/60))
            if mins == "0" {
                mins = ""
            }
            sec = String(viewRouter.currentExercise.time%60)
            if sec == "0" {
                sec = ""
            }
            details = viewRouter.currentExercise.details
        }.onChange(of:name) {newValue in
            setSaveAllowed()
        }.onChange(of:mins) {newValue in
            setSaveAllowed()
        }.onChange(of:sec) {newValue in
            setSaveAllowed()
        }
        }
    }
    func saveExercise() {
        viewRouter.currentExercise.name = name
        viewRouter.currentExercise.time = (Int(mins) ?? 0)*60 + (Int(sec) ?? 0)!
        viewRouter.currentExercise.details = details
        viewRouter.currentExercise = WorkoutAPI.getExerciseById(id:WorkoutAPI.writeExercise(viewRouter.currentExercise))
    }
    func setSaveAllowed() {
        saveAllowed = name != "" && (Int(mins) ?? 0)*60 + (Int(sec) ?? 0)! > 0
    }
}
