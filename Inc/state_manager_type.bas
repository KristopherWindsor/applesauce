
'detect and change the state of the applesauce gui window

#include once "fbgfx.bi"
#include once "windows.bi"
#include "crt.bi"
#include once "crt/process.bi"

enum state_manager_enum
  minimized  = 1
  active     = 2
  outoffocus = 3
end enum

type state_manager_type
  As HWND gameWindow
  
  declare constructor ()
  
  declare sub setState(state as state_manager_enum)
  declare function getState() as state_manager_enum
  
  declare sub goAwayMouse()
  declare sub altTab()
  declare function isMinimized() as integer
  declare function hasFocus() as integer
end type

constructor state_manager_type ()
  screencontrol(FB.GET_WINDOW_HANDLE, cast(Integer, gameWindow))
end constructor

sub state_manager_type.setState(state as state_manager_enum)
  'note: cannot set state to outoffocus
  
  dim as state_manager_enum old = this.getState()
  dim as integer handle
  
  'minimize this window
  screencontrol(fb.get_window_handle, handle)
  
  if old = state then return
  
  if state = state_manager_enum.minimized then
    'only one path to minimized state
    ShowWindow(cast(hwnd, handle), SW_MINIMIZE)
    sleep(500, 1)
  elseif state = state_manager_enum.active and old = state_manager_enum.minimized then
    'restore window to get to active state from minimized
    ShowWindow(cast(hwnd, handle), SW_RESTORE)
    sleep(500, 1)
    SetForegroundWindow(gameWindow)
    'restored window might not have focus
    if not hasFocus() then altTab()
  elseif state = state_manager_enum.active and old = state_manager_enum.outoffocus then
    'use alt+tab to get focus back
    altTab()
  end if
end sub

function state_manager_type.getState() as state_manager_enum
  if isMinimized() then
    return state_manager_enum.minimized
  end if
  if not hasFocus() then return state_manager_enum.outoffocus
  return state_manager_enum.active
end function

sub state_manager_type.goAwayMouse()
  setmouse(0, 0, 0)
end sub

sub state_manager_type.altTab()
  Dim As INPUT_ ki, ki2(0 To 1)
  
  ki2(0).type = INPUT_KEYBOARD
  ki2(0).ki.wVk = VK_MENU
  ki2(0).ki.dwFlags = 0
  ki2(1).type = INPUT_KEYBOARD
  ki2(1).ki.wVk = VK_TAB
  ki2(1).ki.dwFlags = 0
  SendInput(2, @ki2(0), Sizeof(ki))
  Sleep(50, 1)
  ki2(0).type = INPUT_KEYBOARD
  ki2(0).ki.wVk = VK_TAB
  ki2(0).ki.dwFlags = KEYEVENTF_KEYUP
  ki2(1).type = INPUT_KEYBOARD
  ki2(1).ki.wVk = VK_MENU
  ki2(1).ki.dwFlags = KEYEVENTF_KEYUP
  SendInput(2, @ki2(0), Sizeof(ki))
  Sleep(50, 1)
end sub

function state_manager_type.isMinimized() as integer
  dim as WINDOWPLACEMENT wp
  wp.length = sizeof(wp)
  GetWindowPlacement(gameWindow, @wp)
  return wp.showCmd = SW_SHOWMINIMIZED
end function

function state_manager_type.hasFocus() as integer
  Dim As INPUT_ ki
  
  While Inkey() > "": Wend
  
  ki.type = INPUT_KEYBOARD
  ki.ki.wVk = VK_Q
  ki.ki.dwFlags = 0
  SendInput(1, @ki, Sizeof(ki))
  Sleep(50, 1)
  ki.type = INPUT_KEYBOARD
  ki.ki.wVk = VK_Q
  ki.ki.dwFlags = KEYEVENTF_KEYUP
  SendInput(1, @ki, Sizeof(ki))
  Sleep(50, 1)

  return Lcase(Inkey()) = "q"
end function
