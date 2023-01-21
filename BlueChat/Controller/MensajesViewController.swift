import UIKit

class MensajesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var myTable : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        myTable.register(UITableView.self, forCellReuseIdentifier: "cell")
        myTable.delegate = self
        myTable.dataSource = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Omar Diaz"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Mostrar mensajes
    //let vc = ChatViewController()
    //vc.title = "Chat"

}
