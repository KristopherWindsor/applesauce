
#include once "fbgfx.bi"

function key_match(key as string, shouldMatch as string) as integer
  
  dim as string build, c
  
  shouldMatch += "|"
  for i as integer = 0 to len(shouldMatch)
    c = chr(shouldMatch[i])
    if c = "|" then
      if left(build, 2) = "\\" then
        if key = chr(255, val(mid(build, 3))) then return true
      elseif left(build, 1) = "\" then
        if key = chr(val(mid(build, 2))) then return true
      else
        if key = build then return true
      end if
      build = ""
    else
      build += c
    end if
  next i
  
  return false
end function
