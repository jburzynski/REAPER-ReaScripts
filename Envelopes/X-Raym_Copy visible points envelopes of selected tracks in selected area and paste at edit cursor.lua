--[[
 * ReaScript Name: Copy points envelopes of selected tracks in time selection and paste at edit cursor
 * Description: A way to copy paste multiple points envelope from the same track. Preserve original time selected envelope area.
 * Instructions: Make a selection area. PLace the edit cursor somewhere. Execute the script.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.0
 * Version Date: 2015-03-17
 * REAPER: 5.0 pre 15
 * Extensions: SWS 2.6.3 #0
 --]]
 
--[[
 * Changelog:
 * v9.0 (2015-03-17)
	+ beta
 --]]

-- ----- DEBUGGING ====>
--NOT YES ABBLE TO CALL PTHER FOLDER FILE
--[[local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()]]
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	offset = reaper.GetCursorPosition()

	startLoop, endLoop = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
	lengthLoop = endLoop - startLoop

		-- LOOP TRHOUGH SELECTED TRACKS
		selected_tracks_count = reaper.CountSelectedTracks(0)
		for i = 0, selected_tracks_count-1  do
			
			-- GET THE TRACK
			track = reaper.GetSelectedTrack(0, i) -- Get selected track i

			-- LOOP THROUGH ENVELOPES
			env_count = reaper.CountTrackEnvelopes(track)
			for j = 0, env_count-1 do

				-- GET THE ENVELOPE
				env = reaper.GetTrackEnvelope(track, j)
				
				br_env = reaper.BR_EnvAlloc(env, 0)
				active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, test = reaper.BR_EnvGetProperties(br_env)


				-- IF VISIBLE
				if visible == true then

					env_points_count = reaper.CountEnvelopePoints(env)
					

					if env_points_count > 0 then

					retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, startLoop, 0, 0)
					retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, endLoop, 0, 0)
					
					shape = 0
					tension = 0

					-- ADD POINTS ON LOOP START AND END
					reaper.InsertEnvelopePoint(env, startLoop, valueOut, shape, tension, 1, true) -- INSERT startLoop point
					reaper.InsertEnvelopePoint(env, endLoop, valueOut2, shape, tension, 1, true) -- INSERT startLoop point
					-- LOOP THROUGH POINTS
						for k = 0, env_points_count+1 do 

							retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(env, k)

							--IF the point is in selection area and if there is an envelope point
							if time >= startLoop and time <= endLoop then
								
								point_time = time - startLoop + offset
								
								if point_time <= startLoop or point_time >= endLoop then
									reaper.InsertEnvelopePoint(env, point_time, valueOut, shape, tension, 1, true)
								end -- ENDIF point time would be paste in time selection

							end -- ENDIF in selected area

							-- SET LOOP START AND END POINT VALUE
							--[[retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, startLoop, 0, 0)
							retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, endLoop, 0, 0)
							
							-- ADD POINTS ON LOOP START AND END
							reaper.InsertEnvelopePoint(env, startLoop, valueOut, shape, tension, 1, true) -- INSERT startLoop point
							reaper.InsertEnvelopePoint(env, endLoop, valueOut2, shape, tension, 1, true) -- INSERT startLoop point
							--]]
							--[[reaper.InsertEnvelopePoint(env, offset, valueOut, shape, tension, 1, true) -- INSERT startLoop point

							if offset+lengthLoop <= startLoop or offset+lengthLoop >= endLoop then
									
								reaper.InsertEnvelopePoint(env, offset+lengthLoop, valueOut2, shape, tension, 1, true) -- INSERT startLoop point
							
							end -- ENDIF point time would be paste in time selection--]]
						
						end -- ENDIF points on the envelope

						reaper.Envelope_SortPoints(env)

					end -- ENDLOOP throught points
					
					reaper.BR_EnvFree(env, 1)
				
				end -- ENFIF visible
				
			end -- ENDLOOP through envelopes

		end -- ENDLOOP through selected tracks

		reaper.Undo_EndBlock("Copy points envelopes of selected tracks in time selection and paste at edit cursor", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SAVEVIEWS5"), 0) ]] -- Save view
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0 ]]-- Save loop
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SAVE_CURSOR_POS_SLOT_8"), 0) ]]--


main() -- Execute your main function

--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0) ]] -- Restore loop
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_RESTORE_CURSOR_POS_SLOT_8"), 0) ]]-- Restore current position
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_RESTIREVIEWS5"), 0) ]] -- Restore view
--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
