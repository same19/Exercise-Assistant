//
//  Workout.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 4/11/22.
//

import Foundation
import SwiftUI
import AVFoundation
let vibrateSound : UInt32 = 4095
let warningSound : UInt32 = 1254
let doubleVibrateSound : UInt32 = 1026
struct StartWorkoutView : View {
    @EnvironmentObject var viewRouter: ViewRouter
    @State var exerciseIndex: Int = 0
    @State var currentExercise: String = ""
    @State var paused = true
    @State var timeEnd : Date = Date()
    @State var pausedTimeLeft : Double = 0
    @State var breakTime = false
    @State var timer : Timer? = nil
    @State var checkTimeInterval = 0.01
    @State var timeString = ""
    @State var partOfTimeDone = 0.0
    @State var showingTime = true
    @State var currentBreakLength : Double = 0
    @State var player: AVAudioPlayer!
    @State var timerTranslation : CGSize = .zero
    let timeFormatter = DateFormatter()
    @State var isTransitioning = false
    @State var canNext : Bool = true
    @State var canPrevious : Bool = true
    @State var startWorkoutTime : Date = Date.now
    var body: some View {
        GeometryReader { geometry in
        VStack {
            ZStack {
                if (isExerciseBefore() && (abs(timerTranslation.width) > 0 || isTransitioning)) {
                    ZStack{
                        VStack {
                            Text(viewRouter.currentWorkout.exercises[exerciseIndex-1].name).bold().foregroundColor(paused ? .secondary : .primary).font(.title)
//                            if (showingTime) {
                                Text(generateTimeString(Double(viewRouter.currentWorkout.exercises[exerciseIndex-1].time))).font(.system(size: 80)).bold().foregroundColor(paused ? .secondary : .primary)
//                            }
                        }
//                        if paused {
//                            Image(systemName:"pause.fill").resizable().foregroundColor(.primary.opacity(0.5)).padding(65)
//                        }
                    }.frame(width: 300,height: 300)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color(uiColor:.systemBlue), lineWidth: 10)
                    )
                    .padding(.top,50).padding(.bottom,10)
                    .offset(x: self.timerTranslation.width - geometry.size.width, y: 0)
                }
                ZStack{
                    if (exerciseIndex < viewRouter.currentWorkout.exercises.count) {
                        ZStack {//main timer
                            Button(action:{playpause(geometry)}) {
                                VStack {
                                    Text(currentExercise).bold().foregroundColor(paused ? .secondary : .primary).font(.title)
                                    if (showingTime) {
                                        Text(timeString).font(.system(size: 80)).bold().foregroundColor(paused ? .secondary : .primary)
                                    }
                                }
                            }
        //                    if paused {
        //                        Button(action:{playpause()}) {
        //                            Image(systemName:"pause.fill").resizable().foregroundColor(.primary.opacity(0.5)).padding(100).padding(.top,20)
        //                        }.padding(65)
        //                    }
                        }
                        .frame(width: 300,height: 300)
                        .clipShape(Circle())
                        .overlay(
                            Circle().trim(from: 0.0, to: partOfTimeDone)
                                .rotation(.degrees(-90))
                                .stroke(Color(uiColor:.systemBlue), lineWidth: 10)
                        ).overlay(
                            Circle().trim(from: partOfTimeDone, to:1.0)
                                .rotation(.degrees(-90))
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 10)
                        ).onAppear() {
                            resetTimer(geometry)
                        }
                    } else {
                        EndWorkoutView(parentView:self)
                            .frame(width: 300,height: 300)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .rotation(.degrees(-90))
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 10)
                            ).onAppear() {
                                deleteActionTimer()
                            }
                    }
                }
                
                .padding(.top,50).padding(.bottom,10)
                .offset(x: self.timerTranslation.width, y: 0)
                .onAnimationCompleted(for: timerTranslation.width) {
                    isTransitioning = false
                }
                .gesture(
                    DragGesture()
                    .onChanged { value in
                        let w = geometry.size.width
                        let moved = value.translation.width
                        if (moved < 0) {
                            timerTranslation.width = max(moved, isExerciseAfter() ? -0.75*w : -0.33*w)
                        } else if (moved > 0) {
                            timerTranslation.width = min(moved, isExerciseBefore() ? 0.75*w : 0.33*w)
                        } else {
                            timerTranslation = .zero
                        }
                    }.onEnded { value in
                        if self.timerTranslation.width > geometry.size.width/3.0 && exerciseIndex > 0 { //previous exercise, not last
                            swipePreviousExercise(geometry,considerBreak:false)
                        } else if self.timerTranslation.width < geometry.size.width/(-3.0)  { //next exercise, not  last
                            swipeNextExercise(geometry,considerBreak:false)
                        } else {
                            isTransitioning = true
                            withAnimation {
                                self.timerTranslation = .zero
                            }
                        }
                    }
                )
                if (isExerciseAfterStrict()) {
                    ZStack{
                        VStack {
                            Text(viewRouter.currentWorkout.exercises[exerciseIndex+1].name).bold().foregroundColor(paused ? .secondary : .primary).font(.title)
//                            if (showingTime) {
                                Text(generateTimeString(Double(viewRouter.currentWorkout.exercises[exerciseIndex+1].time))).font(.system(size: 80)).bold().foregroundColor(paused ? .secondary : .primary)
//                            }
                        }
//                        if paused {
//                            Image(systemName:"pause.fill").resizable().foregroundColor(.primary.opacity(0.5)).padding(65)
//                        }
                    }.frame(width: 300,height: 300)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color(uiColor:.systemBlue), lineWidth: 10)
                    )
                    .padding(.top,50).padding(.bottom,10)
                    .offset(x: self.timerTranslation.width + geometry.size.width, y: 0)
                } else if (isExerciseAfter()) {
                    EndWorkoutView(parentView:self)
                        .frame(width: 300,height: 300)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .rotation(.degrees(-90))
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 10)
                        )
                        .padding(.top,50).padding(.bottom,10)
                        .offset(x: self.timerTranslation.width + geometry.size.width, y: 0)
                }
            }.padding(.top,10)
            HStack {
                VStack {
                    Button(action:{swipePreviousExercise(geometry)}) {
                        Image(systemName:"backward.fill").resizable().foregroundColor(.primary).padding(20).padding(.leading,-5).frame(width: 80, height: 80)
                            .background(Color.secondary)
                        .clipShape(Circle())
                        .shadow(radius: 10)
    //                    .padding(.bottom, 20).padding(.top,20)
                    }
                    Text(breakTime ? cutoffCharacters(20,getExerciseByIndex(exerciseIndex).name) : (cutoffCharacters(20,getExerciseByIndex(exerciseIndex-1) != .null ? getExerciseByIndex(exerciseIndex-1).name : " "))).font(.body)
                }.frame(width:150,height:150)
                VStack {
                    Button(action:{if isExerciseAfter(){resetTimer(geometry)}}) {
                        Image(systemName:"gobackward").resizable().foregroundColor(.primary).padding(20).padding(.top,-2).frame(width: 80, height: 80).background(canPrevious ? Color.secondary : Color.secondary.opacity(0.3))
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .padding(.bottom, 20)
                    }
                    Text("")
                }
                VStack {
                    Button(action:{if(isExerciseAfter()) {swipeNextExercise(geometry)}}) {
                        Image(systemName:"forward.fill").resizable().foregroundColor(.primary).padding(20).padding(.trailing,-5).frame(width: 80, height: 80).background(canNext ? Color.secondary : Color.secondary.opacity(0.3))
                            .clipShape(Circle())
                            .shadow(radius: 10)
    //                        .padding(.bottom, 20)
                    }
                    Text(!isExerciseAfterStrict() && isExerciseAfter() ? "End Workout" : cutoffCharacters(20,getExerciseByIndex(exerciseIndex+1) != .null ? getExerciseByIndex(exerciseIndex+1).name : " ")).font(.body)
                }.frame(width:150,height:150)
            }
            HStack {
                Button(action: {showingTime.toggle()}) {
                    Text(showingTime ? "Hide Time" : "Show Time")
                      .font(.headline)
                      .foregroundColor(.primary)
                        .padding()
                      .frame(width: 150, height: 50)
                      .background(Color.secondary)
                      .cornerRadius(15.0)
                }.padding([.leading,.trailing],10)
                Button(action: {
                    if (breakTime) {
                        timeEnd = timeEnd.addingTimeInterval(Double(viewRouter.currentWorkout.restTime))
                        currentBreakLength += Double(viewRouter.currentWorkout.restTime)
                    } else {
                        breakTime = true
                        resetTimer(geometry)
                    }
                }) {
                    Text(breakTime ? "Add Time" : "Stop and Rest")
                      .font(.headline)
                      .foregroundColor(.primary)
                      .padding()
                      .frame(width: 150, height: 50)
                      .background(Color.secondary)
                      .cornerRadius(15.0)
                }.padding([.leading,.trailing],10)
            }
            if (getCurrentExercise().details != "") {
                Text("Description: "+getCurrentExercise().details).font(.body)
            }
        }.navigationTitle(isExerciseAfter() ? currentExercise : "Workout Complete")
//            .navigationBarTitleDisplayMode(.large)
        .onAppear() {
            resetTimer(geometry)
            paused.toggle()
            startWorkoutTime = Date.now
        }.onDisappear() {
            cleanup(true)
            let _ = WorkoutAPI.logWorkout(viewRouter.currentWorkout,timeMinutes:Int(Date.now.timeIntervalSince(startWorkoutTime)/60))
        }
        }
    }
    func isExerciseBefore()->Bool {
        return exerciseIndex>0
    }
    func isExerciseAfterStrict()->Bool {
        return exerciseIndex < viewRouter.currentWorkout.exercises.count-1
    }
    func isExerciseAfter()->Bool {
        return exerciseIndex < viewRouter.currentWorkout.exercises.count
    }
    func swipeNextExercise(_ geometry:GeometryProxy, considerBreak : Bool = true) {
        if (!isExerciseAfter()) {
            withAnimation {
                self.timerTranslation.width = 0
            }
            return
        }
        if (isExerciseAfterStrict()) { //normal
            if considerBreak {
                if breakTime {
                    exerciseIndex += 1
                }
                breakTime.toggle()
            } else {
                breakTime = false
                exerciseIndex += 1
            }
            resetTimer(geometry)
        } else { //finished workout
            breakTime = false
            exerciseIndex += 1
        }
        isTransitioning = true
        self.timerTranslation.width += geometry.size.width
        withAnimation {
            self.timerTranslation = .zero
        }
    }
    func swipePreviousExercise(_ geometry: GeometryProxy, considerBreak : Bool = true) {
        if (!isExerciseBefore() && !breakTime) {
            withAnimation {
                self.timerTranslation.width = 0
            }
            return
        }
        if breakTime {
            breakTime = false
        } else {
            exerciseIndex -= 1
        }
        resetTimer(geometry)
        isTransitioning = true
        self.timerTranslation.width -= geometry.size.width
        withAnimation {
            self.timerTranslation = .zero
        }
    }
    func getTime(_ interval : Double)->Date{
//        print("Mins: "+String(timeEnd.timeIntervalSinceNow/60))
        return Date(timeIntervalSince1970: (interval-17*3600))
    }
    func generateTimeString(_ interval : Double)->String {
        let timeFormatter = DateFormatter()
        if (interval<60-checkTimeInterval) {
            timeFormatter.dateFormat = "s"
        } else if interval < 3600 {
            timeFormatter.dateFormat = "m:ss"
        } else {
            timeFormatter.dateFormat = "H:mm:ss"
        }
        let stringDate = timeFormatter.string(from: getTime(interval))
        return stringDate
    }
    func getTimeString() {
        let intervalToNow = timeEnd.timeIntervalSinceNow
        timeString = generateTimeString(intervalToNow)
    }
    func playAudioAsset(_ assetName : String) {
        guard let dataAudio = NSDataAsset(name: assetName) else {
            print("fail 2")
            return
        }
        
        do {
            // Configure and activate the AVAudioSession
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback
            )

            try AVAudioSession.sharedInstance().setActive(true)

            // Play a sound
            self.player = try AVAudioPlayer(data:dataAudio.data)

            self.player.play()
        }
        catch {
            print("fail error")
            // Handle error
        }
    }
    func getExerciseByIndex(_ ind : Int)->WorkoutAPI.Exercise {
        if ind >= 0 && ind < viewRouter.currentWorkout.exercises.count {
            return viewRouter.currentWorkout.exercises[ind]
        } else {
            return .null
        }
    }
    func getCurrentExercise() -> WorkoutAPI.Exercise {
        if exerciseIndex >= 0 && exerciseIndex < viewRouter.currentWorkout.exercises.count {
            return viewRouter.currentWorkout.exercises[exerciseIndex]
        } else {
            return .null
        }
    }
    func resetTimer(_ geometry : GeometryProxy) {
        if !breakTime {
            currentExercise = getCurrentExercise().name
            timeEnd = Date(timeIntervalSinceNow:Double(getCurrentExercise().time))
        } else {
            currentExercise = "Break Time"
            currentBreakLength = Double(viewRouter.currentWorkout.restTime)
            timeEnd = Date(timeIntervalSinceNow:Double(viewRouter.currentWorkout.restTime))
        }
        resetActionTimer(geometry)
        if (!paused) {
            DispatchQueue.main.asyncAfter(deadline: .now() + checkTimeInterval) {
                getTimeString()
            }
        } else {
            getTimeString()
        }
        setProgressBar()
    }
    func setProgressBar() {
        pausedTimeLeft = timeEnd.timeIntervalSinceNow
        partOfTimeDone = breakTime ? pausedTimeLeft/currentBreakLength: pausedTimeLeft/Double(getCurrentExercise().time)
    }
    func deleteActionTimer() {
        if (timer != nil) {
            timer!.invalidate()
            timer = nil
        }
    }
    func resetActionTimer(_ geometry : GeometryProxy) {
        deleteActionTimer()
        timer = Timer.scheduledTimer(withTimeInterval: checkTimeInterval, repeats: true) { _ in
            timerUpdate(geometry)
        }
    }
    func timerUpdate(_ geometry : GeometryProxy) {
        if (!paused) {
            setProgressBar()
            if (timeEnd.timeIntervalSinceNow <= 0) {
                swipeNextExercise(geometry)
            } else {
                if (6-timeEnd.timeIntervalSinceNow <= checkTimeInterval && 6-timeEnd.timeIntervalSinceNow > 0) {
                    playAudioAsset("Low C Note")
                }
                if (timeEnd.timeIntervalSinceNow <= checkTimeInterval && timeEnd.timeIntervalSinceNow > 0) {
                    playAudioAsset("High C Note")
                }
                getTimeString()
            }
        }
    }
    func playpause(_ geometry : GeometryProxy) {
//        AudioServicesPlaySystemSound(vibrateSound)
        paused = !paused
        if (paused) {
            deleteActionTimer()
            pausedTimeLeft = timeEnd.timeIntervalSinceNow
        } else {
            resetActionTimer(geometry)
            timeEnd = Date(timeIntervalSinceNow: pausedTimeLeft)
        }
    }
//    func backward(_ geometry : GeometryProxy) {
//        if (breakTime) {
//            //exerciseIndex -= 1
//            breakTime = false
//            resetTimer(geometry)
//        } else if (exerciseIndex != 0) {
//            exerciseIndex -= 1
//            resetTimer(geometry)
//        }
//    }
//    func forward() {
//        if (exerciseIndex < viewRouter.currentWorkout.exercises.count-1) {
//            if (breakTime) {
//                breakTime = false
//                exerciseIndex += 1
//            } else {
//                breakTime = true
//            }
//            resetTimer(geometry)
//        } else {
//            finishedWorkout()
//        }
//    }
//    func finishedWorkout() {
//        cleanup()
//        viewRouter.setPage(.home)
//    }
    func cleanup(_ reset : Bool = false) {
        if (timer != nil) {
            timer!.invalidate()
            timer = nil
        }
        if (reset) {
            exerciseIndex = 0
        }
        currentExercise = getCurrentExercise().name
        partOfTimeDone = 0
        if (!reset) {
            paused = true
        } else {
            paused = false
        }
        breakTime = false
    }
    
}
func cutoffCharacters(_ i : Int, _ s : String, _ b : Bool = false)->String {
    var s1 = s
    if (s.count < i) {
        if (b) {
            for _ in (s.count ... i) {
                s1 += " "
            }
        }
    } else if (s.count > i) {
        if (i>3) {
            s1 = String(s1.dropLast(s.count-i)).dropLast(3) + "..."
        } else {
            s1 = String(s1.dropLast(s.count-i))
        }
    } else if (i>3 && s.count == i) {
        s1 = String(s1.dropLast(3))+"..."
    }
    return s1
    
}
