module.exports =
  config: {}

  ###*
   * Get plugin configuration
  ###
  init: () ->
    # See also https://secure.php.net/urlhowto.php .
    @config['haxe'] = atom.config.get('raxe-lang.haxe')
    @config['raxe'] = atom.config.get('raxe-lang.raxe')

    atom.config.onDidChange 'raxe-lang.haxe', () =>
      @init()

    atom.config.onDidChange 'raxe-lang.raxe', () =>
      @init()
