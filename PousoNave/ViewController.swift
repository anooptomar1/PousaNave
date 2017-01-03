//
//  ViewController.swift
//  PousoNave
//
//  Created by Yuri Natividade on 11/12/16.
//  Copyright © 2016 Yuri Natividade. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class ViewController: UIViewController, SCNSceneRendererDelegate {

    var sceneView : SCNView {
        return view as! SCNView
    }
    
    var scene : SCNScene {
        return sceneView.scene!
    }
    
    var naveNode = SCNNode()
    var velocidadeLabel = SKLabelNode()
    let camera = SCNNode()
    var ultimoTempo = TimeInterval()
    var ultimaPosicao = SCNVector3()
    let fogoPropulsor = SCNParticleSystem(named: "Fogo.scnp", inDirectory: "Assets.scnassets")
    var propulsorDireito = false
    var propulsorEsquerdo = false
    var propulsorDireitoNode = SCNNode()
    var propulsorEsquerdoNode = SCNNode()
    var toqueDireito : UITouch?
    var toqueEsquerdo : UITouch?
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - ultimoTempo
        let distancia = Double(ultimaPosicao.distance(vector: naveNode.presentation.position))
        
        var velocidade = 0.0
        if deltaTime > 0 {
            velocidade = distancia / deltaTime * 10
        }
        
        if propulsorDireito {
            naveNode.physicsBody?.applyForce(SCNVector3(-0.01, 0.05, 0), asImpulse: true)
            
            if propulsorDireitoNode.particleSystems == nil {
                propulsorDireitoNode.addParticleSystem(fogoPropulsor?.copy() as! SCNParticleSystem)
            }
        } else {
            propulsorDireitoNode.removeAllParticleSystems()
        }
        
        if propulsorEsquerdo {
            naveNode.physicsBody?.applyForce(SCNVector3(0.01, 0.05, 0), asImpulse: true)
            if propulsorEsquerdoNode.particleSystems == nil {
                propulsorEsquerdoNode.addParticleSystem(fogoPropulsor?.copy() as! SCNParticleSystem)
            }
        } else {
            propulsorEsquerdoNode.removeAllParticleSystems()
        }
        
        print("\(propulsorEsquerdo) <-> \(propulsorDireito)")
        
        velocidadeLabel.text = String(format: "%.1f m/s", velocidade)
        camera.position = naveNode.presentation.position + SCNVector3(0, 0, 3 + naveNode.presentation.position.y)
        
        ultimoTempo = time
        ultimaPosicao = naveNode.presentation.position
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        layoutScene()
        setupCamera()
        setupHUD()
        
        sceneView.delegate = self
    }
    
    func setupScene() {
        
        view.isMultipleTouchEnabled = true
        
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        
        scene.background.contents = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        scene.physicsWorld.gravity = SCNVector3(0, -1.6, 0)
    }
    
    func layoutScene() {
        
        
        let chuva = SCNParticleSystem(named: "Chuva.scnp", inDirectory: "Assets.scnassets")
        let chuvaNode = SCNNode()
        chuvaNode.addParticleSystem(chuva?.copy() as! SCNParticleSystem)
        chuvaNode.position = SCNVector3(0, 20, 0)
        scene.rootNode.addChildNode(chuvaNode)
        
        let naveScene = SCNScene(named: "Assets.scnassets/Nave.scn")!
        naveNode = naveScene.rootNode.childNodes.first! as SCNNode
        scene.rootNode.addChildNode(naveNode)
        naveNode.enumerateChildNodes { (node, _) in
            if node.name == "propulsorDireito" {
                propulsorDireitoNode = node
            }
            if node.name == "propulsorEsquerdo" {
                propulsorEsquerdoNode = node
            }
        }
        
        
        let terrenoScene = SCNScene(named: "Assets.scnassets/Terreno.scn")
        terrenoScene?.rootNode.enumerateChildNodes({ (node, _) in
            
            if node.name == "base1" {
                naveNode.position = node.position + SCNVector3(0, 0.25, 0)
            }
            scene.rootNode.addChildNode(node)
            
        })
        
        naveNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: naveNode, options: nil))
        naveNode.physicsBody?.angularVelocityFactor = SCNVector3(0, 0, 1)
    }
    
    func setupCamera() {
        
        camera.camera = SCNCamera()
        scene.rootNode.addChildNode(camera)
        camera.position = SCNVector3(0, 4, 10)
    }
    
    func setupHUD() {
        let hudScene = SKScene(fileNamed: "Assets.scnassets/hud.sks")
        hudScene?.scaleMode = .aspectFill
        hudScene?.isUserInteractionEnabled = false
        sceneView.overlaySKScene = hudScene
        velocidadeLabel = hudScene?.childNode(withName: "velocidadeLabel")! as! SKLabelNode
        velocidadeLabel.text = "0"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for toque in touches {
            
            let posicao = toque.location(in: view)
            
            if posicao.x < view.frame.size.width / 2 {
                propulsorEsquerdo = true
                toqueEsquerdo = toque
            } else {
                propulsorDireito = true
                toqueDireito = toque
            }
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for toque in touches {
            if toque == toqueDireito {
                propulsorDireito = false
                toqueDireito = nil
            } else if toque == toqueEsquerdo {
                propulsorEsquerdo = false
                toqueEsquerdo = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for toque in touches {
            if toque == toqueDireito {
                propulsorDireito = false
                toqueDireito = nil
            } else if toque == toqueEsquerdo {
                propulsorEsquerdo = false
                toqueEsquerdo = nil
            }
        }
    }

}

