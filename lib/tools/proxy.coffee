exec = require "child_process"
process = require "process"
config = require "../config.coffee"
fs = require 'fs'

currentProcesses = []

###*
 * Executes a command to PHP proxy
 * @param  {string}  command Command to exectue
 * @param  {boolean} async   Must be async or not
 * @return {array}           Json of the response
###
execute = (command, async) ->
  if not async
    for c in command
      c.replace(/\\/g, '\\\\')

    try
      # avoid multiple processes of the same command
      if not currentProcesses[command]?
        currentProcesses[command] = true

        stdout = exec.spawnSync(command).output[1].toString('ascii')

        delete currentProcesses[command]
        return stdout
    catch err
      return []
  else
    command.replace(/\\/g, '\\\\')

    if not currentProcesses[command]?
      currentProcesses[command] = exec.exec(command, (error, stdout, stderr) ->
        delete currentProcesses[command]
        return []
      )

module.exports =
  ###*
   * Returns all fields available at the current cursor position
   *
   * @return {Array}
  ###
  fields: () ->
    return []
