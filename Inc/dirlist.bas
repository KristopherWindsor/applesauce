
function dirlist(path as string) as linkedlist_type ptr
  dim as string filename = Dir(path + "/*", &H10)
  dim as linkedlist_type ptr res
  
  if filename = "" then
    return res
  end if
  
  res = new linkedlist_type(filename)
  do
    filename = dir()
    if filename = "" then exit do
    res = res->add(filename)
  loop
  
  return res
end function
