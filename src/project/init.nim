import std/[os, strformat, strutils, tables]
import templates
import gitUtils

proc askQuestion*(prompt: string, default = ""): string =
  if default != "":
    stdout.write(fmt"{prompt} [{default}]: ")
  else:
    stdout.write(fmt"{prompt}: ")
  
  result = stdin.readLine()
  if result == "" and default != "":
    result = default

proc askYesNo*(prompt: string, default = true): bool =
  let defaultStr = if default: "Y/n" else: "y/N"
  stdout.write(fmt"{prompt} [{defaultStr}]: ")
  
  let answer = stdin.readLine().toLowerAscii()
  if answer == "":
    return default
  
  return answer.startsWith("y")

proc createProject*(name: string) =
  # Проверяем, существует ли директория
  if dirExists(name):
    echo fmt"Error: Directory '{name}' already exists"
    quit(1)
  
  # Создаем директорию проекта
  createDir(name)
  
  # Собираем информацию о проекте
  echo "Creating new Ryton project..."
  let 
    author = askQuestion("Author name")
    version = askQuestion("Version", "1.0")
    package = askQuestion("Package name", fmt"org.{author}.{name}")
  
  # Выбор шаблона проекта
  echo "\nSelect project template:"
  echo "1. CLI Application"
  echo "2. GUI Application"
  echo "3. Web Application"
  echo "4. Library"
  
  let templateChoice = askQuestion("Enter choice (1-4)", "1")
  let projectTemplate = case templateChoice:
    of "2": ptGUI
    of "3": ptWeb
    of "4": ptLibrary
    else: ptCLI
  
  # Создаем структуру директорий
  let defaultDirs = case projectTemplate:
    of ptCLI: "src tests"
    of ptGUI: "src src/ui resources tests"
    of ptWeb: "src src/routes src/views src/models tests"
    of ptLibrary: "src tests examples docs"
  
  let dirs = askQuestion("Directories to create (space separated)", defaultDirs)
  
  for dir in dirs.split():
    createDir(name / dir)
  
  # Добавляем зависимости
  var 
    rimbleLibs = initTable[string, string]()
    nimbleLibs = initTable[string, string]()
  
  case projectTemplate:
    of ptGUI:
      rimbleLibs["rtk"] = "1.0"
      nimbleLibs["nimqt"] = "1.2"
    of ptWeb:
      rimbleLibs["blyze"] = "0.5"
    else: discard
  
  # Создаем задачи
  var tasks = initTable[string, Table[string, string]]()
  
  # Задача debug
  var debugTask = initTable[string, string]()
  debugTask["1"] = "rytonc build src"
  debugTask["2"] = "nim c --path:~/projects/CLI/RytonLang/stdLib -d:debug --debuginfo --linedir:on -o:bin/" & name & " src/" & name & ".nim"
  tasks["debug"] = debugTask
  
  # Задача run
  var runTask = initTable[string, string]()
  runTask["1"] = "ryton_debug build src"
  runTask["2"] = "nim c --path:~/projects/CLI/RytonLang/stdLib -d:debug --debuginfo --linedir:on -o:bin/" & name & " src/" & name & ".nim"
  runTask["3"] = "bin/" & name
  tasks["run"] = runTask
  
  # Задача release
  var releaseTask = initTable[string, string]()
  releaseTask["1"] = "ryton_debug build src/"
  releaseTask["2"] = "nim c --path:~/projects/CLI/RytonLang/stdLib -d:release -o:bin/" & name & " src/" & name & ".nim"
  tasks["release"] = releaseTask
  
  # Спрашиваем про Git
  let useGit = askYesNo("Initialize Git repository?", true)
  
  if useGit:
    # Добавляем Git задачи
    var commitTask = initTable[string, string]()
    commitTask["1"] = "git add ."
    commitTask["2"] = "git commit -m \"$1\""
    tasks["commit"] = commitTask
    
    var pushTask = initTable[string, string]()
    pushTask["1"] = "git push origin main"
    tasks["push"] = pushTask
  
  # Создаем файл конфигурации
  var configStr = fmt"""[app]
name = "{name}"
author = "{author}"
version = "{version}"
package = "{package}"

[deps]
rytonc = "1.0"
nim = "2.2.2"
"""

  # Добавляем библиотеки
  if rimbleLibs.len > 0:
    configStr &= "\n[rimbleLibs]\n"
    for lib, ver in rimbleLibs:
      configStr &= fmt""""{lib}" = "{ver}" """ & '\n'
  
  if nimbleLibs.len > 0:
    configStr &= "\n[nimbleLibs]\n"
    for lib, ver in nimbleLibs:
      configStr &= fmt""""{lib}" = "{ver}" """ & '\n'
  
  # Добавляем задачи
  for taskName, taskCommands in tasks:
    configStr &= "\n" & fmt"[tasks.{taskName}]" & "\n"
    for cmdKey, cmdValue in taskCommands:
      configStr &= fmt""""{cmdKey}" = "{cmdValue}" """ & "\n"
  
  # Записываем конфигурацию
  writeFile(name / "forgen.make", configStr)
  
  # Создаем основной файл проекта
  let mainContent = getTemplateContent(projectTemplate)
  
  createDir(name / "src")
  writeFile(name / "src" / name & ".ry", mainContent)
  
  # Создаем README.md
  let readmeContent = fmt"""# {name}
##### *made in Ryton*

## Building

```
## Project Structure
{name}/ 
    ├── src/    # Source code
    |   ╰── {name}.ry/  # Main file
    ├── bin/    # Compiled binaries 
    └── tests/  # Tests
```
"""
  
  writeFile(name / "README.md", readmeContent)
  
  # Создаем .gitignore
  let gitignoreContent = """bin/
nimcache/
rytoncache/
*.exe
*.o
*.so
*.dll
"""
  
  writeFile(name / ".gitignore", gitignoreContent)
  
  # Инициализируем Git репозиторий если нужно
  if useGit:
    initGitRepo(name)
  
  echo "\n" & fmt"Project '{name}' created successfully!"
  echo "cd " & name & "\n"
  discard execShellCmd(fmt"cd {name}")
  echo fmt"`forgen run` - for run"
