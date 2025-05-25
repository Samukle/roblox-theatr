---//   TheatR //---
-- TheatR.lua  --
--[[
	
	TODO@BASIC - Set up Remote through RemoteComm by listing functions
		Needs a "variable scope" thing? Shared table between
		functions that is used by client/server
	
	TODO@BASIC - Make Animation events happen through Happening RM Event
	
	TODO@OPTIM/FINISHME - Make useNativeClientScript insert Client.lua automatically
	
	
	# ]} WELCOME TheatR! {[
	
	TheatR compiles KeyframeSequence data into
	custom objects called AnimationSequence that
	save loading time for Animations.
	
	The code was made to save time and doesn't
	have much compatibility with other packages. (sorry :[)
	because i decided to not learn how to create
	roblox package repositories at the time 👍
	
	A few configurations are available in this
	script's Attributes.
	
	The comments utilize Nerd Font symbols.
	
	
	# ] External Version [
	
	To use the external module version, use:
	```
	require(ID_HERE)()
	```
	
	A table can be used as an argument and it sets
	the module's configurations.
	
	Example:
	```
	require(ID_HERE)
		{
			useNativeClientScript = true
		}
	```
	
	
	# ]| HOW DO I USE THIS THING? {[
	
	TheatR is an API and you'll be managing ani-
	mations through the master module (this one).
	
	
	
--]]

local const = require(script.constants)
local err   = require(script.err)
local types = require(script.types)


local Sequencer = require(script.Sequencer)
local RemoteComm = require(script.RemoteComm)

local TheatR = table.freeze {
	version = {value = "1.0", release = false} :: types.Version,
	
	-- Sequencer
	Sequencer  = Sequencer :: Sequencer.Sequencer,
	
	compile = Sequencer.new,
	isAnimationSequence = Sequencer.is,
	
	-- Remote communicator
	Remote = RemoteComm :: RemoteComm.RemoteComm,
	RemoteInit = RemoteComm.init
}

do -- Configurations
	
	local REPS = game:GetService("ReplicatedStorage")
	if const.ATT (script, 'useNativeClientScript') then
		
		local Path = Instance.new("ObjectValue")
            Path.Parent = REPS
		Path.Value = script
		Path.Name = 'TheatR_Path'
		
		local Client = script.Remote:WaitForChild('Client')
		
	end

	if const.ATT (script, 'bindRemotesOnRequire') then
		
		local scope = {}
		TheatR.RemoteInit(scope)
		
	end
end


export type TheatR = typeof(TheatR)
return TheatR :: TheatR