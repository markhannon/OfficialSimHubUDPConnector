import asyncio

from winrt.windows.media.control import \
    GlobalSystemMediaTransportControlsSessionManager as MediaManager

from datetime import datetime, timezone
import socket,json, time

## Sends a message to the SimhubUDPConnector plugin and the current date.
## Make sure to have a game running or the plugin will not be listening. 

UDP_IP = "127.0.0.1"
UDP_PORT = 20777

def sendUDPDatastream(data):
	sock.sendto(bytes(json.dumps(data), 'UTF-8'), (UDP_IP, UDP_PORT))

async def get_media_info(current_session):
    if current_session:  # there needs to be a media session running
        # if current_session.source_app_user_model_id == TARGET_ID:
        info = await current_session.try_get_media_properties_async()
        pbInfo = current_session.get_playback_info() 
        timeLineProps = current_session.get_timeline_properties()
        playbackStatus = pbInfo.playback_status
        if playbackStatus.name == 'PLAYING':
            current_time = datetime.now(timezone.utc)
            timeElapsedSinceUpdate = current_time - timeLineProps.last_updated_time
            timeElapsed = timeLineProps.position + timeElapsedSinceUpdate
        else :
            timeElapsed = timeLineProps.position 
        return {"artist":info.artist, "title":info.title, "status":playbackStatus.name, "position":str(timeElapsed), "updated":str(timeLineProps.last_updated_time)}
    else :
       return  "no session"
async def get_session():
    sessions = await MediaManager.request_async()
    current_session = sessions.get_current_session()
    # if current_session:
    #     current_session.add_timeline_properties_changed(callback_timeline_properties_changed)
    return current_session

def callback_timeline_properties_changed(handler, changed_properties):
    print(f"Properties changed: {changed_properties}")

if __name__ == '__main__':
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    current_session = asyncio.run(get_session())
    
    while(True):
        if not current_session :
            current_session = asyncio.run(get_session())
        infos =  asyncio.run(get_media_info(current_session))
        print(infos)
        sendUDPDatastream(infos)
        time.sleep(0.5)
        
    sock.close()
    