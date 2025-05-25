---// SEQUENCER //---
-- Sequencer.lua  --
--[[
	
	The Sequencer is reponsible for compiling KeyframeSequences
	into simple tables called AnimationSequence.
	
	OBJECTS
	 AnimationSequence
	
	CONSTANTS
	 int KF_TIME
	 int KF_WEIGHT
	 int KF_TRANSFORM

--]]

local Sequencer = {
	KF_TIME = -2,
	KF_WEIGHT = -1,
	KF_TRANSFORM = 0
}

local err   = require(script.Parent.err)
local const = require(script.Parent.constants)
local type  = require(script.Parent.types)


local Sequence = { } -- Metatable used for Sequences

do  --- Sequencing 
	
	-- Internal keyframe iterator function
	-- Returns Keyframe, Time, Poses 
	function Sequencer.ikeyframes ( instance: KeyframeSequence ) : ( ) -> (Keyframe, number, type.GetPoses)
		err.assertKeyframeSequence(instance)
		local children: { Keyframe } = instance:GetChildren()
		local child: Keyframe?
		local i = 1
		if #children <= 0 then return nil end
		child = children[i]
		return function ()
			while child do
				child = children[i]
				i += 1
				if not child:IsA(const.TYP_POSE) then continue end
				return child, child.Time, child:GetPoses()
			end
			return nil
		end
	end
	
	-- Keyframe Iterator function
	-- Returns Name, KeyframeJoint
	function Sequencer.keyframes ( sequence: type.Sequence ) : ( ) -> (string, type.KeyframeJoint)
		if #sequence <= 0 then return nil end
		local Joints = sequence.Joints
		local i = 1
		local joint = sequence [i]
		local name = ''
		return function ()
			while joint do
				for jointName, jointID in Joints do
					if jointID ~= i then continue end
					name = jointName
					break
				end
				joint = sequence [i]
				i += 1
				return name, joint
			end
			return nil
		end
	end
	
	-- Pose/SubPose iterator function
	-- Returns Pose, SubPoses
	function Sequencer.poses ( poses: type.GetPoses ) : ( ) -> (PoseBase, type.GetPoses)
		local child: PoseBase?
		local i = 1
		if #poses <= 0 then return nil end
		child = poses[i]
		return function ()
			while child do
				child = poses[i]
				i += 1
				return child, child.Name, child:GetSubPoses()
			end
			return nil
		end
	end
	
	-- Keyframe reader
	function keyframe ( sequence: type.Sequence, keyframe: Keyframe, time: number, poses_: type.GetPoses )
		if sequence.Length < time then
			sequence.Length = time
		end
		poses(sequence, time, poses_)
	end
	
	-- GetPoses/GetSubPoses list reader
	function poses ( sequence: type.Sequence, time: number, poses_: type.GetPoses )
		for pose_, jointName, subposes in Sequencer.poses(poses_) do
			if not pose_:FindFirstChild(const.KF_NULL) then
				pose(sequence, time, pose_, jointName)
			end
			poses(sequence, pose_, subposes)
		end
	end
	
	local components = (CFrame.identity :: CFrame).GetComponents
	local _jointPointer
	-- Pose/SubPose reader
	function pose ( sequence: type.Sequence, time: number, pose_: Pose, jointName: string )
		if not sequence.Joints [jointName] then
			sequence.Joints [jointName] = #sequence+1
			sequence [sequence.Joints [jointName]] = {}
		end
		_jointPointer = sequence [sequence.Joints [jointName]]
		_jointPointer [#_jointPointer] = {
			[Sequencer.KF_TIME] = time,
			[Sequencer.KF_WEIGHT] = pose_.Weight,
			[Sequencer.KF_TRANSFORM] = { components(pose_.CFrame) }
		} :: type.Keyframe
	end
	
	
	-- Creates a TheatR Sequence.
	function Sequencer.new ( instance: KeyframeSequence ) : type.Sequence
		
		err.assertKeyframeSequence(instance)
		
		local sequence: type.Sequence = {
			Joints = { } :: type.KeyframeJoints,
			Length = 0
		}
		
		for keyframe_, time, poses in Sequencer.keyframes(instance) do
			keyframe(sequence, keyframe_, time, poses)
		end

		-- Sort all keyframes by their time property
		--for name, keyframe in Sequencer.keyframes(sequence) do
		for name, keyframe in Sequencer.keyframes(sequence) do
			table.sort(keyframe, function(x, y)
				return x [Sequencer.KF_TIME] < y [Sequencer.KF_TIME]
			end)
		end
		
		setmetatable(sequence, Sequence)
		return sequence
		
	end
	
	function Sequencer.is ( obj: any ) : boolean
		return typeof(obj) == const.TYP_TABLE and getmetatable(obj) == Sequence
	end
	
end --- Sequencing


do --- Sequence Metatable
	
	local rawLength, rawJoints = "Length", "Joints"
	function Sequence.__index ( self, var )
		if rawget(self, rawJoints)[var] then
			return rawget(self, rawget(self, rawJoints)[var])
		end
		return Sequence [var]
	end
	
	
	function Sequence:is(...)
		return Sequencer.is(...)
	end
	
	function Sequence:Destroy()
		setmetatable(self, nil)
		table.clear(self)
		table.freeze(self)
	end
	
	
end --- Sequence Metatable

table.freeze(Sequencer)
export type Sequencer = typeof(Sequencer)
return Sequencer :: Sequencer