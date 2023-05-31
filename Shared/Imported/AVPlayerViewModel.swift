//
//  AVPlayerViewModel.swift
//  Exercise Assistant
//
//  Created by Sam Engel on 4/17/22.
//

import Foundation
import AVKit
import SwiftUI
import Combine
final class AVPlayerViewModel: ObservableObject {

    @Published var pipStatus: PipStatus = .undefined
    @Published var media: Media?

    let player = AVPlayer()
    private var cancellable: AnyCancellable?
    
    init() {
//        setAudioSessionCategory(to: .playback)
//        cancellable = $media
//            .compactMap({ $0 })
//            .compactMap({ URL(string: $0.url) })
//            .sink(receiveValue: { [weak self] in
////                guard let self = self else { return }
////                let videoUrl = URL(string: "Exercise-Assistant-(iOS)://\(assetName)")!
////                let asset = AVURLAsset(url: videoUrl)
////                guard let dataAsset = NSDataAsset(name: assetName) else {
////                    fatalError("Data asset not found with name \(assetName)")
////                }
////                let resourceDelegate = DataAssetAVResourceLoader(dataAsset: dataAsset)
////                assetLoaderDelegate = resourceDelegate
////                asset.resourceLoader.setDelegate(resourceDelegate, queue: .global(qos: .userInteractive))
////
////                let item = AVPlayerItem(asset: asset)
////                self.player.replaceCurrentItem(with: AVPlayerItem(asset:))
//            })
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func setAudioSessionCategory(to value: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
           try audioSession.setCategory(value)
        } catch {
           print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
}

struct Media {
    let title: String
    let url: String
}

enum PipStatus : String {
    case willStart = "willStart"
    case didStart = "didStart"
    case willStop = "willStop"
    case didStop = "didStop"
    case undefined = "undefined"
}

struct AVVideoPlayer: UIViewControllerRepresentable {
    @ObservedObject var viewModel: AVPlayerViewModel
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        print("running setup")
        let vc = AVPlayerViewController()
        vc.player = viewModel.player
        vc.delegate = context.coordinator
        vc.canStartPictureInPictureAutomaticallyFromInline = true
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        let parent: AVVideoPlayer
        
        init(_ parent: AVVideoPlayer) {
            self.parent = parent
        }
        
        func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
            parent.viewModel.pipStatus = .willStart
        }
        
        func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
            parent.viewModel.pipStatus = .didStart
        }
        
        func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
            parent.viewModel.pipStatus = .willStop
        }
        
        
        func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
            parent.viewModel.pipStatus = .didStop
        }
    }
}
