//
//  ARVideoView.swift
//  arvideoinspace
//
//  Created by Yasuhito NAGATOMO on 2022/01/30.
//

import SwiftUI
import RealityKit
import ARKit

struct ARVideoView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ARViewController {
        let viewController = ARViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
    }

    class Coordinator: NSObject {
        var parent: ARVideoView
        init(_ parent: ARVideoView) {
            self.parent = parent
        }
    }
}

class ARViewController: UIViewController {
    let videoName = "NewGoddardGalaxy_LGH264_480p"
    let videoType = "mov"
    let spaceName = "spaceModel.usdz"
    let screenSize: (Float, Float) = (1.28, 0.72)
    let screenPosition = SIMD3<Float>([0.0, 0.0, -1.5])
    var playerLooper: AVPlayerLooper!

    override func viewDidAppear(_ animated: Bool) {
        let arView = ARView(frame: .zero)
        view = arView

        let anchorEntity = AnchorEntity()
        arView.scene.addAnchor(anchorEntity)

        if let url = Bundle.main.url(forResource: videoName, withExtension: videoType) {
            let playerItem = AVPlayerItem(url: url)
            let player = AVQueuePlayer()
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)

            let material = VideoMaterial(avPlayer: player)
            do {
                let spaceEntity = try Entity.loadModel(named: spaceName)
                anchorEntity.addChild(spaceEntity)

                let mesh = MeshResource.generatePlane(width: screenSize.0, height: screenSize.1)
                let screenEntity = ModelEntity.init(mesh: mesh, materials: [material])
                screenEntity.generateCollisionShapes(recursive: true)
                arView.installGestures(.all, for: screenEntity)

                screenEntity.setPosition(screenPosition, relativeTo: nil)
                anchorEntity.addChild(screenEntity)
            } catch {
                assertionFailure("Could not load the USDZ asset.")
            }

            player.play()
        } else {
            assertionFailure("Could not load the video asset.")
        }

        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
    }
}
