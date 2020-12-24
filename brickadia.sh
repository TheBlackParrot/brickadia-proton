#!/usr/bin/env bash

PROTON_VERSIONS=("3.7" "3.16" "4.2" "4.11" "5.0")
PROTON_APPIDS=(858280 961940 1054830 1113280 1245040)
ARGV=("$@")

function br_install {
	mkdir -p "$BRICKADIA_DIR"
	cd "$BRICKADIA_DIR"

	if ! which wine; then
		echo "wine not detected in PATH, please install wine."
		exit
	fi

	if ! which winetricks; then
		WINETRICKS_SCRIPT="$BRICKADIA_DIR/winetricks"

		if [ ! -f "$BRICKADIA_DIR/winetricks" ]; then
			echo -e "\n\033[1mwinetricks script not found at $WINETRICKS_SCRIPT, downloading it...\033[0m"
			curl -o "$WINETRICKS_SCRIPT" "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
			chmod +x "$WINETRICKS_SCRIPT"
		fi
	else
		WINETRICKS_SCRIPT=$(which winetricks)
	fi

	echo -e "\n\033[1mINSTALLER MAY FAIL INSTALLING VC2010. Just ctrl-c the script/cancel installation and re-run the script.\033[0m"
	sleep 3s

	# Run the installer
	cd "$PROTON_DIR"
	./proton run "$BRICKADIA_DIR/BrickadiaInstaller.exe"

	# Kill the running wine server and install vcredist2010
	echo -e "\n\033[1mManually re-installing the VC2010 redistributable package...\033[0m"
	sleep 1s
	wineserver -k
	WINEPREFIX="$BRICKADIA_DIR/pfx" $WINETRICKS_SCRIPT vcrun2010

	echo -e "\n\033[1mBrickadia should be installed! Run this script again with \"run\" instead of \"install\".\033[0m"
	exit
}

function br_vars {
	if ! touch ./vars; then
		echo "Could not write ./vars, please check permissions of the parent folder and re-run script."
		exit
	else
		rm ./vars
	fi

	# (Default variables)
	# Wine prefix directory
	BRICKADIA_DIR="$(pwd)"
	while [ -z "$inp" ]; do
		printf "Directory to store files needed for Brickadia and installing it [default $BRICKADIA_DIR]: "; read inp

		if [ -z "$inp" ]; then
			inp="$BRICKADIA_DIR"
		fi

		if [ ! -d "$inp" ]; then
			printf "Would you like to create the directory $inp? Y/n: "; read inp2

			if [ "${inp2,,}" == "n" ]; then
				unset inp
				unset inp2
			else
				mkdir -p "$inp"
			fi
		fi
	done
	BRICKADIA_DIR="$inp"
	unset inp
	unset inp2

	# URL to Launcher
	LAUNCHER_DOWNLOAD_URL="https://static.brickadia.com/launcher/1.4/BrickadiaInstaller.exe"
	printf "URL to download the Brickadia launcher from [default $LAUNCHER_DOWNLOAD_URL]: "; read inp
	if [ -z "$inp" ]; then
		inp="$LAUNCHER_DOWNLOAD_URL"
	fi
	LAUNCHER_DOWNLOAD_URL="$inp"
	unset inp

	# Download the launcher
	echo -e "\n\033[1mDownloading the launcher installer...\033[0m"
	if [ ! -f "$BRICKADIA_DIR/BrickadiaInstaller.exe" ]; then
		curl -o "$BRICKADIA_DIR/BrickadiaInstaller.exe" "$LAUNCHER_DOWNLOAD_URL"
	fi

	# Directory containing proton
	PROTON_DIR="$HOME/.local/share/Steam/steamapps/common/Proton 4.11"
	while [ -z "$inp" ]; do
		printf "Directory containing Proton [default $PROTON_DIR, or dl to download]: "; read inp

		if [ -z "$inp" ]; then
			inp="$PROTON_DIR"
		fi

		if [ "${inp,,}" == "dl" ]; then
			if ! which steamcmd; then
				echo "steamcmd not detected in PATH, please install steamcmd."
				exit
			fi

			echo -e "\n\033[1m!! SIGN IN ON STEAM FIRST BEFORE CONTINUING. !!\033[0m"
			echo -e "\033[0;31m!! YOU WILL BE SIGNED OUT OF STEAM. !!\033[0m"
			printf "Enter your Steam username: "; read steamu

			while [ -z $protonv ]; do
				echo -e "\n\033[0;31m!! Proton 5.13 is currently disabled. !!\033[0m"
				echo -e "\033[1mSee issue #4269 and PR #4409 on Github in Proton's Github repository.\033[0m"
				printf "Select the Proton version you want to download (0: 3.7; 1: 3.16; 2: 4.2; 3: 4.11; 4: 5.0): "; read protonv
			done

			echo -e "\n\033[1mInstalling Proton ${PROTON_VERSIONS[$protonv]} to $BRICKADIA_DIR/Proton...\033[0m"
			if [ -d "$BRICKADIA_DIR/Proton" ]; then
				rm -rf "$BRICKADIA_DIR/Proton"
				mkdir "$BRICKADIA_DIR/Proton"
			fi
			
			echo -e "\033[1mInstalling via steamcmd may take multiple attempts. (may hit Invalid install path bug)\033[0m"
			while [ ! -f "$BRICKADIA_DIR/Proton/proton" ]; do
				steamcmd +force_install_dir "$BRICKADIA_DIR/Proton" +login "$steamu" +app_update ${PROTON_APPIDS[$protonv]} +exit
			done

			#if [ $protonv -eq 5 ]; then
			#	# https://github.com/ValveSoftware/Proton/issues/4269
			#	# https://github.com/ValveSoftware/Proton/pull/4409
			#	echo -e "\033[1mApplying workaround to fix an invalid symbolic link that Valve seemingly refuses to update in Proton 5.13... -_-\033[0m"
			#	echo -e "\033[1mThis next Wine command will fail.\033[0m"
			#	sleep 1s
			#	# This will fail, we just need default_pfx to be created
			#	STEAM_COMPAT_DATA_PATH="$BRICKADIA_DIR" "$BRICKADIA_DIR/Proton/proton" run "$BRICKADIA_DIR/BrickadiaInstaller.exe"
			#
			#	if [ -d "$BRICKADIA_DIR/pfx" ]; then
			#		rm -rf "$BRICKADIA_DIR/pfx"
			#	fi
			#	# The symbolic links in here are all correct so we're just gonna copy it, whatever. Fix this, Valve.
			#	cp -r "$BRICKADIA_DIR/Proton/dist/share/default_pfx" "$BRICKADIA_DIR/pfx"
			#fi

			inp="$BRICKADIA_DIR/Proton"
		fi

		if [ ! -f "$inp/proton" ]; then
			echo "Proton executable script not found in directory $inp."
			exit
		fi
	done
	PROTON_DIR="$inp"
	unset inp
	
	echo "BRICKADIA_DIR=\"$BRICKADIA_DIR\"" > ./vars
	echo "LAUNCHER_DOWNLOAD_URL=\"$LAUNCHER_DOWNLOAD_URL\"" >> ./vars
	echo "PROTON_DIR=\"$PROTON_DIR\"" >> ./vars

	echo ""
	cat ./vars
}

function br_run {
	echo -e "\n\033[1mStarting the launcher...\033[0m"
	DIR="$BRICKADIA_DIR/pfx/drive_c/Program Files/Brickadia/BrickadiaLauncher"

	if [ ! -f "$DIR/BrickadiaLauncher.exe" ]; then
		echo "Brickadia launcher not present in $DIR. Use this script again with \"install\" instead of \"run\"."
	fi

	BRANCH="${ARGV[1]}"
	if [ -z ${ARGV[1]} ]; then
		BRANCH="main"
	else
		echo "Running on branch ${ARGV[1]}"
	fi

	echo "$LAUNCHER_ARGS"
	cd "$PROTON_DIR"
	./proton run "$DIR/BrickadiaLauncher.exe" --branch $BRANCH
	exit
}

if [ ! -f ./vars ]; then
	br_vars
fi
source ./vars

# Proton needs this
export STEAM_COMPAT_DATA_PATH=$BRICKADIA_DIR

case ${ARGV[0],,} in
	r|ru|run)
		br_run;;

	i|in|ins|inst|insta|instal|install)
		br_install;;

	v|va|var|vars|vari|varia|variab|variabl|variable|variables)
		br_vars;;

	* ) 
		echo "Commands: run [branch]/install/vars";;
esac
