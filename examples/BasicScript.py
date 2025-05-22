from datetime import datetime
import socket,json

## Sends a message to the SimhubUDPConnector plugin and the current date.
## Make sure to have a game running or the plugin will not be listening. 

UDP_IP = "127.0.0.1"
UDP_PORT = 20777

def sendUDPDatastream(data):
	sock.sendto(bytes(json.dumps(data), 'UTF-8'), (UDP_IP, UDP_PORT))

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
data = {
		"message":"Hello from python",
		"time":datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
		}
sendUDPDatastream(data)
sock.close()