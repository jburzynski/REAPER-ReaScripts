--[[
 * ReaScript Name: Rename selected items active take from multiline clipboard content
 * Description: See title.
 * Screenshot: https://i.imgur.com/z66OJnG.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=166689
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-09-01)
  + Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console
sep = "\n" -- default sep
names_csv = "" -- default name

------------------------------------------------------- END OF USER CONFIG AREA

-- https://helloacm.com/split-a-string-in-lua/
function split(s, delimiter, preserve)
  local result = {}
  local i = 0
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    if preserve and i > 0 then
      table.insert(result, delimiter .. match)
    else
      table.insert(result, match)
    end
    i = i + 1
  end
  return result
end


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

  for i, item in ipairs(init_sel_items) do
    take = reaper.GetActiveTake(item)
    if take then
      name_out = names[i]
      if name_out then
        reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", name_out, true)
      else
        break
      end
    end
  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  if reaper.SNM_CreateFastString then

    fs = reaper.SNM_CreateFastString('')

    clipboard = reaper.CF_GetClipboardBig(fs)

  else
    clipboard = reaper.CF_GetClipboardBig('')
  end

  if clipboard ~= "" then
  
    names_csv = clipboard
  
    reaper.PreventUIRefresh(1)
  
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    init_sel_items =  {}
    SaveSelectedItems(init_sel_items)
    
    names = split(names_csv,sep)
  
    main()
  
    reaper.Undo_EndBlock("Rename selected items active take from multiline clipboard content", -1) -- End of the undo block. Leave it at the bottom of your main function.
  
    reaper.UpdateArrange()
  
    reaper.PreventUIRefresh(-1)
    
  end

  if reaper.SNM_DeleteFastString then
   reaper.SNM_DeleteFastString(fs)
  end
  
end
