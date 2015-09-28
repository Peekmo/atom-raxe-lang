proxy = require "../tools/proxy.coffee"
AbstractProvider = require "./abstract-provider.coffee"
xml2js = require 'xml2js'
fs = require 'fs'
fuzzaldrin = require 'fuzzaldrin'

module.exports =
class AutocompleteProvider extends AbstractProvider
  cache: {}

  # Required: Return a promise, an array of suggestions, or null.
  fetchSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    @regex = /([^\s=:])+\.([a-zA-Z])*/

    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix

    elements = prefix.split(".")
    current = elements.pop()
    prefix = elements.join(".")
    suggestions = []

    if not @cache[prefix]?
      @cache = {}

      if current == ""
        @insertAutocompleteFragment(editor, bufferPosition)

      xml = proxy.fields(editor.buffer.file?.path)
      return unless xml

      xml2js.parseString(xml, (err, result) =>
        if err? or not result?
          return

        @cache[prefix] = {}
        for item in result.list.i
          if item.$.k == "var"
            @cache[prefix][item.$.n] =
              text: item.$.n
              description: item.d.join("\\n")
              type: "property"
              leftLabel: item.t[0].trim()
              replacementPrefix: current
          else
            @cache[prefix][item.$.n] =
              snippet: @getSnippet(item)
              description: item.d.join("\\n")
              type: "method"
              leftLabel: item.t[0].split("->").pop().trim()
              replacementPrefix: current
      )

    keys = (k for k of @cache[prefix])
    words = fuzzaldrin.filter keys, current

    for w in words
      @cache[prefix][w].replacementPrefix = current
      suggestions.push @cache[prefix][w]

    return suggestions

  ###*
   * Returns the snippet for the given element
   *
   * @param  {Object} item Item from haxe --display compiler
   *
   * @return {string
  ###
  getSnippet: (item) =>
    content = item.$.n + "("
    index = 1
    args = item.t[0].split("->")

    # Remove return type
    args.pop()

    for arg in args
      arg = arg.trim()

      # NO args
      if arg == "Void" and args.length == 1
        break

      # Callbacks in parameters
      if arg[0].toUpperCase() == arg[0] and arg[0] != "?"
        content = "#{content} -> #{arg}"
      else if index == 1
        content = "#{content}${#{index}:#{arg}"
        index++
      else
        content = "#{content}}, ${#{index}:#{arg}"
        index++

    if index != 1
      content = "#{content}}"

    content = "#{content})$0"
