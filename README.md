# Forgen - A simple Build System

Система сборки для проектов любой сложности, на любом языке программирования.
Заточен под написание скриптов сборки для пректов на Ryton и Nim.

# Установка
```
git clone https://github.com/CodeLibraty/Forgen.git
```

# Сборка

Для сборки используется [Nim](https://nim-lang.org/)
- для дебаг сборки:
  ```
  nim r build.nim build
  ```
- для релизной сборки:
  ```
  nim r build.nim release
  ```

# Использование

создайте файл forgen.make в корне проекта, и запишите в него:
```
[app]
name = "project"
author = "rejzi"
version = "1.0"
package = "org.rejzi.project"

[deps]
rytonc = "1.0"
nim = "2.2.2"

[rimbleLibs]
"rtk" = "1.0" 

[nimbleLibs]
"nimqt" = "1.2" 

[tasks.debug]
"1" = "rytonc build src" 
"2" = "nim c --path:~/projects/CLI/RytonLang/stdLib -d:debug --debuginfo --linedir:on -o:bin/project src/project.nim" 

[tasks.release]
"1" = "ryton_debug build src" 
"2" = "nim c --path:~/projects/CLI/RytonLang/stdLib -d:debug --debuginfo --linedir:on -o:bin/project src/project.nim" 

[tasks.run]
"1" = "ryton_debug build src" 
"2" = "nim c --path:~/projects/CLI/RytonLang/stdLib -d:debug --debuginfo --linedir:on -o:bin/project src/project.nim" 
"3" = "bin/project" 

```
- [app] - основные параметры проекта
- [deps] - внешние зависимости 
- [rimbleLibs] - зависимости для Ryton
- [nimbleLibs] - зависимости для Nim
- [tasks.debug] - задачи для сборки в режиме дебага
- [tasks.release] - задачи для сборки в режиме релиза
- [tasks.run] - задачи для запуска проекта

после чего вы сможете выполнять комманды из файла forgen.make - для этого введите в терминале:
```
forgen <command> 
```
например: debug, release или run

# Комманды
- `--help` `-h` - вывод справки
- `--version` `-v` - вывод версии
- `--about` - вывод информации о проекте из конфига
- `--create:Name` - создание нового проекта с именем Name

  это запустит создание нового проекта, где вы введёте нужные метаданные, forgen предложит: создать его по шаблону, пронициализировать git, и создать структуру проекта
