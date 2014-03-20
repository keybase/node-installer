#!/usr/bin/env node

var semver = require('semver');

if (semver.lt(process.version, "0.10.0")) {
	console.error("We're sorry; keybase requires Node version v0.10 or greater; please upgrade");
	process.exit(2);
}

require("../lib/main").run();
