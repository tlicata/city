var city = {};

var drawCity = function () {
    console.log("is this thing on?");
};

city.websocket = (function () {
    var socket = null;

    var send = function (msg) {
        if (!socket) {
            socket = new WebSocket("ws://" + window.location.host +  window.location.pathname + "live");
            socket.onopen = function (event) {
                socket.send(msg);
            };
            socket.onclose = function (event) {
                socket = null;
            };
            socket.onmessage = function (event) {
                console.log("message received", event);
            };
        } else {
            socket.send(msg);
        }
    };

    return {
        send: send
    };
})();

drawCity();
