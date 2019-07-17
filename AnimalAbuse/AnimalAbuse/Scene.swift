//
//  Scene.swift
//  AnimalAbuse
//
//  Created by Spence on 7/17/19.
//  Copyright © 2019 Olly. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    
    var sceneView: ARSKView {
        return view as! ARSKView
    }
    
    var isWorldSetUp = false
    var target: SKSpriteNode!
    let gameSize = CGSize(width: 2, height: 2)
    
    var haveAntidote = false
    
    let antidoteLabel = SKLabelNode(text: "Number of Antidotes Collected: ")
    let numberOfAntidotesLabel = SKLabelNode(text: "0")
    
    
    var antidoteCount = 0 {
        didSet {
            self.numberOfAntidotesLabel.text = "\(antidoteCount)"
        }
    }
    
    override func didMove(to view: SKView) {
   target = SKSpriteNode(imageNamed: "target")
        addChild(target)
        setUpLabels()
    }
    
    override func update(_ currentTime: TimeInterval) {
   
        if isWorldSetUp == false
        {
            setUpWorld()
        }
        
        adjustLighting()
        guard let currentFrame = sceneView.session.currentFrame  else {
            return
        }
        collectAntidote(currentFrame: currentFrame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rescuedBo()
      
    }
   
    func setUpWorld()
    {
        // Create anchor using the camera's current position
        guard let currentFrame = sceneView.session.currentFrame,
            let scene = SKScene(fileNamed: "level1")else{
                return
        }
        
        for node in scene.children
        {
            if let node = node as? SKSpriteNode
            {
                var translation = matrix_identity_float4x4
                let xPos = node.position.x/scene.size.width
                let yPos = node.position.y/scene.size.height
                translation.columns.3.x = Float(xPos*gameSize.width)
                translation.columns.3.z = -Float(yPos*gameSize.height)
                translation.columns.3.y = Float.random(in: -0.5..<0.5)
                let transform = simd_mul(currentFrame.camera.transform, translation)
                //let anchor = ARAnchor(transform: transform)
                //sceneView.session.add(anchor: anchor)
                let anchor = Anchor(transform: transform)
                if let name = node.name,
                    let type = NodeType(rawValue: name) {
                    anchor.type = type
                    sceneView.session.add(anchor: anchor)
                }
            }
        }
        isWorldSetUp = true
    }
    
    
    func adjustLighting(){
        
        //  if the app is unable to get a light estimate it will exit the method and prevent the app from crashing
        guard let currentFrame = sceneView.session.currentFrame, let lightEstimate = currentFrame.lightEstimate else {
            return
        }
        
        let neutralIntensity: CGFloat = 1000
        let ambientIntensity = min(lightEstimate.ambientIntensity, neutralIntensity)
        let blendFactor = 1 - ambientIntensity / neutralIntensity
        
        for node in children {
            if let bunnyBo = node as? SKSpriteNode {
                bunnyBo.color = .black
                bunnyBo.colorBlendFactor = blendFactor
            }
        }
    }
    
    func rescuedBo() {
        let location = target.position
        let hitNodes = nodes(at: location)
        var rescueBo: SKNode?
        for node in hitNodes {
            if node.name == "Bo" && haveAntidote == true  {
                rescueBo = node
                break
            }
        }
        if let rescueBo = rescueBo {
            let wait = SKAction.wait(forDuration: 0.3)
            let removeBo = SKAction.removeFromParent()
            let sequence = SKAction.sequence([wait, removeBo])
            rescueBo.run(sequence)
            
            
        }

    }
    
    func collectAntidote(currentFrame: ARFrame) {
        for anchor in currentFrame.anchors {
            guard let node = sceneView.node(for: anchor),
                node.name == NodeType.cure.rawValue
                else {continue}
            let distance = simd_distance(anchor.transform.columns.3, currentFrame.camera.transform.columns.3)
            if distance < 0.1 {
                sceneView.session.remove(anchor: anchor)
                haveAntidote = true
                antidoteCount += 1
                break
                
            }
           
        }


  }

    func setUpLabels() {
        
        antidoteLabel.fontSize = 20
        antidoteLabel.fontName = "Futura-Medium"
        antidoteLabel.color = .white
        antidoteLabel.position = CGPoint(x: 0, y: 280)
        addChild(antidoteLabel)
        
        
        numberOfAntidotesLabel.fontSize = 20
        numberOfAntidotesLabel.fontName = "Futura-Medium"
        numberOfAntidotesLabel.color = .white
        numberOfAntidotesLabel.position = CGPoint(x: 0, y: 240)
        addChild(numberOfAntidotesLabel)
        
        
    }
}



