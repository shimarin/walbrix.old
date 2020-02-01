var http = require('http')
var os = require('os')

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/plain'})
    const host = os.hostname()
    res.end(`Hello World ${host} \n`)
}).listen(8080)
