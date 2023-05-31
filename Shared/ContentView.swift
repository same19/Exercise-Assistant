//
//  ContentView.swift
//  Shared
//
//  Created by Sam Engel on 4/11/22.
//

import SwiftUI

enum Page {
    case home
    case selectWorkout
    case createWorkout
    case createExercise
    case workout
}
class ViewRouter: ObservableObject {
    
    @Published var page: [Page]
    @Published var currentExercise: WorkoutAPI.Exercise
    @Published var currentWorkout: WorkoutAPI.Workout
    @Published var showingPopup: Bool
    //@Published var locationManager: LocationManager
    init() {
        self.page = [.home]
        self.currentWorkout = .null
        self.currentExercise = .null
        self.showingPopup = false
    }
    func currentPage()->Page {
        return page[page.count-1]
    }
    func setPage(_ p: Page) {
        withAnimation {
            page.append(p)
        }
    }
    func backPage() {
        page.removeLast()
    }
    func showPopup() {
        showingPopup = true
    }
    func hidePopup() {
        showingPopup = false
    }
//    init(_ locationManager : LocationManager, _ account : LoginAPI.Account = .null, _ page : Page = .loginPage) {
//        self.locationManager = locationManager
//        currentAccount = account
//        currentPage = page    }
}

var oppositePrimary  = Color(uiColor: UIColor.systemBackground)
struct ContentView: View {
    @StateObject var viewRouter: ViewRouter = ViewRouter()
    @State private var selection = 2
    var body: some View {
            Group {
                TabView(selection:$selection) {
                    SelectWorkoutView().tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Explore")
                    }.tag(0)
                    StreakView().tabItem {
                        Image(systemName: "calendar")
                        Text("Streak")
                    }.tag(1)
                    SelectWorkoutView().tabItem {
                        Image(systemName: "play")
                        Text("Workout")
                    }.tag(2)
//                    SelectWorkoutView().tabItem {
//                        Image(systemName: "seal")
//                        Text("Progress")
//                    }.tag(3)
                    ProfileView(admin:true).tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }.tag(3)
                    
                }.environmentObject(viewRouter)
            }.preferredColorScheme(.none)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StartWorkoutView().environmentObject(ViewRouter())
    }
}

