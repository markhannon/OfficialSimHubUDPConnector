# Collisions effect #
The collisions effect is a 4-corner ShakeIt effect.
It uses the realtime collision data from assetto corsa.
The profile requires the SimHubUDPConnector lua app with CollisionsExtension activated (activated by default) and the SimHubUDPConnector.dll SimHub plugin.
You can easily adjust two parameters, make sure to do it for all 4 corners in the javascript block (don't change the "run once" part above it!).
Here is the code for the front left corner : 
`if( 
	(getCollidedWith(150) != 'None') && 
	(isnull($prop('UDPConnectorDataPlugin.CollisionPositionX'),0)>-0.5) && 
	(isnull($prop('UDPConnectorDataPlugin.CollisionPositionZ'),0)>0.5) 
)
	return startVibrating( 100, 250, true);
return stopVibrating();`

In the second line you can play with the parameter of the function getCollidedWith(delay)
That's a delay to ensure we don't miss a collision, the default value is 150ms.
Line 6 you can tune the second parameter of the function startVibrating(intensity, duration, useSpeedRatio)
First parameter, intensity, is the max value we can reach, leave it at 100.
The parameter duration is the one you may want to tweak, it's the minimum duration of the vibration to make sure to feel it.
Default value is 250ms. The last parameter, useSpeedRatio take the speed of both collider into account. You should leave it as it is to avoid vibration when both collider are motionless.