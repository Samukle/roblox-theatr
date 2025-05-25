---// THEATR CLIENT //---
-- Client.lua --

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TheatR = ReplicatedStorage:WaitForChild('TheatR_Path') :: ObjectValue

TheatR = require(TheatR.Value :: ModuleScript)

local scope = { }

TheatR.RemoteInit(scope)