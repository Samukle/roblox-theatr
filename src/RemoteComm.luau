---// REMOTE COMMUNICATOR //---
-- RemoteComm.lua --
--[[

	List the functions adopted by the remotes
	and doubles as their util.

	CONSTANTS
	 bool CLIENTSIDE
	 string KEY_SERVER
	 string KEY_CLIENT
	 string FORMAT_ON_EVENT
	 string FORMAT_ON_FUNCT
	 array(string) REMOTE_INDEX
	 array(int) REMOTE_TYPES
	 int TYPE_EVENT
	 int TYPE_FUNCTION
--]]
local task = nil -- no task scheduler >:[

local err   = require(script.Parent.err)
local const = require(script.Parent.constants)
local type  = require(script.Parent.types)

local CLIENTSIDE = game:GetService('Players').LocalPlayer ~= nil

local KEY_SERVER = "Server"
local KEY_CLIENT = "Client"
local FORMAT_ON_EVENT = "On%sEvent"
local FORMAT_ON_FUNCT = "On%sInvoke"
local REMOTE_NAMES = { "Allocator", "Controller", "Happening" }
local REMOTE_TYPES = { 1, 0, 0 }
local REMOTE_UNRELIABLE = { false, true, false }
local TYPE_EVENT = 0
local TYPE_FUNCTION = 1

local Folder = script.Parent.Remote
local Binds = Folder.Binds
do
	local WARNING_NOT_LOADED = "TheatR: Remote %* didn't load"
	local i
	local inst
	for _, Script in next, Binds:GetChildren() do
		i = nil
		for j, slot in next, REMOTE_NAMES do
			if slot ~= Script.Name then continue end
			i = j
			break
		end
		if not i then
			warn(string.format(WARNING_NOT_LOADED, Script))
			continue
		end

		if REMOTE_TYPES [i] == 0 then
			if REMOTE_UNRELIABLE [i] then
				inst = Instance.new("UnreliableRemoteEvent")
			else
				inst = Instance.new("RemoteEvent")
			end
		else
			inst = Instance.new("RemoteFunction")
		end
		inst.Name = REMOTE_NAMES [i]
		inst.Parent = Binds
	end
end

local Remotes = {
	CLIENTSIDE = CLIENTSIDE,
	KEY_SERVER = KEY_SERVER,
	KEY_CLIENT = KEY_CLIENT,
	FORMAT_ON_EVENT = FORMAT_ON_EVENT,
	FORMAT_ON_FUNCT = FORMAT_ON_FUNCT,
	REMOTE_NAMES = REMOTE_NAMES,
	REMOTE_TYPES = REMOTE_TYPES,
	TYPE_EVENT = TYPE_EVENT,
	TYPE_FUNCTION = TYPE_FUNCTION,
	
	-- Manipulates animation memory
	Allocator = {
		Instance = Folder.Allocator,
		Server = require(Binds.Allocator).Server,
		Client = require(Binds.Allocator).Client
	},
	
	-- Controls animation properties and playability
	Controller = {
		Instance = Folder.Controller,
		Server = require(Binds.Controller).Server,
		Client = require(Binds.Controller).Client
	},
	
	-- Handles animation events
	Happening = {
		Instance = Folder.Happening,
		Server = require(Binds.Happening).Server,
		Client = require(Binds.Happening).Client
	}
}

do -- Main body
	
	-- Sets up the Remote Communication through current replication side
	-- e.g.: Calling it from a LocalScript will bind the Client-side remotes.
	-- |
	-- Returns a table containing all the connections made separated by instance.
	function Remotes.init ( scope : { any }, exceptions: { string: {[any]: boolean} } )
		local key = if CLIENTSIDE then Remotes.KEY_CLIENT else Remotes.KEY_SERVER
		local current
		local connectionList = { }
		for id, remote in next, Remotes.REMOTE_NAMES do
			connectionList [remote] = { }
			current = Remotes [remote]
			if Remotes.REMOTE_TYPES [id] == Remotes.TYPE_FUNCTION then
				current.Instance [string.format(Remotes.FORMAT_ON_FUNCT, key)] = current [key] [1] (scope)
				break
			end
			for id, funct in current [key] do
				if exceptions and exceptions [remote] [id] then return end
				connectionList [remote] [id] =
					current.Instance [string.format(Remotes.FORMAT_ON_EVENT, key)]:Connect(funct(scope))
			end
		end
		current = nil
		key = nil
		return connectionList
	end
	
end -- Main body

table.freeze(Remotes)
export type RemoteComm = typeof(Remotes)
return Remotes