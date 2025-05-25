local types = { }

-- Version readability for TheatR
export type Version = {value: number, release: boolean}


-- Sequencer
export type GetPoses = { PoseBase }

export type KeyframeJoints = { [string]: number }
export type Sequence = {
	[number]: Keyframe,
	
	Joints: KeyframeJoints,
	Length: number
}
export type AnimationSequence = Sequence
export type KeyframeJoint = { Keyframe }
export type Keyframe = { [number|number|number]: number|number|KeyframeTransform }
export type KeyframeTransform = { number }


return types