//
//  HomeView.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 4/11/22.
//
import Foundation
import SwiftUI
import CryptoKit
import CoreLocation

struct HomeView : View {
    @StateObject private var viewModel = AVPlayerViewModel()
    @EnvironmentObject var viewRouter: ViewRouter
    var body: some View {
        NavigationView {
            ScrollView() {
//                Text("Exercise Assistant")
//                    .font(.largeTitle).foregroundColor(.primary)
//                    .padding(20)
                
                NavigationLink(destination:SelectWorkoutView()) {
                    Text("Select Workout")
                      .font(.headline)
                        .foregroundColor(oppositePrimary)
                        .padding()
                      .frame(width: 300, height: 50)
                      .background(Color.primary)
                      .cornerRadius(15.0)
                }.padding(.top)
            }.navigationTitle("Exercise Assistant")
        }.navigationViewStyle(.stack)
//            VStack {
//                Text(viewModel.pipStatus.rawValue)
//                    .bold()
//                    .frame(maxWidth: .infinity)
////                    .background(viewModel.pipStatus.color)
//                AVVideoPlayer(viewModel: viewModel)
//            }
//            .onAppear {
//                viewModel.media = Media(title: "testvideo",
//                url: "mp4")
//            }
//            .onDisappear {
//                viewModel.pause()
//            }
    }
}
