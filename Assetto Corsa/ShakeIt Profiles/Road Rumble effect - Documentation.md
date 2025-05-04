# Road Rumble effect #
The Road Rumble effect is a 4-corner ShakeIt effect.
It uses the realtime surface type and vibration by wheel data from assetto corsa.
The profile requires the SimHubUDPConnector lua app with RoadRumbleExtension activated (activated by default) and the SimHubUDPConnector.dll SimHub plugin.
## Frequencies ##
> [!NOTE]
> The new version of the effect enables dynamic frequencies the range is 20hz to 120Hz and the default value is 26Hz (when no data is available to calculate the dynamic frequency).  
In the frequency function you can change the default value from 26 to whatever you prefer :
`getFrequency(26, $prop('UDPConnectorDataPlugin.WheelFLSurfaceVibrationLength'), $prop('UDPConnectorDataPlugin.WheelFLAngularSpeed'), $prop('UDPConnectorDataPlugin.WheelFLRimRadius'));`
The Min and Max values are in the run once block at the top : 
`MIN_FREQUENCY = 20;
MAX_FREQUENCY = 120;`  
It's a group of effects, that includes one effect per surface type so make sure to adjust the effect for each surface type (intensity, frequencies...) to get the best result for your setup.