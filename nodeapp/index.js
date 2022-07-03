const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);
const { spawn } = require("child_process");


app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});


app.get('/no-sockets', (req, res) => {
  const comm = spawn('../kind-setup.sh', { detached: true});
  comm.unref()
  res.send('process started');

});

io.on('connection', async (socket) => {
  
  const comm = spawn('../kind-setup.sh');

  comm.stdout.on('data', (data) => {
    console.log(`${data}`);
    var enc = new TextDecoder("utf-8");
    io.sockets.emit('logs',{data:enc.decode(data)});
  });

  comm.stderr.on('data', (data) => {
    console.log(`${data}`);
    var enc = new TextDecoder("utf-8");
    io.sockets.emit('errorLogs',{data:enc.decode(data)});
  });

});


server.listen(3000, () => {
    console.log('listening on *:3000');
});
