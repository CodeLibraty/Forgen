type
  ProjectTemplate* = enum
    ptCLI = "cli",
    ptGUI = "gui", 
    ptWeb = "web",
    ptLibrary = "lib"

# Шаблоны для разных типов проектов
const 
  cliMainTemplate = """
module import {
    std.fStrings
}

func main(type: String) {
    print(f"Hello from {type} app!")
}

main("CLI")
"""

  guiMainTemplate = """
module import {
    rtk.Core.Window
    rtk.Core.Widget
}

pack MainWindow <- Window {
    init {
        self.title = "RTK Window"
        self.size = (800, 600)
        self.show()
    }
}

def window = MainWindow()
window.run()
"""

  webMainTemplate = """
module import {
    Blyze.Server
}

func handleRoot(req, res) {
    res.send("Hello from Ryton Web!")
}

def server = Server()
server.get("/", handleRoot)
server.listen(3000)
"""

  libMainTemplate = """
pack MyLibrary {
    func hello(name: String) {
        return "Hello, " & name & "!"
    }
}

module export {
    MyLibrary
}
"""

proc getTemplateContent*(projectTemplate: ProjectTemplate): string =
  case projectTemplate:
    of ptCLI: cliMainTemplate
    of ptGUI: guiMainTemplate
    of ptWeb: webMainTemplate
    of ptLibrary: libMainTemplate
