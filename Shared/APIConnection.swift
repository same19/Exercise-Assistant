//
//  APIConnection.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 4/11/22.
//

import Foundation
import SwiftUI
import CryptoKit
import FirebaseDatabase

func writeTextFileLine(filename : String, text: String, ext: String = ".txt") -> Bool {
    var arr = readTextFile(filename: filename, ext:ext)
    arr.append(Substring(text))
    let s = arr.joined(separator: "\n")
    return writeTextFile(filename: filename, text:s, ext:ext)
}
func writeTextFile(filename : String, text: String, ext: String = ".txt")->Bool {
    let file = getDocumentsDirectory().appendingPathComponent(filename+ext)
        
    do {
        try text.write(to: file, atomically: true, encoding: String.Encoding.utf8)
//        print(readTextFile(filename:filename, ext:ext))
        return true
    } catch {
        return false
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
    }
}
func readTextFileRaw(filename : String, ext: String = ".txt")->String {
    let file = getDocumentsDirectory().appendingPathComponent(filename+ext)
        
    do {
        let contents = try String(contentsOf:file)
        return contents
    } catch {
        return ""
    }
}
func readTextFile(filename : String, ext: String = ".txt")->[Substring] {
    let contents = readTextFileRaw(filename:filename, ext:ext)
    let lines = contents.split(separator:"\n")
    return lines
}
func getLineKey(_ line : String)->String {
    let range: Range<String.Index> = line.range(of: "=")!
    if range.isEmpty {
        return ""
    }
    let index: Int = line.distance(from: line.startIndex, to: range.lowerBound)
    return String(line.dropLast(line.count-index))
}
func getLineValue(_ line : String)->String {
    let range: Range<String.Index> = line.range(of: "=")!
    if range.isEmpty {
        return ""
    }
    let index: Int = line.distance(from: line.startIndex, to: range.lowerBound)
    return String(line.dropFirst(index+1))
}
func getStoredVariable(_ key : String, filename : String = "storedVars")->[[String]] {
    var r : [[String]] = []
    let lines = readTextFile(filename:filename)
    for l in lines {
        let l1 = String(l)
        if getLineKey(l1)==key {
            r.append(getLineValue(l1).components(separatedBy: ","))
        }
    }
    return r
}
func writeStoredVariable(_ key : String, _ value : String, filename : String = "storedVars")->Bool { //<name>=<value>
    
    if (getStoredVariable(key,filename:filename).isEmpty) {
        return writeTextFileLine(filename:filename,text:"\(key)=\(value)")
    } else {
        var lines = readTextFile(filename:filename)
        var doneBool = false
        var i = 0
        while i < lines.count {
            if getLineKey(String(lines[i]))==key && doneBool == false {
                lines[i] = Substring("\(key)=\(value)")
                doneBool = true
            } else if getLineKey(String(lines[i]))==key {
                lines.remove(at:i)
                i-=1
            }
            i+=1
        }
        return writeTextFile(filename:filename,text:lines.joined(separator:"\n"))
        
    }
    
}
func dataFromAPIData<T : APIData>(_ data : [T]) -> [[String : Any]] {
    if data is [WorkoutAPI.Exercise] {
        var list : [[String : Any]] = []
        for e in data {
            let d : WorkoutAPI.Exercise = e as! WorkoutAPI.Exercise
            list.append([
                "id" : d.id,
                "name" : d.name,
                "time" : d.time,
                "recommendedReps" : d.recommendedReps,
                "details" : d.details
            ])
        }
        return list
    } else if data is [WorkoutAPI.Workout] {
        var list : [[String : Any]] = []
        for e in data {
            let d : WorkoutAPI.Workout = e as! WorkoutAPI.Workout
            var exercisesList : [Int] = []
            for i in d.exercises {
                exercisesList.append(i.id)
            }
            list.append([
                "id":d.id,
                "name":d.name,
                "exercises":exercisesList,
                "restTime":d.restTime,
                "cycles":d.cycles,
                "details":d.details
            ])
        }
        return list
    } else {
        return []
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}
func setJSONFile<T : APIData>(_ file_name : String, _ data : [T]) -> Bool {
    //print("setting JSON File")
    let array = dataFromAPIData(data) as NSArray
    //print(array)
    var jsonData: NSData!
    // serialize json data
    do
    {
        jsonData = try JSONSerialization.data(withJSONObject: array) as NSData
//        let jsonString = String(data: jsonData as Data, encoding: String.Encoding.utf8)
//        print(jsonString!)
    }
    catch let error as NSError
    {
        print("Array to JSON conversion failed: \(error.localizedDescription)")
        return false
    }

    // overwrite the contents of the original file.
    do
    {
        //print("in the do")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        //print(paths)
        let documentsDirectory = paths[0]
        let path = "\(documentsDirectory)/\(file_name).json"
        //Bundle.main.path(forResource: file_name, ofType: "json")
//        print(path)
//        print("about to write!")
        try jsonData!.write(toFile:path)
        print("JSON data was written to the file successfully!")
        return true
    }
    catch let error
    {
        print("Couldn't write to file: \(error.localizedDescription)")
        return false
    }
}
func getFromJSONFile<T : Decodable>(_ file_name : String)->[T] {
    if let path = Bundle.main.path(forResource: file_name, ofType: "json") {
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let list = try! JSONDecoder().decode([T].self, from: data)
        //print(list)
        return list
    } else {
        print("Error accessing file '"+file_name+"'")
        return [T]()
    }
}
func getFromStoredJSONFile<T : Decodable>(_ file_name : String)->[T]  {
    let url = getDocumentsDirectory().appendingPathComponent(file_name+".json")
    if let data = try? Data(contentsOf: url), let list = try? JSONDecoder().decode([T].self, from: data) {
        return list
    } else {
        return getFromJSONFile(file_name)
    }
}
func getValuePart(_ value : String, _ index : Int)->String {
    let v = value.split(separator:",")
    return String(v[index])
}
func getKeyFromDate(_ date : Date = Date.now) -> String {
    return date.format(dateFormat:"dd/MM/yyyy")
}
func getDateFromKey(_ key : String) -> Date? {
    return key.date(dateFormat:"dd/MM/yyyy")
}
protocol API {
    
}
protocol APIData : Codable, Identifiable, Hashable {
    var id: Int {get}
    static var null : Self {get}
    
}
extension APIData {
    func isValid() -> Bool {
        return id >= 0
    }
}
func writeSecondsAsMinutes(seconds : Int)->String {
    let formatter = DateComponentsFormatter()
    var s : String
    if (seconds >= 60) {
        s = formatter.string(from: TimeInterval(seconds))!
    } else {
        s = String(formatter.string(from: TimeInterval(seconds+60))!.dropFirst(2))
        s = "0:"+s
    }
    return s
}


class WorkoutAPI : API {
    static var ref: DatabaseReference! = Database.database().reference()
    static var userID : String? = .none
    struct Exercise : APIData {
        var id : Int
        var name : String
        var time : Int
        var recommendedReps : Int = 1
        var details : String
        static let null : Exercise = Exercise(id: -1, name: "", time: 0, recommendedReps: 0, details: "")
    }
    struct Workout : APIData {
        var id : Int
        var name : String
        var exercises : [Exercise] = []
        var restTime : Int
        var cycles : Int = 1
        var details : String
        
        static let null : Workout = Workout(id: -1, name: "", restTime: 0, cycles: 0, details: "")
    }
    struct WorkoutTemplate : APIData {
        
        var id : Int
        var name : String
        var exercises : [Int] = []
        var restTime : Int
        var cycles : Int = 1
        var details : String
        
        static let null : WorkoutTemplate = WorkoutTemplate(id: -1, name: "", restTime: 0, cycles: 0, details: "")
    }
    static func getAllExercises() -> [Exercise] {
        let list1 : [Exercise] = getFromStoredJSONFile("exercises")
        return list1
        
    }
    static func maxExerciseId()->Int {
        let exercises : [Exercise] = getAllExercises()
        var max = -1
        for i in exercises {
            if i.id > max {
                max = i.id
            }
        }
        return max
    }
    //change the following to sync to the firebase database
    private static func saveExercises(_ exs : [Exercise])->Bool {
        return setJSONFile("exercises", exs)
    }
    static func getExerciseById(id : Int)->Exercise {
        let exercises : [Exercise] = getAllExercises()
        for i in exercises {
            if i.id == id {
                return i
            }
        }
        return .null
    }
    static func generateNewExerciseId()->Int {
        let g = getStoredVariable("maxexerciseid")
        if (g.isEmpty) {
            let i = maxExerciseId()+1
            let _ = writeStoredVariable("maxexerciseid", String(i))
            return i
        } else {
            let s = Int(g[0][0]) ?? -1
            if (s == -1) {
                let i = maxExerciseId()+1
                let _ = writeStoredVariable("maxexerciseid", String(i))
                return i
            } else {
                let _ = writeStoredVariable("maxexerciseid", String(s+1))
                return s+1
            }
        }
    }
    static func removeExercise(_ id: Int)->Bool {
        var exerciseList = getAllExercises()
        var index = 0
        for i in exerciseList {
            if (i.id == id) {
                exerciseList.remove(at:index)
                index-=1
            }
            index += 1
        }
        return saveExercises(exerciseList)
    }
    static func writeExercise(_ ex : inout Exercise) -> Int {
        var exerciseList = getAllExercises()
        if ex.id >= 0 {
            var index = 0
            for i in exerciseList {
                if i.id == ex.id {
                    exerciseList[index] = ex
                    if (saveExercises(exerciseList)) {
                        return ex.id
                    } else {
                        return -1
                    }
                }
                index+=1
            }
        }
        let ex2 = Exercise(id:generateNewExerciseId(),name:ex.name,time:ex.time,details:ex.details)
        exerciseList.append(ex2)
        if (saveExercises(exerciseList)) {
            return ex2.id
        } else {
            return -1
        }
    }
    
    
    
    static func getAllWorkouts() -> [Workout] {
        let list1 : [WorkoutTemplate] = getFromStoredJSONFile("workouts")
        var list2 : [Workout] = []
        for i in list1 {
            var w = Workout(id: i.id, name: i.name, restTime: i.restTime, details: i.details)
            for j in i.exercises {
//                print("Name: "+getExerciseById(id: j).name)
                w.exercises.append(getExerciseById(id: j))
            }
            list2.append(w)
        }
        return list2
        
    }
    static func maxWorkoutId()->Int {
        let workouts : [Workout] = getAllWorkouts()
        var max = -1
        for i in workouts {
            if i.id > max {
                max = i.id
            }
        }
        return max
    }
    static func saveWorkouts(_ exs : [Workout])->Bool {
        return setJSONFile("workouts", exs)
    }
    static func getWorkoutById(id : Int)->Workout {
        let workouts : [Workout] = getAllWorkouts()
        for i in workouts {
            if i.id == id {
                return i
            }
        }
        return .null
    }
    static func generateNewWorkoutId()->Int {
        let g = getStoredVariable("maxworkoutid")
        if (g.isEmpty) {
            let i = maxWorkoutId()+1
            let _ = writeStoredVariable("maxworkoutid", String(i))
            return i
        } else {
            let s = Int(g[0][0]) ?? -1
            if (s == -1) {
                let i = maxWorkoutId()+1
                let _ = writeStoredVariable("maxworkoutid", String(i))
                return i
            } else {
                let _ = writeStoredVariable("maxworkoutid", String(s+1))
                return s+1
            }
        }
    }
    static func removeWorkout(_ id: Int)->Bool {
        var workoutList = getAllWorkouts()
        var index = 0
        for i in workoutList {
            if (i.id == id) {
                workoutList.remove(at:index)
                index-=1
            }
            index += 1
        }
        return saveWorkouts(workoutList)
    }
    static func writeWorkout(_ ex : inout Workout) -> Int {
        var workoutList = getAllWorkouts()
        if ex.id >= 0 {
            var index = 0
            for i in workoutList {
                if i.id == ex.id {
                    workoutList[index] = ex
                    if (saveWorkouts(workoutList)) {
                        return ex.id
                    } else {
                        return -1
                    }
                }
                index+=1
            }
            workoutList.append(ex)
            if (saveWorkouts(workoutList)) {
                return ex.id
            } else {
                return -1
            }
        }
        ex.id = generateNewWorkoutId()
        workoutList.append(ex)
        if (saveWorkouts(workoutList)) {
            return ex.id
        } else {
            return -1
        }
    }
    static func logWorkout(_ w : Workout, timeMinutes : Int)->Bool {
        return writeTextFileLine(filename:"workoutLogs", text:"\(getKeyFromDate())=\(w.id),\(Date.now.format(dateFormat:"H:mm")),\(timeMinutes)")
        //Workout Log Format: key from date = workoutID, timeLogged, lengthWorkoutMinutes
    }
    static func getAccountVariable(_ key : String)->[[String]] {
        return getStoredVariable(key,filename:"accountVars")
    }
}

extension Formatter {
    static let date = DateFormatter()
}
extension Date {
    func format(dateFormat: String = "dd/MM/yyyy, H:mm", calendar: Calendar = Calendar(identifier: .iso8601), locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = .current) -> String {
        Formatter.date.calendar = calendar
        Formatter.date.locale   = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateFormat = dateFormat
        return Formatter.date.string(from: self)
    }
}
extension String {
   func date(dateFormat: String = "dd/MM/yyyy, H:mm", calendar: Calendar = Calendar(identifier: .iso8601), defaultDate: Date? = nil, locale: Locale = Locale(identifier: "en_US_POSIX"), timeZone: TimeZone = .current) -> Date? {
       Formatter.date.calendar = calendar
       Formatter.date.defaultDate = defaultDate ?? calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
       Formatter.date.locale = locale
       Formatter.date.timeZone = timeZone
       Formatter.date.dateFormat = dateFormat
       return Formatter.date.date(from: self)
   }
}
