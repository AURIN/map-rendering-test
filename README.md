map-rendering-test
=========================

Test-bed to run rendering performance tests.

## Installation

If on dev-api.aurin.org.au, change dir to `/opt`.

Install the package:
`npm install git+https://<your github user>@github.com/AURIN/map-rendering-test.git#<version>"`

Move the package's from the `node_modules` dir
`mv node_modules/map-rendering-test/ .`

If on dev-api.aurin.org.au:
`sudo service rendering restart`


## Run

on LINUX, run: `./lan.sh`

on Windows, run: `cmd /c lan.bat`

If you are outside the AURIN's LAN:
1) Setup an SSH tunnel from port localhost:8984 to port db2.aurin.org.au:5984
2) Setup an SSH tunnel from port localhost:8432 to port db2.aurin.org.au:5432
3) Run `./wan.sh`

Open a browser (possibly FireFox) at:
`http://localhost:2010/index.html`

If it has been installed on dev-api.aurin.org.au, open at:
`https://dev-api.aurin.org.au/rendering/index.html`
   