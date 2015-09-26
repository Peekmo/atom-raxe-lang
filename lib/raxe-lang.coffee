{CompositeDisposable} = require 'atom'
config = require './config.coffee'

AutocompleteProvider = require './provider/autocomplete-provider.coffee'
VariableProvider = require './provider/variable-provider.coffee'

module.exports = RaxeLang =
  config:
    haxe:
      title: 'Haxe command'
      description: 'Command to use haxe'
      type: 'string'
      default: 'haxe'
      order: 1

    raxe:
      title: 'Raxe command'
      description: 'Command to use raxe CLI'
      type: 'string'
      default: 'haxelib run raxe'
      order: 2

  providers: []

  activate: (state) ->
    config.init()

    @providers.push new AutocompleteProvider()
    @providers.push new VariableProvider()
  deactivate: ->
  provide: ->
    return @providers
