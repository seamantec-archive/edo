/**
 * Created by pepusz on 15. 02. 10..
 */
package com.harbor {
import com.common.AppProperties;
import com.seamantec.LicenseManager;
import com.websocket.WebSocket;
import com.websocket.WebSocketErrorEvent;
import com.websocket.WebSocketEvent;
import com.websocket.WebSocketMessage;

import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

public class WebsocketHandler {

    private static var _instance:WebsocketHandler;
    private var websocket:WebSocket;

    public function WebsocketHandler() {
        websocket = new WebSocket(AppProperties.websocketEndpoint, LicenseManager.END_POINT_URI, ["permessage-deflate", "client_max_window_bits"])
        websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
        websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
        websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
        websocket.addEventListener(WebSocketEvent.PING, websocket_pingHandler);
        websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
        websocket.addEventListener(IOErrorEvent.IO_ERROR, handleConnectionFail);
        websocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleConnectionFail);
    }

    public function connect():void {
        if (CloudHandler.instance.token != null) {
            websocket.connect();
        }
    }

    public function disconnect(waitForServer:Boolean = true):void {
        websocket.close(waitForServer);
    }

    public static function get instance():WebsocketHandler {
        if (_instance == null) {
            _instance = new WebsocketHandler();
        }
        return _instance;
    }

    public function get connected():Boolean {
        return websocket.connected;
    }

    function handleWebSocketOpen(event:WebSocketEvent):void {
        trace("Connected");
        CloudHandler.instance.getPolars();
    }

    function handleWebSocketClosed(event:WebSocketEvent):void {
        trace("Disconnected");
        PolarFileHandler.instance.status = PolarFileHandler.STATUS_NOT_SYNCED;
    }

    private function handleConnectionFail(event:ErrorEvent):void {
        trace("Connection Failure: " + event.text);
        PolarFileHandler.instance.status = PolarFileHandler.STATUS_NOT_SYNCED;
    }

    function handleWebSocketMessage(event:WebSocketEvent):void {
        trace("Got message: " + event.message.utf8Data);
        if (CloudHandler.instance.userId == null || CloudHandler.instance.userId == "") {
            return;
        }
        if (event.message.type === WebSocketMessage.TYPE_UTF8) {
            var json:Object = JSON.parse(event.message.utf8Data);
            //            connectionId = json[0][1].data.connection_id;
            switch (json[0][0]) {
                case"client_connected":
                    websocket.sendUTF(createMessage("websocket_rails.subscribe", {channel: CloudHandler.instance.userId}))
                    break;
                case "websocket_rails.ping":
                    websocket.sendUTF(createMessage("websocket_rails.pong"));
                    break;
                case "new_polar":
                    CloudHandler.instance.getPolars();
                    break;
                case "deleted_polar":
                    CloudHandler.instance.getPolars();
                    break;

            }

            //#"{"name":"hello","id":7s1858,"data":{},"connection_id":"8536840c81f77910794d"}"
        }

    }


    private function createMessage(action:String, data:Object = null):String {
        var dataObject:Object = {}
        var a:Array = []
        a.push(action)
        dataObject["id"] = (((1 + Math.random()) * 0x10000) | 0);
        if (data != null) {
            dataObject["data"] = data;
        } else {
            dataObject["data"] = {};
        }
        a.push(dataObject);
        return JSON.stringify(a);
    }

    private function websocket_pingHandler(event:WebSocketEvent):void {
        trace("ping")
    }
}
}
