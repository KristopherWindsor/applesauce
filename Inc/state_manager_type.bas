
'detect and change the state of the applesauce gui window

#include once "fbgfx.bi"
#include once "windows.bi"
#include "crt.bi"
#include once "crt/process.bi"

Enum state_manager_enum
  minimized  = 1
  active     = 2
  outoffocus = 3
End Enum

Type state_manager_type
  As HWND gameWindow
  
  Declare Sub setState(state As state_manager_enum)
  Declare Function getState() As state_manager_enum
  
  Declare Sub goAwayMouse()
  Declare Sub altTab()
  Declare Function isMinimized() As Integer
  Declare Function hasFocus() As Integer
End Type

Sub state_manager_type.setState(state As state_manager_enum)
  'note: cannot set state to outoffocus
  
  Dim As state_manager_enum old = this.getState()
  Dim As Integer handle
  
  'minimize this window
  screencontrol(fb.get_window_handle, handle)
  
  If old = state Then Return
  
  If state = state_manager_enum.minimized Then
    'only one path to minimized state
    ShowWindow(cast(hwnd, handle), SW_MINIMIZE)
    Sleep(500, 1)
  Elseif state = state_manager_enum.active And old = state_manager_enum.minimized Then
    'restore window to get to active state from minimized
    ShowWindow(cast(hwnd, handle), SW_RESTORE)
    Sleep(500, 1)
    SetForegroundWindow(gameWindow)
    'restored window might not have focus
    If Not hasFocus() Then altTab()
  Elseif state = state_manager_enum.active And old = state_manager_enum.outoffocus Then
    'use alt+tab to get focus back
    altTab()
  End If
End Sub

Function state_manager_type.getState() As state_manager_enum
  if not gameWindow then screencontrol(FB.GET_WINDOW_HANDLE, cast(Integer, gameWindow))
  If isMinimized() Then
    Return state_manager_enum.minimized
  End If
  If Not hasFocus() Then Return state_manager_enum.outoffocus
  Return state_manager_enum.active
End Function

Sub state_manager_type.goAwayMouse()
  Setmouse(0, 0, 0)
End Sub

Sub state_manager_type.altTab()
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
End Sub

Function state_manager_type.isMinimized() As Integer
  Dim As WINDOWPLACEMENT wp
  wp.length = Sizeof(wp)
  GetWindowPlacement(gameWindow, @wp)
  Return wp.showCmd = SW_SHOWMINIMIZED
End Function

Function state_manager_type.hasFocus() As Integer
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

  Return Lcase(Inkey()) = "q"
End Function
