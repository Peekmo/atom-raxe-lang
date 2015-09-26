AbstractProvider = require "./abstract-provider.coffee"

module.exports =
class AutocompleteProvider extends AbstractProvider
  # Required: Return a promise, an array of suggestions, or null.
  fetchSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    @regex = /([a-zA-Z0-9_])+\.([a-zA-Z0-9_])*/

    prefix = @getPrefix(editor, bufferPosition)

    if prefix
      return []
