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
                let data = event.data;
                try {
                    data = JSON.parse(event.data)
                } catch (e) { }
                console.log("message received", data);
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
