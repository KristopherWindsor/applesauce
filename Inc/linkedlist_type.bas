
'string linked list

type linkedlist_type
  
  declare constructor(data as string = "")
  declare function add(data as string) as linkedlist_type ptr
  declare sub cleanup()
  
  as string data
  as linkedlist_type ptr n
end type

constructor linkedlist_type(data as string = "")
  this.data = data
end constructor

function linkedlist_type.add(data as string) as linkedlist_type ptr
  dim as linkedlist_type ptr res = new linkedlist_type(data)
  res->n = @this
  return res
end function

sub linkedlist_type.cleanup()
  'recursion -> yes i'm putting the whole list on the stack
  if this.n > 0 then
    this.n->cleanup()
    delete this.n
  end if
end sub
