import std/[os, strformat]

proc initGitRepo*(projectDir: string) =
  # Переходим в директорию проекта
  let currentDir = getCurrentDir()
  setCurrentDir(projectDir)
  
  # Инициализируем Git репозиторий
  echo "Initializing Git repository..."
  discard execShellCmd("git init")
  
  # Добавляем файлы в репозиторий
  discard execShellCmd("git add .")
  
  # Делаем первый коммит
  discard execShellCmd("git commit -m \"Initial commit\"")
  
  # Создаем ветку main (если нужно)
  discard execShellCmd("git branch -M main")
  
  # Спрашиваем про удаленный репозиторий
  stdout.write("Add remote repository URL (leave empty to skip): ")
  let remoteUrl = stdin.readLine()
  
  if remoteUrl != "":
    discard execShellCmd(fmt"git remote add origin {remoteUrl}")
    echo "Remote repository added. Use 'forgen push' to push changes."
  
  # Возвращаемся в исходную директорию
  setCurrentDir(currentDir)
