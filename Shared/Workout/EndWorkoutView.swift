//
//  EndWorkoutView.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 4/15/22.
//

import Foundation
import SwiftUI

struct EndWorkoutView : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter : ViewRouter
    @State var parentView : StartWorkoutView
    var body : some View {
        VStack {
            Text("Congratulations!").font(.title).bold()
            Text("You finished "+viewRouter.currentWorkout.name).font(.headline).multilineTextAlignment(.center)
            HStack {
                Button(action:{withAnimation{parentView.cleanup(true)}}) {
                    Text("Cycle")
                        .font(.subheadline)
                        .foregroundColor(oppositePrimary)
                        .padding()
                        .frame(width: 100, height: 40)
                        .background(Color.primary)
                        .cornerRadius(15.0)
                }
                Button(action:{presentationMode.wrappedValue.dismiss()}) {
                    Text("Done")
                        .font(.subheadline)
                        .foregroundColor(oppositePrimary)
                        .padding()
                        .frame(width: 100, height: 40)
                        .background(Color.primary)
                        .cornerRadius(15.0)
                }
            }
        }
        
    }
}
