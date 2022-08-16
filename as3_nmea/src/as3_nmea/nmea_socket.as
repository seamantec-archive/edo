package as3_nmea {

import flash.system.Security;
import flash.utils.*;
import flash.events.*;
import flash.net.Socket;
import flash.events.TimerEvent;


public class nmea_socket
{
	// soecket for connection
	private var socket:Socket;
	
	// periodic timer for update
	private var updateTimer:Timer;
	
	// periodic update interval in milliseconds
	private static var updateInterval:Number = 200;
	
	// nmea stuff
	private var packeter: nmea_packeter = new nmea_packeter();
	private var interpreter: nmea_interpreter = new nmea_interpreter();
	
	public function nmea_socket()
	{
		//Security.allowDomain("*");
		
		socket = new Socket();
		socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		socket.addEventListener(Event.CONNECT, onSocketConnected);
		socket.addEventListener(Event.CLOSE, onSocketClosed);
		socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketSecurityError);
		
		updateTimer = new Timer(updateInterval, 0);
		updateTimer.addEventListener("timer", onUpdateTimer);
	}
	
	public function onUpdateTimer(e:TimerEvent):void
	{
		sendText("u");
	}

	public function Connect(host:String = "localhost", port:Number = 3999):void
	{
		socket.connect(host, port);
	}

	private function onSocketConnected(e:Event):void
	{
		updateTimer.start();
		trace(updateTimer.running);
	}

	private function onSocketClosed(e:Event):void
	{
		updateTimer.stop();
	}

	private function onSocketData(e:ProgressEvent):void
	{
		var str:String = e.currentTarget.readUTFBytes(e.currentTarget.bytesAvailable);
		
		while (str.length > 0)
		{
			var packet_data: Array = packeter.readPacket(str);
			interpreter.interpret(packet_data[0]);
			str = packet_data[1];
		}
	}

	private function onSocketError(e:IOErrorEvent):void
	{
	}

	private function onSocketSecurityError(e:SecurityErrorEvent):void
	{
	}

	private function sendText(str:String):void
	{
		if (socket.connected)
		{
			socket.writeUTFBytes(str);
			socket.flush();
		}
	}
}

} // package sailing
