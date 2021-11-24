------------------------------------------------------------------------
-- Data
import Data.Char
import qualified Data.Map as M
import Data.Maybe
import Data.Monoid
import Data.Tree
import System.Directory
import System.Exit
import System.IO
import XMonad
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves
import qualified XMonad.Actions.Search as S
import XMonad.Actions.WindowGo
import XMonad.Actions.WithAll
-- Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
-- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants
-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle
import qualified XMonad.Layout.MultiToggle as MT
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import qualified XMonad.Layout.ToggleLayouts as T
import XMonad.Layout.WindowArranger
import XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet as W
-- Utilities
import XMonad.Config.Azerty
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

------------------------------------------------------------------------
-- Variables

myFont :: String
myFont = "xft:Fira Code:regular:size=10:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "brave"

myMusicPlayer :: String
myMusicPlayer = "spotify"

myEditor :: String
myEditor = myTerminal ++ " -e lvim"
--myEditor = "code"

myFileManager :: String
myFileManager = "pcmanfm"

mySocialApp :: String
mySocialApp = "discord"

myMailApp :: String
myMailApp = "thunderbird"

myBorderWidth :: Dimension
myBorderWidth = 2

myNormalBorderColor :: String
myNormalBorderColor = "#282c34"

myFocusedBorderColor :: String
myFocusedBorderColor = "#46d9ff"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses :: Bool
myClickJustFocuses = False

------------------------------------------------------------------------
-- Scratchpads

myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "terminal" spawnTerm findTerm manageTerm,
    NS "calculator" spawnCalc findCalc manageCalc
  ]
  where
    spawnTerm = myTerminal ++ " -t scratchpad"
    findTerm = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnCalc = "qalculate-gtk"
    findCalc = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
      where
        h = 0.5
        w = 0.4
        t = 0.75 - h
        l = 0.70 - w

------------------------------------------------------------------------
-- Layouts

-- Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.

mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

tall =
  renamed [Replace "tall"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                ResizableTall 1 (3 / 100) (1 / 2) []

floats =
  renamed [Replace "floats"] $
    smartBorders $
      limitWindows 20 simplestFloat

grid =
  renamed [Replace "grid"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                mkToggle (single MIRROR) $
                  Grid (16 / 10)

-- Setting colors for tabs layout and tabs sublayout.
myTabTheme =
  def
    { fontName = myFont,
      activeColor = "#46d9ff",
      inactiveColor = "#313846",
      activeBorderColor = "#46d9ff",
      inactiveBorderColor = "#282c34",
      activeTextColor = "#282c34",
      inactiveTextColor = "#d0d0d0"
    }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme =
  def
    { swn_font = "xft:Ubuntu:bold:size=60",
      swn_fade = 1.0,
      swn_bgcolor = "#1c1f24",
      swn_color = "#ffffff"
    }

-- The layout hook
myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        T.toggleLayouts floats $
          mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      withBorder myBorderWidth tall
        ||| floats
        ||| grid

------------------------------------------------------------------------
-- Workspaces

myWorkspaces :: [String]
myWorkspaces = [" www ", " dev ", " chat ", " mus ", " mail ", " web ", " game ", " sys ", " vid "]

------------------------------------------------------------------------
-- Window rules

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook =
  composeAll
    -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
    -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
    -- I'm doing it this way because otherwise I would have to write out the full
    -- name of my workspaces and the names would be very long if using clickable workspaces.
    [
      className =? "confirm"                       --> doFloat
     , className =? "file_progress"                 --> doFloat
     , className =? "dialog"                        --> doFloat
     , className =? "download"                      --> doFloat
     , className =? "error"                         --> doFloat
     , className =? "notification"                  --> doFloat
     , className =? "pinentry-gtk-2"                --> doFloat
     , className =? "splash"                        --> doFloat
     , className =? "toolbar"                       --> doFloat
     , title =? "Oracle VM VirtualBox Manager"      --> doFloat
     , className =? "firefox"                       --> doShift ( myWorkspaces !! 0 )
     , className =? "qute"                   --> doShift ( myWorkspaces !! 0 )
     , className =? "Chromium"                      --> doShift ( myWorkspaces !! 0 )
     , className =? "Firefox Developer Edition"     --> doShift ( myWorkspaces !! 0 )
     , className =? "Brave-browser"                 --> doShift ( myWorkspaces !! 0 )
     , className =? "Code"                          --> doShift ( myWorkspaces !! 1 )
     , className =? "Code - Insiders"               --> doShift ( myWorkspaces !! 1 )
     , className =? "kate"                          --> doShift ( myWorkspaces !! 1 )
     , className =? "Godot"                         --> doShift ( myWorkspaces !! 1 )
     , className =? "GitHub Desktop"                --> doShift ( myWorkspaces !! 1 )
     , className =? "discord"                       --> doShift ( myWorkspaces !! 2 )
     , title =? "Messenger call - Brave"            --> doShift ( myWorkspaces !! 2 )
     , className =? "Thunderbird" --> doShift (myWorkspaces !! 4)
     , isFullscreen --> doFullFloat
    ]
    <+> namedScratchpadManageHook myScratchPads

------------------------------------------------------------------------
-- Startup hook

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "compton &"
  spawnOnce "nm-applet &"
  spawnOnce "volumeicon &"
  spawnOnce "nitrogen --restore &"
  spawnOnce "conky -c /home/edward/.config/conky/xmonad.conkyrc"
  spawnOnce "blueman-adapters &"
  spawnOnce "xrandr --output DP-2 --mode 1920x1080 --rate 144  --output HDMI-0 --mode 1920x1080 --rate 60 --left-of DP-2 &"
  spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34  --height 22 &"
  setWMName "LG3D"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.

-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
  -- KB_GROUP Xmonad
  [ ("M-C-r", spawn "xmonad --recompile"), -- Recompiles xmonad
    ("M-S-r", spawn "xmonad --restart"), -- Restarts xmonad
    ("M-S-q", io exitSuccess), -- Quits xmonad
    -- KB_GROUP Run Prompt
    ("M-<Space>", spawn "rofi -show run -lines 3 -eh 2 -width 100 -padding 800 -bw 0 -separator-style none -hide-scrollbar true -color-window '#e62f343f' -color-normal '#002f343f,#ffffff,#002f343f,#002f343f,#9575cd' -font 'System San Francisco Display 18'"),
    -- KB_GROUP Useful programs to have a keybinding for launch
    ("M-t", spawn (myTerminal)),
    ("M-b", spawn (myBrowser)),
    ("M-s", spawn (myMusicPlayer)),
    ("M-c", spawn (myEditor)),
    ("M-d", spawn (mySocialApp)),
    ("M-e", spawn (myMailApp)),
    ("M-f", spawn (myFileManager)),
    ("M-v", spawn "virt-manager"),
    ("M-r", spawn "runelite"),
    ("M-i", spawn (myTerminal ++ " -e ~/dotfiles/cht.sh")),
    ("M-S-s", spawn "~/bash_scripts/dm-scrot.sh"),
    ("M-S-c", spawn "dm-confedit"),
    ("M-S-h", spawn "dm-hub"),
    ("M-S-k", spawn "dm-kill"),
    ("M-<Delete>", spawn "dm-logout"),
    -- KB_GROUP Kill windows
    ("M-q", kill),
    -- KB_GROUP Workspaces
    ("M-.", nextScreen), -- Switch focus to next monitor
    ("M-,", prevScreen), -- Switch focus to prev monitor
    ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP), -- Shifts focused window to next ws
    ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP), -- Shifts focused window to prev ws

    -- KB_GROUP Floating windows
    ("M-S-f", sendMessage (T.Toggle "floats")), -- Toggles my 'floats' layout
    ("M-S-t", withFocused $ windows . W.sink), -- Push floating window back to tile

    -- KB_GROUP Windows navigation
    ("M-p", windows W.focusMaster), -- Move focus to the master window
    ("M-l", windows W.focusDown), -- Move focus to the next window
    ("M-h", windows W.focusUp), -- Move focus to the prev window
    ("M-S-m", windows W.swapMaster), -- Swap the focused window and the master window
    ("M-S-l", windows W.swapDown), -- Swap focused window with next window
    ("M-<Backspace>", promote), -- Moves focused window to master, others maintain order
    ("M-S-<Tab>", rotSlavesDown), -- Rotate all windows except master and keep focus in place
    ("M-C-<Tab>", rotAllDown), -- Rotate all the windows in the current stack

    -- Move the focus to next screen (multi screen)
    ("M-<Tab>", nextScreen),

    -- KB_GROUP Layouts
    ("M-o", sendMessage NextLayout), -- Switch to next layout
    ("M-m", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts), -- Toggles noborder/full

    -- KB_GROUP Window resizing
    ("M-C-h", sendMessage Shrink),
    ("M-C-l", sendMessage Expand),
    ("M-C-k", sendMessage MirrorShrink),
    ("M-C-k", sendMessage MirrorExpand),
    -- KB_GROUP Scratchpads
    ("M-p t", namedScratchpadAction myScratchPads "terminal"),
    ("M-p c", namedScratchpadAction myScratchPads "calculator"),
    -- KB_GROUP Multimedia Keys
    ("<XF86AudioPlay>", spawn "playerctl play-pause"),
    ("<XF86AudioPrev>", spawn "playerctl previous"),
    ("<XF86AudioNext>", spawn "playerctl next"),
    ("<XF86AudioMute>", spawn "amixer set Master toggle"),
    ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
  ]


  where
    -- The following lines are needed for named scratchpads.
    nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
    nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

-- END_KEYS

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

main :: IO ()
main = do
  -- Launching three instances of xmobar on their monitors.
  xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
  xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
  xmonad $
    ewmh
      def
        {
          keys = belgianKeys <+> keys belgianConfig,
          -- simple stuff
          terminal           = myTerminal,
          focusFollowsMouse  = myFocusFollowsMouse,
          clickJustFocuses   = myClickJustFocuses,
          borderWidth        = myBorderWidth,
          modMask            = myModMask,
          workspaces         = myWorkspaces,
          normalBorderColor  = myNormalBorderColor,
          focusedBorderColor = myFocusedBorderColor,

          -- hooks, layouts
          layoutHook         = showWName' myShowWNameTheme $ myLayoutHook,
          manageHook         = myManageHook <+> manageDocks,
          handleEventHook    = docksEventHook,
          startupHook        = myStartupHook,
          logHook =
            dynamicLogWithPP $
              namedScratchpadFilterOutWorkspacePP $
                xmobarPP
                  { -- the following variables beginning with 'pp' are settings for xmobar.
                    ppOutput = \x ->
                      hPutStrLn xmproc0 x -- xmobar on monitor 1
                        >> hPutStrLn xmproc1 x, -- xmobar on monitor 2
                    ppCurrent = xmobarColor "#c792ea" "" . wrap "<box type=Bottom width=2 mb=2 color=#c792ea>" "</box>", -- Current workspace
                    ppVisible = xmobarColor "#c792ea" "", -- Visible but not current workspace
                    ppHidden = xmobarColor "#82AAFF" "" . wrap "<box type=Top width=2 mt=2 color=#82AAFF>" "</box>", -- Hidden workspaces
                    ppHiddenNoWindows = xmobarColor "#82AAFF" "", -- Hidden workspaces (no windows)
                    ppTitle = xmobarColor "#b3afc2" "" . shorten 60, -- Title of active window
                    ppSep = "<fc=#666666> <fn=1>|</fn> </fc>", -- Separator character
                    ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!", -- Urgent workspace
                    ppExtras = [windowCount], -- # of windows current workspace
                    ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t] -- order of things in xmobar
                  }
        }
      `additionalKeysP` myKeys
