const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);
const { spawnSync } = require("child_process");
const CSVToJSON = require('csvtojson');
const path = require('path');
const fs = require('fs');

app.use(express.json({
    inflate: true,
    limit: '100kb',
    reviver: null,
    strict: true,
    type: 'application/json',
    verify: undefined
}))

app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});

function format (req){
  var response= [];
  if (req.body.memorySize != undefined){
    if (typeof req.body.memorySize === 'object'){
      response.push({
          varName: "memorySize",
          length: req.body.memorySize.length,
          value: req.body.memorySize
        });
    } else response.push({varName: "memorySize", "value": req.body.memorySize});
  }
  if (req.body.maxMemory != undefined){
    if (typeof req.body.maxMemory === 'object'){
      response.push({
          varName: "maxMemory",
          length: req.body.maxMemory.length,
          value: req.body.maxMemory
      })
    } else response.push({varName: "maxMemory", "value": req.body.maxMemory});
  }
  if (req.body.userMemory != undefined){
    if (typeof req.body.userMemory === 'object'){
      response.push({
          varName: "userMemory",
          length: req.body.userMemory.length,
          value: req.body.userMemory
      });
    } else response.push({varName: "userMemory", "value": req.body.userMemory});
  }
  if (req.body.minMemory != undefined){
    if (typeof req.body.minMemory === 'object'){
      response.push({
        varName: "minMemory",
        length: req.body.minMemory.length,
        value: req.body.minMemory
      });
    } else response.push({varName: "minMemory", "value": req.body.minMemory});
  }
  return response;
}
var comm;
function spawnArgs (input,inputLength,detachedV){
  let argsArr=[];
  let flag=true;
  for(let element=0;element<input.length;element++) {
    if(input[element].length === undefined){
      argsArr.push(input[element]);
    } else {
      for(let i=0;i<input[element].length;i++){
        flag=false;
        argsArr.push({"varName":input[element].varName,"value":input[element].value[i]});
        for( let j=element+1;j<input.length;j++){
          argsArr.push(input[j]);
        }
        spawnArgs(argsArr,inputLength,detachedV);
          for(let j=input.length;j>element;j--){
            argsArr.pop();
          }
      }
    }
  }
  if(input.length == inputLength && flag){
    let arguments=[];
    input.forEach(value => {
      arguments.push(value.varName+"="+value.value);
    });
    console.log(arguments);
    comm = spawnSync('/home/user/test-loadgen.sh',arguments,{detached:false});
  }
}

app.get('/no-sockets', (req, res) => {

  const formatted = format(req);
  spawnArgs(formatted,formatted.length,false)
  var results=[];
  const directoryPath = path.join(__dirname, '../octave-results');
  fs.readdir(directoryPath, async function (err, files) {
    if (err) {
      return console.log('Unable to scan directory: ' + err);
    } 
    for (const file in files) {
      const fn = files[file];
       await CSVToJSON().fromFile(directoryPath+"/"+fn)
        .then(values => {
          results.push({
            dataPair:fn.slice(0,fn.length-4),
            value:values
          });
          console.log(results);
        }).catch(err => {
          console.log(err);
        });
    };
    res.send(results);
  });

});


app.get('/results', (req, res) => {
  //https://medium.com/stackfame/get-list-of-all-files-in-a-directory-in-node-js-befd31677ec5
  var results=[];
  const directoryPath = path.join(__dirname, '../octave-results');
  fs.readdir(directoryPath, async function (err, files) {
    if (err) {
      return console.log('Unable to scan directory: ' + err);
    } 
    for (const file in files) {
      const fn = files[file];
       await CSVToJSON().fromFile(directoryPath+"/"+fn)
        .then(values => {
          results.push({
            dataPair:fn.slice(0,fn.length-4),
            value:values
          });
          console.log(results);
        }).catch(err => {
          console.log(err);
        });
    };
    res.send(results);
  });
});

io.on('connection', async (socket) => {
  
  if(comm !== undefined){
    comm.stdout.on('data', (data) => {
      var enc = new TextDecoder("utf-8");
      io.sockets.emit('logs',{data:enc.decode(data)});
    });

    comm.stderr.on('data', (data) => {
      var enc = new TextDecoder("utf-8");
      io.sockets.emit('errorLogs',{data:enc.decode(data)});
    });
  }
});


server.listen(3000, () => {
    console.log('listening on *:3000');
});
