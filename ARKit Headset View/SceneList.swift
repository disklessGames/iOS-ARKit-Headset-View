import UIKit
import HeadSetKit
import SceneKit
import ARKit

struct Scene {
    let name: String
    let scnScene: ARUpdateable
    
}

class SceneList: UITableViewController {
    
    let scenes: [Scene] = [
        Scene(name: "Ship", scnScene: JetFighterScene()),
        Scene(name: "MouseBall", scnScene: MouseBallScene())]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SceneCell", for: indexPath)
        
        cell.textLabel?.text = scenes[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scene = scenes[indexPath.row].scnScene
        let vc = HeadsetViewController.createFromStoryBoard(with: scene)
        navigationController?.pushViewController(vc, animated: true)
    }
}
