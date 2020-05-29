return {
  regex_match_entry_types = {
    number = '[1-9][0-9]*',
  },
  regex_match_values = {
    number = function(match)
      return tonumber(match)
    end,
  },
}
