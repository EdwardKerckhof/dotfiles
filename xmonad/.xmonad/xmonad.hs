------------------------------------------------------------------------
-- Imports
-- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

-- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

-- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.NamedScratchpad
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

------------------------------------------------------------------------
-- Variables

myFont :: String
myFont = "xft:JetBrainsMono Nerd Font:regular:size=11:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "kitty"

myBrowser :: String
myBrowser = "brave"

myMusicPlayer :: String
myMusicPlayer = "LD_PRELOAD=/home/edward/.config/spotifywm/spotifywm.so /usr/share/spotify"

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' "

myEditor :: String
myEditor = myTerminal ++ " nvim"
--myEditor = "code"

myFileManager :: String
myFileManager = "thunar"

mySocialApp :: String
mySocialApp = "discord"

myMailApp :: String
myMailApp = "mailspring"

myNoteTakingApp :: String
myNoteTakingApp = myTerminal ++ " --title notetaker /home/edward/.local/bin/notetaker"

myGamingApp :: String
myGamingApp = "lutris"

myBorderWidth :: Dimension
myBorderWidth = 2

myNormalBorderColor :: String
myNormalBorderColor = "#3B294A"

myFocusedBorderColor :: String
myFocusedBorderColor = "#82AAFF"


windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses :: Bool
myClickJustFocuses = False

------------------------------------------------------------------------
-- Startup hook

myStartupHook :: X ()
myStartupHook = do
  spawn "killall trayer"

  spawnOnce "lxsession"
  spawnOnce "picom --experimental-backends --backend glx --xrender-sync-fence"
  spawnOnce "nm-applet"
  spawnOnce "volumeicon"
  spawnOnce "blueman-adapters"
  spawnOnce "dunst"
  spawn ("sleep 1 && trayer --edge top --margin 16 --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --tint 0x000000 --transparent true --alpha 150 --height 22 --distance 11")
  spawnOnce "xinput set-button-map 'Logitech M705' 1 2 3 5 4 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"
  spawnOnce "xinput set-prop 'Logitech M705' 291 1"
  spawnOnce "dwall -s style &"
  spawnOnce "mailspring"
  spawnOnce "discord"
  spawnOnce "brave"
  setWMName "LG3D"

------------------------------------------------------------------------
-- Scratchpads

myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "notes" spawnNotes findNotes manageNotes ]
  where
    spawnNotes = myNoteTakingApp 
    findNotes = title =? "notetaker"
    manageNotes = customFloating $ W.RationalRect l t w h
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
      inactiveBorderColor = "#1a1b26",
      activeTextColor = "#1a1b26",
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
myWorkspaces = [" www ", " dev ", " chat ", " mus ", " mail ", " work ", " game ", " sys ", " note "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

------------------------------------------------------------------------
-- Window rules

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook =
  composeAll
    -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
    -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
    [
      className =? "confirm"                        --> doFloat
     , className =? "file_progress"                 --> doFloat
     , className =? "dialog"                        --> doFloat
     , className =? "download"                      --> doFloat
     , className =? "error"                         --> doFloat
     , className =? "notification"                  --> doFloat
     , className =? "pinentry-gtk-2"                --> doFloat
     , className =? "splash"                        --> doFloat
     , className =? "toolbar"                       --> doFloat
     , title =? "Oracle VM VirtualBox Manager"      --> doFloat
     , className =? "Code"                          --> doShift ( myWorkspaces !! 1 )
     , className =? "Code - Insiders"               --> doShift ( myWorkspaces !! 1 )
     , className =? "kate"                          --> doShift ( myWorkspaces !! 1 )
     , className =? "discord"                       --> doShift ( myWorkspaces !! 2 )
     , title =? "Messenger call - Brave"            --> doShift ( myWorkspaces !! 2 )
     , className =? "Spotify"                       --> doShift ( myWorkspaces !! 3 )
     , className =? "spotify"                       --> doShift ( myWorkspaces !! 3 )
     , title =? "Spotify"                           --> doShift ( myWorkspaces !! 3 )
     , title =? "spotify"                           --> doShift ( myWorkspaces !! 3 )
     , className =? "Mailspring"                    --> doShift ( myWorkspaces !! 4 )
     , className =? "Lutris"                        --> doShift ( myWorkspaces !! 6 )
     , className =? "net-runelite-launcher-Launcher"--> doShift ( myWorkspaces !! 6 )
     , className =? "Virt-manager"                  --> doShift ( myWorkspaces !! 7 )
     , className =? "qBittorrent"                   --> doShift ( myWorkspaces !! 7 )
     , className =? "obsidian"                      --> doShift ( myWorkspaces !! 8 )
     , isFullscreen --> doFullFloat
    ]
    <+> namedScratchpadManageHook myScratchPads


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
    ("M-<Space>", spawn "rofi -show run -lines 3 -eh 2 -width 100 -padding 800 -bw 0 -separator-style none -hide-scrollbar true -color-window '#e62f343f' -color-normal '#002f343f,#ffffff,#002f343f,#002f343f,#1A2746' -font 'System San Francisco Display 18'"),
    -- KB_GROUP Useful programs to have a keybinding for launch
    ("M-t", spawn (myTerminal)),
    ("M-b", spawn (myBrowser)),
    ("M-s", spawn (myMusicPlayer)),
    ("M-c", spawn (myEditor)),
    ("M-d", spawn (mySocialApp)),
    ("M-e", spawn (myMailApp)),
    ("M-n", namedScratchpadAction myScratchPads "notes"),
    ("M-S-n", spawn (myTerminal ++ " most-recent-note")),
    ("M-f", spawn (myFileManager)),
    ("M-g", spawn (myGamingApp)),
    ("M-r", spawn "/opt/RuneLite.AppImage"),
    ("M-v", spawn "virt-manager"),
    ("M-S-s", spawn "~/.local/bin/screenshot"),
    ("M1-<Space>", spawn "dunstctl history-pop"),
    ("M-S-e", spawn "dm-confedit"),
    ("M-S-c", spawn ("colorpicker --short --one-shot | xclip -selection clipboard")),
    ("M-S-a", spawn "dm-hub"),
    ("M-S-k", spawn "dm-kill"),
    ("M-<Delete>", spawn "dm-logout"),
    -- Kill windows
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
    ("M-S-h", windows W.swapMaster), -- Swap the focused window and the master window
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
    ("M1-S-h", sendMessage Shrink),
    ("M1-S-l", sendMessage Expand),
    ("M1-S-k", sendMessage MirrorShrink),
    ("M1-S-k", sendMessage MirrorExpand),
    -- KB_GROUP Scratchpads
    -- KB_GROUP Multimedia Keys
    ("<XF86AudioPlay>", spawn "~/.local/bin/changevolume playpause"),
    ("<XF86AudioPrev>", spawn "~/.local/bin/changevolume previous"),
    ("<XF86AudioNext>", spawn "~/.local/bin/changevolume next"),
    ("<XF86AudioMute>", spawn "~/.local/bin/changevolume mute"),
    ("<XF86AudioLowerVolume>", spawn "~/.local/bin/changevolume down"),
    ("<XF86AudioRaiseVolume>", spawn "~/.local/bin/changevolume up")
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
                    ppCurrent = xmobarColor "#82AAFF" "" . wrap "<box type=Bottom width=2 mb=0 color=#82AAFF>" "</box>", -- Current workspace
                    ppVisible = xmobarColor "#82AAFF" "" . clickable, -- Visible but not current workspace
                    ppHidden = xmobarColor "#82AAFF" "" . clickable, -- Hidden workspaces
                    ppHiddenNoWindows = xmobarColor "#b3afc2" "" . clickable, -- Hidden workspaces (no windows)
                    ppTitle = xmobarColor "#b3afc2" "" . shorten 60, -- Title of active window
                    ppSep = "<fc=#666666> <fn=1>|</fn> </fc>", -- Separator character
                    ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!", -- Urgent workspace
                    ppExtras = [windowCount], -- # of windows current workspace
                    ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t] -- order of things in xmobar
                  }
        }
      `additionalKeysP` myKeys
