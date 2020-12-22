# Proton Launcher for Brickadia
This script launches Brickadia with Proton, and can grab select official releases of Proton for use with it.

## Notice
This script is new and I imagine it probably breaks in specific situations. It runs fine for me, but please install into a fresh Wine prefix just in case.  

For now, if you choose to install Proton through this script, it will install itself into a "Proton" directory in the set Brickadia folder during the initialization part. The prefix by default resides in "pfx" in the same folder.

## Dependencies
- curl
- steam *(for logging in for use with steamcmd)*
- steamcmd
- wine
- winetricks *(optional, script can grab it)*

## Usage
```
./brickadia.sh [vars|install|run]
	vars
		Sets installation directories and sets up some prerequisites
	install
		Installs the Brickadia launcher (may also run vars)
	run
		Runs the Brickadia launcher
```

## Brickadia user data directory
[Brickadia folder]/pfx/drive_c/users/steamuser/Local Settings/Application Data/Brickadia/Saved