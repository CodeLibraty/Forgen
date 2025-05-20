import std/[os, strformat, strutils, tables, sequtils, algorithm]
import parsetoml
import project/init

type 
  ForgenConfig = object
    app: AppConfig
    deps: DepsConfig
    rimbleLibs: Table[string, string]
    nimbleLibs: Table[string, string]
    tasks: Table[string, Table[string, string]]

  AppConfig = object
    name, author, version, package: string

  DepsConfig = object
    rytonc, nim: string

proc loadConfig(): ForgenConfig =
  let toml = parsetoml.parseFile("forgen.make")
  
  # Загружаем секцию app
  result.app.name = toml["app"]["name"].getStr("")
  result.app.author = toml["app"]["author"].getStr("")
  result.app.version = toml["app"]["version"].getStr("1.0")
  result.app.package = toml["app"]["package"].getStr("")
  
  # Загружаем секцию deps
  result.deps.rytonc = toml["deps"]["rytonc"].getStr("1.0")
  result.deps.nim = toml["deps"]["nim"].getStr("2.0")
  
  # Загружаем библиотеки
  result.rimbleLibs = initTable[string, string]()
  if toml.hasKey("rimbleLibs"):
    let rimbleTable = toml["rimbleLibs"].getTable()
    for k, v in rimbleTable:
      result.rimbleLibs[k] = v.getStr
    
  result.nimbleLibs = initTable[string, string]()
  if toml.hasKey("nimbleLibs"):
    let nimbleTable = toml["nimbleLibs"].getTable()
    for k, v in nimbleTable:
      result.nimbleLibs[k] = v.getStr
  
  # Загружаем задачи
  result.tasks = initTable[string, Table[string, string]]()
  for k in toml.getTable().keys:
    if toml.hasKey("tasks"):
      let tasksTable = toml["tasks"].getTable()
      # Перебираем подсекции (debug, release и т.д.)
      for taskName, taskValue in tasksTable:
        result.tasks[taskName] = initTable[string, string]()
        let taskCommands = taskValue.getTable()
        for cmdKey, cmdValue in taskCommands:
          result.tasks[taskName][cmdKey] = cmdValue.getStr()

proc showProjectInfo(config: ForgenConfig) =
  echo "Project Information:"
  echo "==================="
  echo fmt"Name: {config.app.name}"
  echo fmt"Author: {config.app.author}"
  echo fmt"Version: {config.app.version}"
  echo fmt"Package: {config.app.package}"
  
  echo "\nDependencies:"
  echo "============"
  echo fmt"Rytonc: {config.deps.rytonc}"
  echo fmt"Nim: {config.deps.nim}"
  
  if config.rimbleLibs.len > 0:
    echo "\nRimble Libraries:"
    echo "================"
    for name, version in config.rimbleLibs:
      echo fmt"{name}: {version}"
      
  if config.nimbleLibs.len > 0:
    echo "\nNimble Libraries:"
    echo "================"
    for name, version in config.nimbleLibs:
      echo fmt"{name}: {version}"
      
  if config.tasks.len > 0:
    echo "\nAvailable Tasks:"
    echo "==============="
    for taskName, commands in config.tasks:
      echo "\n" & fmt"{taskName}:"
      for key, cmd in commands:
        echo fmt"  {key}: {cmd}"

proc runTask(config: ForgenConfig, taskName: string) =
  if not config.tasks.hasKey(taskName):
    echo fmt"Error: Task '{taskName}' not found"
    quit(1)
    
  let task = config.tasks[taskName]
  var keys = toSeq(task.keys)
  keys.sort()
  
  for key in keys:
    let cmd = task[key]
    echo fmt"Running: {cmd}"
    if execShellCmd(cmd) != 0:
      echo fmt"Error executing: {cmd}"
      quit(1)

proc main() =
  if paramCount() < 1:
    echo "Usage: forgen <task> or forgen --create:<name>"
    quit(1)
  
  let arg = paramStr(1)
  
  if arg.startsWith("--create:"):
    let projectName = arg.split(":")[1]
    createProject(projectName)
    return

  if arg.startsWith("--help"):
    echo "Usage: forgen <task> or forgen --create:<name>"
    quit(0)

  if arg.startsWith("--version") or arg.startsWith("-v"):
    echo "Forgen Build System - version 0.1.0 Beta"
    quit(0)

  if arg.startsWith("--about"):
    showProjectInfo(loadConfig())
    quit(0)

  let config = loadConfig()
  runTask(config, arg)

when isMainModule:
  main()