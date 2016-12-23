-- My Config

import XMonad

import XMonad.Util.EZConfig
import XMonad.Util.Run

import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ICCCMFocus

-- import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
-- import XMonad.Layout.Grid

myModMask  = mod4Mask -- Use Super instead of Alt
myTerminal = "xfce4-terminal"

{-
  Xmobar configuration variables. These settings control the appearance
  of text which xmonad is sending to xmobar via the DynamicLog hook.
-}

myTitleColor     = "#eeeeee"  -- color of window title
myTitleLength    = 120        -- truncate window title to this length
myCurrentWSColor = "#e6744c"  -- color of active workspace
myVisibleWSColor = "#c185a7"  -- color of inactive workspace
myUrgentWSColor  = "#cc0000"  -- color of workspace with 'urgent' window
myCurrentWSLeft  = "["        -- wrap active workspace with these
myCurrentWSRight = "]"
myVisibleWSLeft  = "("        -- wrap inactive workspace with these
myVisibleWSRight = ")"
myUrgentWSLeft  = "{"         -- wrap urgent workspace with these
myUrgentWSRight = "}"

{-
  Special Keys
-}

myKeyBindings =
  [
      ((myModMask, xK_x), spawn "light-locker-command -l")            -- lock screen with light-locker
    -- ((myModMask, xK_b), sendMessage ToggleStruts)
    -- , ((myModMask, xK_a), sendMessage MirrorShrink)
    -- , ((myModMask, xK_z), sendMessage MirrorExpand)
    -- , ((myModMask, xK_p), spawn "synapse")
    -- , ((myModMask .|. mod1Mask, xK_space), spawn "synapse")
    -- , ((myModMask, xK_u), focusUrgent)
    , ((0, 0x1008FF12), spawn "amixer -D pulse set Master 1+ toggle") -- mute/unmute
    , ((0, 0x1008FF11), spawn "amixer -q set Master 3%-")             -- volume down
    , ((0, 0x1008FF13), spawn "amixer -q set Master 3%+")             -- volume up
  ]

{-
  My custom layout

  avoid broders in fullscreen layout
  avoidStruts instructs xmonad to not cover cover up any docks, status bars
-}

myLayouts = smartBorders(avoidStruts(
      ResizableTall 1 (3/100) (1/2) []
  ||| Mirror (ResizableTall 1 (3/100) (1/2) [])
  ||| noBorders Full))

{-
  Here we actually stitch together all the configuration settings
  and run xmonad. We also spawn an instance of xmobar and pipe
  content into it via the logHook.
-}

main = do
  -- reduce tearing
  spawn "compton --backend glx --vsync opengl &"
  -- status bar
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc"
  -- lock screen
  spawn "light-locker &"
  -- shift screen color temperature
  spawn "redshift &"

  xmonad $ defaultConfig {
    modMask = myModMask
  , terminal = myTerminal
  -- >> leave a gap for the statusbar
  , manageHook      = manageDocks    <+> manageHook      defaultConfig -- do not focus on docks
  , handleEventHook = docksEventHook <+> handleEventHook defaultConfig -- whenever a new dock appears, refresh the layout
  , layoutHook      = myLayouts
  -- <<
  , logHook = takeTopFocus <+> dynamicLogWithPP xmobarPP {
        ppOutput = hPutStrLn xmproc
        , ppTitle = xmobarColor myTitleColor "" . shorten myTitleLength
        , ppCurrent = xmobarColor myCurrentWSColor ""
          . wrap myCurrentWSLeft myCurrentWSRight
        , ppVisible = xmobarColor myVisibleWSColor ""
          . wrap myVisibleWSLeft myVisibleWSRight
        , ppUrgent = xmobarColor myUrgentWSColor ""
          . wrap myUrgentWSLeft myUrgentWSRight
      }
  }
    `additionalKeys` myKeyBindings
