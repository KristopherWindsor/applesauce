
type config_type
  const max = 128
  
  declare constructor()
  declare sub init(filename as string)
  declare function get(key as string) as string
  declare function getInt(key as string) as integer
  declare sub set(key as string, value as string)
  
  as integer total
  as string keys(1 to max)
  as string values(1 to max)
end type

dim shared as config_type ptr getConfig

constructor config_type()
  getConfig = @this
end constructor

sub config_type.init(filename as string)
  dim as integer temp, ff = freefile()
  dim as string l, a, b
  
  open filename for input as #ff
  while not eof(ff)
    line input #ff, l
    temp = instr(l, "=")
    if temp = 0 then continue while
    this.set(left(l, temp - 1), mid(l, temp + 1))
  wend
  close #ff
end sub

function config_type.get(key as string) as string
  for i as integer = 1 to total
    if keys(i) = key then return values(i)
  next i
  return ""
end function

function config_type.getInt(key as string) as integer
  return cint(val(this.get(key)))
end function

sub config_type.set(key as string, value as string)
  if total = max then return
  
  for i as integer = 1 to total
    if keys(i) = key then values(i) = value: return
  next i
  
  total += 1
  keys(total) = key
  values(total) = value
end sub
