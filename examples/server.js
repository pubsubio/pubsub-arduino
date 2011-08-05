var buffoon = require('buffoon');
var server = require('router').create();

server.post('*',function(request, response) {
	buffoon.json(request, function(err, data){
		response.writeHead(200);
		response.end('ok');

		console.log('post ' + request.url + " data " + JSON.stringify(data));
	});
});

server.get('*', function(request, response) {
	response.writeHead(200);
	response.end('ok');
	
	console.log('get ' + request.url);
});

server.listen(12009);
console.log('server running on port 12009');