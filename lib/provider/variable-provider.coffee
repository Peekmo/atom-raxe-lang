fuzzaldrin = require 'fuzzaldrin'
parser = require "../tools/parser.coffee"
AbstractProvider = require "./abstract-provider"

module.exports =
# Autocomplete for variables in the current function
class VariableProvider extends AbstractProvider
  variables: []

  ###*
   * Get suggestions from the provider (@see provider-api)
   * @return array
  ###
  fetchSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    @regex = /([a-zA-Z_0-9]+)/g

    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix.length

    @variables = parser.getAllVariablesInFunction(editor, bufferPosition)
    return unless @variables.length

    suggestions = @findSuggestionsForPrefix(prefix.trim())
    return unless suggestions.length
    return suggestions

  ###*
   * Returns suggestions available matching the given prefix
   * @param {string} prefix Prefix to match
   * @return array
  ###
  findSuggestionsForPrefix: (prefix) ->
    # Filter the words using fuzzaldrin
    words = fuzzaldrin.filter @variables, prefix

    # Builds suggestions for the words
    suggestions = []
    for word in words
      suggestions.push
        text: word,
        type: 'variable',
        replacementPrefix: prefix

    return suggestions

  ###*
   * Get prefix for autocomplete
   *
   * @return {string}
  ###
  getPrefix: (editor, bufferPosition) ->
    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

    # Match the regex to the line, and return the match
    matches = line.match(@regex)

    # Looking for the correct match
    if matches?
      for key in [0...matches.length]
        match = matches[key]
        start = bufferPosition.column - match.length
        if start >= 0
          word = editor.getTextInBufferRange([[bufferPosition.row, bufferPosition.column - match.length], bufferPosition])
          if word == match
            # Avoid autocomplete in variable declarations
            if key > 0 and matches[key-1] == "def"
              continue

            # Not really nice hack.. But non matching groups take the first word before. So I remove it.
            # Necessary to have completion juste next to a ( or [ or {
            if match[0] == '(' or match[0] == '['
              match = match.substring(1)

            return match

    return ''
