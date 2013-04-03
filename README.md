map-rendering-test
=========================

Test-bed to run rendering performance tests.

## Installation

`npm install`


## Run

on LINUX, run: `./lan.sh`

on Windows, run: `cmd /c lan.bat`

If you are outside the AURIN's LAN:
1) Setup an SSH tunnel from port localhost:8984 to port db2.aurin.org.au:5984
2) Setup an SSH tunnel from port localhost:8432 to port db2.aurin.org.au:5432
3) Run `./wan.sh`

Open a browser (possibly FireFox) at:
http://localhost:2010/index.html

   