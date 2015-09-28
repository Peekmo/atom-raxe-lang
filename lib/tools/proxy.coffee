exec = require "child_process"
process = require "process"
config = require "../config.coffee"
fs = require 'fs'

currentProcesses = []
childProcess = null

###*
 * Executes a command to PHP proxy
 * @param  {string}  command Command to exectue
 * @param  {boolean} async   Must be async or not
 * @return {array}           Json of the response
###
execute = (command, cwd, async) ->
  if not async
    for c in command
      c.replace(/\\/g, '\\\\')

    try
      # avoid multiple processes of the same command
      if not currentProcesses[command]?
        currentProcesses[command] = true

        elements = command.split(" ")
        cmd = elements.shift()
        stdout = exec.spawnSync(cmd, elements, {cwd: cwd}).output[2].toString('ascii')

        delete currentProcesses[command]
        return stdout
    catch err
      return []
  else
    command.replace(/\\/g, '\\\\')
    elements = command.split(" ")
    cmd = elements.shift()

    childProcess = exec.spawn(cmd, elements, {cwd: cwd}, (error, stdout, stderr) ->
      return []
    )

module.exports =
  watchDirectoryTarget: null

  ###*
   * Kill the watch process
  ###
  kill: () ->
    if childProcess
      childProcess.kill()

  ###*
   * Launch the server raxe server to watch
  ###
  watch: () ->
    for directory in atom.project.getDirectories()
      @watchDirectoryTarget = "#{directory.path}/.raxecompletion"
      execute("#{config.config.raxe} -s #{directory.path} -d ./.raxecompletion --raxe-only -w", directory.path, true)


  ###*
   * Returns all fields available at the current cursor position
   *
   * @param {string} file Filename
   *
   * @return {Array}
  ###
  fields: (file) ->
    if not @watchDirectoryTarget?
      @watch()

    for directory in atom.project.getDirectories()
      newFile = file.replace(directory.path, @watchDirectoryTarget)
      newFile = newFile.replace(".rx", ".hx")
      newFile = newFile.replace(@watchDirectoryTarget + "/", "")

      return execute("#{config.config.haxe} --display #{newFile}@0 -D display-details", @watchDirectoryTarget, false)
