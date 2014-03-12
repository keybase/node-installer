var path = require('path');

function check_node_name() {
	var x = process.argv[0];
	var p = x.split(path.sep);
	var n = p[p.length - 1];
	if (n !== "node") { 
		if (n == "nodejs") {
			console.error("Attention Ubuntu/Debian users; please `apt-get install nodejs-legacy` to enable `node` as an interpreter");
		} else {
			console.error("Your node binary isn't named `node`; keybase can't work in this case")
		}
		process.exit(3);
	}
}

function check_node_version() {
	var v = process.version;
	var m = v.match(/^v(\d+)\.(\d+)\./);
	if (m === null) {
		console.error("Unknown node version: " + v);
		process.exit(10);
	} else if (parseInt(m[1],10) === 0 && parseInt(m[2], 0) < 10) {
		console.error("Need node version v0.10.0 or greater; you have node version " + v);
		process.exit(10);
	} 
}

function main() {
	check_node_name();
	check_node_version();
}

main();