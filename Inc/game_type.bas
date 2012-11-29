
type game_type
  const button_max = 8
  
  declare constructor(path as string)
  
  declare sub run()
  
  as string title
  as string path
  as string description
  as string run_command
  as string run_params
  as integer run_mapper 'boolean
  
  graphic as fb.image ptr
end type

constructor game_type(path as string)
  dim as integer ff = freefile(), temp
  dim as string l
  
  this.path = path
  
  open exepath() + "/Games/" + path + "/title.txt" for input as #ff
  line input #ff, this.title
  close #ff
  
  open exepath() + "/Games/" + path + "/description.txt" for input as #ff
  while not eof(ff)
    line input #ff, l
    this.description += l + !"\n"
  wend
  close #ff
  
  open exepath() + "/Games/" + path + "/run.txt" for input as #ff
  line input #ff, this.run_command
  line input #ff, this.run_params
  input #ff, this.run_mapper
  close #ff
  temp = instr(this.run_command, "{path}")
  if temp > 0 then
    this.run_command = left(this.run_command, temp - 1) + exepath() + "/Games/" + path + mid(this.run_command, temp + 6)
  end if

  graphic = bloader(exepath() + "/Games/" + path + "/screenshot.bmp", getConfig->getInt("thumbx"), getConfig->getInt("thumby"))
end constructor

sub game_type.run ()
  dim as integer handle
  
  'minimize this window
  screencontrol(fb.get_window_handle, handle)
  ShowWindow(cast(hwnd, handle), SW_MINIMIZE)
  
  if this.run_mapper then
    _spawnlp(_P_NOWAIT, exepath() + "/Games/" + this.path + "/ahk.exe", " ", null)
  end if
  
  sleep(2000, 1)
  chdir(exepath() + "/Games/" + this.path + "/game")
  exec(this.run_command, this.run_params)
  sleep(2000, 1)
  
  if this.run_mapper then
    _spawnlp(_P_NOWAIT, exepath() + "/closeahk.exe", " ", null)
    sleep(500, 1)
    dim as INPUT_ ki
    for i as integer = 1 to 255
      ki.type = INPUT_KEYBOARD
      ki.ki.wVk = i
      ki.ki.dwFlags = KEYEVENTF_KEYUP
      SendInput(1, @ki, Sizeof(ki))
    next i
  end if
  
  'restore window
  ShowWindow(cast(hwnd, handle), SW_RESTORE)
  Sleep(500, 1)
end sub

