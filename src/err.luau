local err = { }
local const = require(script.Parent.constants)

local LIST = {
	"Object is %* and not an instance. Provided: %*",
	"Object is %* and not a KeyframeSequence. Provided: %*",
	"Object is %* and not a Keyframe. Provided: %*",
	"Object is %* and not a Pose. Provided: %*"
}

-- Throws Error 1 if argument isn't an Instance.
function err.assertInstance( instance: Keyframe )
	assert(typeof(instance) == const.TYP_INSTANCE, string.format(LIST[1], typeof(instance), instance))
end

-- 

-- Creates an Instance error function.
-- Should be provided with the ClassName to check and the Error string.
function err.assertInstanceDerived( type, err )
	-- Assert derived function
	return function( instance: Instance )
		err.assertInstance(instance);
		assert(instance:IsA(type), string.format(err, instance.ClassName, instance));
	end
end

err.assertKeyframeSequence = err.assertInstanceDerived(const.TYP_KFSEQ, LIST[2]);
err.assertKeyframe = err.assertInstanceDerived(const.TYP_KF, LIST[3]);
err.assertPose = err.assertInstanceDerived(const.TYP_POSE, LIST[4]);

return err