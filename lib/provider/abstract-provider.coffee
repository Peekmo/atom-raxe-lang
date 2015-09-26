module.exports =
  class AbstractProvider
    selector: '.source.rx'
    disableForSelector: '.source.rx .comment, .source.rx .string'
    inclusionPriority: 1

    getPrefix: (editor, bufferPosition) ->
      # Get the text for the line up to the triggered buffer position
      line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

      # Match the regex to the line, and return the match
      matches = line.match(@regex)

      # Looking for the correct match
      if matches?
        for match in matches
          start = bufferPosition.column - match.length
          if start >= 0
            word = editor.getTextInBufferRange([[bufferPosition.row, bufferPosition.column - match.length], bufferPosition])
            if word == match
              # Not really nice hack.. But non matching groups take the first word before. So I remove it.
              # Necessary to have completion juste next to a ( or [ or {
              if match[0] == '(' or match[0] == '['
                match = match.substring(1)

              return match

      return ''

    ###*
     * Entry point of all request from autocomplete-plus
     * Calls @fetchSuggestion in the provider if allowed
     * @return array Suggestions
    ###
    getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
      return @fetchSuggestions({editor, bufferPosition, scopeDescriptor, prefix})
