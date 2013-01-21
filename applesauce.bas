
' Applesauce (APPLE SAUCE) (APPLEE SAUCEE!!!)
' By Kristopher Windsor
' For the SJSU Game Development Club

#include once "fbgfx.bi"
#include once "windows.bi"
#include "crt.bi"
#include once "crt/process.bi"

#include once "Inc/bloader.bas"
#include once "Inc/config_type.bas"
#include once "Inc/game_type.bas"
#include once "Inc/linkedlist_type.bas"
#include once "Inc/dirlist.bas"
#include once "Inc/key_match.bas"
#include once "Inc/state_manager_type.bas"

Type applesauce_type
  Const game_max = 100
  
  Declare Constructor()
  Declare Destructor()
  Declare Sub menu()
  
  As Integer game_total
  As game_type Ptr game(1 To game_max)
  
  As fb.image Ptr logo
  
  As config_type config
  As state_manager_type state_manager
End Type

Constructor applesauce_type()
  Dim As Integer temp, temp2
  
  'load settings / init window
  config.init("config.txt")
  If config.getInt("sx") = -1 Then
    screencontrol(fb.GET_DESKTOP_SIZE, temp)
    config.set("sx", temp & "")
  End If
  
  screencontrol(fb.GET_DESKTOP_SIZE, temp, temp2)
  config.set("windowx", temp & "")
  config.set("windowy", temp2 & "")
  
  Setenviron("fbgfx=GDI")
  Screenres config.getInt("sx"), config.getInt("sy"), 32,, fb.GFX_NO_FRAME Or fb.GFX_ALPHA_PRIMITIVES
  Width config.getInt("sx") \ 8, config.getInt("sy") \ 16
  
  logo = imagecreate(354, 81)
  Bload("logo.bmp", logo)
  
  'load games
  Dim As linkedlist_type Ptr list, iter
  list = dirlist(Exepath() & "/Games")
  iter = list
  While iter > 0
    If iter->Data <> "." And iter->Data<> ".." And Left(iter->Data, 1) <> "-" Then
      game_total += 1
      game(game_total) = new game_type(iter->Data)
    End If
    iter = iter->n
  Wend
  
  menu()
End Constructor

Destructor applesauce_type()
  imagedestroy(logo)
End Destructor

Sub applesauce_type.menu()
  Const ttbomb = 16
  
  Dim As Integer selected_game = 1, hijackcountdown, timebomb = 9999, mx, my, mb
  Dim As Double offset, offset_t
  Dim As String key
  
  offset = (config.getInt("sx") - getConfig->getInt("thumbx")) \ 2 - (getConfig->getInt("thumbx") + 10)
  Windowtitle("Applesauce")
  
  Do
    'recover in case windows apps hijack focus; run this every minute
    hijackcountdown += 1
    If hijackcountdown Mod 3600 = 0 Then state_manager.setState(state_manager_enum.active)
    
    key = Inkey()
    If key_match(key, config.get("keyleft")) then
      If selected_game > 1 Then selected_game -= 1
    Elseif key_match(key, config.get("keyright")) Then
      If selected_game < game_total Then selected_game += 1
    Elseif key_match(key, config.get("keyexit")) Then
      Exit Do
    Elseif key_match(key, config.get("keystart")) Then
      If timebomb > ttbomb * 2 Then timebomb = -1
    End If
    
    offset_t = (config.getInt("sx") - getConfig->getInt("thumbx")) \ 2 - selected_game * (getConfig->getInt("thumbx") + 10)
    offset += (offset_t - offset) * .1
    
    timebomb += 1
    If timebomb = ttbomb Then
      Windowtitle("Applesauce (Idle)")
      state_manager.setState(state_manager_enum.minimized)
      game(selected_game)->Run()
      state_manager.setState(state_manager_enum.active)
      Windowtitle("Applesauce")
    End If
    
    Screenlock()
    Line (0, 0) - (config.getInt("sx"), config.getInt("sy")), &HFFFFFFFF, BF
    Put ((config.getInt("sx") - this.logo->Width) \ 2, 0), this.logo, trans
    For i As Integer = 1 To game_total
      With *game(i)
        Put (offset + i * (getConfig->getInt("thumbx") + 10), 100), .graphic, trans
        '.title
        Draw String (offset + i * (getConfig->getInt("thumbx") + 10), 600), .title, &HFF000000
        '.description
        Dim As Integer height = 608
        Dim As String a, b
        a = .description
        While Instr(a, !"\n")
          b = Left(a, Instr(a, !"\n") - 1)
          a = Mid(a, Len(b) + 2)
          height += 16
          If height = 640 Then height += 8
          Draw String (offset + i * (getConfig->getInt("thumbx") + 10), height), b, &HFF000000
        Wend
      End With
    Next i
    If timebomb = ttbomb - 1 Then
      Line (0, 0) - (config.getInt("sx") - 1, config.getInt("sy") - 1), &HFFFFFFFF, BF
    Elseif timebomb >= 0 And timebomb < ttbomb - 1 Then
      Line (0, 0) - (config.getInt("sx") - 1, config.getInt("sy") - 1), Rgba(255, 255, 255, timebomb * 16 + 16), BF
    Elseif timebomb >= ttbomb And timebomb < ttbomb * 2 - 1 Then
      Line (0, 0) - (config.getInt("sx") - 1, config.getInt("sy") - 1), Rgba(255, 255, 255, (ttbomb * 2 - 1 - timebomb) * 16), BF
    End If
    Screenunlock()
    
    Sleep(18, 1)
  Loop
End Sub

Dim Shared As applesauce_type applesauce
