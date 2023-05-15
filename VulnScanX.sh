#!/bin/bash

# author zynrir
#version 1.0

function sigint_handler {
    echo -e "\n"
    echo "bye-bye!!!"
    exit 0
}

get_os_from_ip() {
    
    get_ttl() {
        local ttl

        ttl=$(ping -c 1 "$ip" | grep ttl | awk -F "ttl=" '{print $2}' | awk -F " " '{print $1}')

        echo "$ttl"
    }

    get_os() {
        local ttl="$1"

        if (( ttl >= 0 && ttl <= 64 )); then
            echo "Linux"
        elif (( ttl >= 65 && ttl <= 128 )); then
            echo "Windows"
        else
            echo "Not Found"
        fi
    }

    ttl=$(get_ttl)
    os_name=$(get_os "$ttl")

    echo -e "\n$ip (ttl -> $ttl): $os_name\n"
}

function extract_vulnerability_info() {
    read -p "Enter the full path to the file containing the port scan results: " filepath
    if [ -f "$filepath" ]; then
        echo "[*] Extracting information from $filepath:"
        echo "Ports    Service      Version"
        #awk '/^[0-9]+\/tcp/ {printf "%-8s %-12s %s\n", $1, $3, $4}' "$filepath"
        awk '/^[0-9]+\/tcp/ {split($0, fields, " "); port = gensub(/\/tcp/, "", "g", fields[1]); service = fields[3]; version = substr($0, index($0, fields[4])); printf "%-9s %-12s %s\n", port, service, version }' "$filepath"
        echo "[*] The information has been successfully extracted from !!!!."
    else
        echo "File '$filepath' not found. Please run option 1 first to scan for open ports."
    fi
}

trap sigint_handler SIGINT SIGTERM

echo "Enter the target IP address:"
read ip

while true
do
    clear
    echo "---- Main menu ----"
    echo "0. Operating System Check"
    echo "1. Port scan"
    echo "2. Port information extraction"
    echo "3. Vulnerability scan" 
    echo "4. Vulnerability information extraction" 
    echo "5. Exit" 
    echo "Enter an option: "
    read opcion
    
    case $opcion in
        0)
            echo "[*] Checking connection."
                get_os_from_ip $ip
            read -p "Press Enter to return to the main menu."
            ;;
        1)
            while true
            do
                clear
                echo "---- Submenu: Port Scanning ----"
                echo "1. Scan TCP ports"
                echo "2. UDP port scan"
                echo "3. Scan all ports"
                echo "4. Exit to the main menu"
                echo "Enter an opcion: "
                read subopcion
                

                case $subopcion in
                    1)
                        echo "Scanning ports TCP to $ip"
                        sudo nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn $ip -oG ports
                        read -p "Press Enter to return to the submenu"
                        ;;
                    2)
                        echo "Scanning ports UDP to $ip"
                        nmap -p --open -sU --min-rate 5000 -vvv -n -Pn $ip -oG ports
                        read -p "Press Enter to return to the submenu"
                        ;;
                    3)
                        echo "Scanning all ports to $ip..."
                        nmap -p --open --min-rate 5000 -vvv -n -Pn $ip -oG ports
                        read -p "Press Enter to return to the submenu".
                        ;;
                    4)
                        break
                        ;;
                    *)
                        echo "Invalid option."
                        read -p "Press Enter to go to the main menu".
                        ;;
                esac
            done
            ;;
	    2)
            echo "Extracting port information..."
            extract_ports   
            read -p "Press Enter to go to the main menu".
            ;;
        3)
            echo "Performing vulnerability scan on $ip"
            read -p "Enter the port to scan: " port
            sudo nmap -sS -sC -sV -p "$port" "$ip" -oN targeted
            echo "Vulnerability scan completed. Results saved to the 'targeted' file."
            read -p "Press Enter to go to the main menu".
            ;;
        4)
            echo "Extracting vulnerability information from $filepath"
            extract_vulnerability_info
            read -p "Press Enter to go to the main menu".
            ;;
        5)
            echo "bye-bye!!"
            exit 0
            ;;
        *)
            echo "Invalid option."
            read -p "Press Enter to go to the main menu."
            ;;
    esac

function extract_ports() {
    if [ -f ports ]; then
        local ports="$(grep -oP '\d{1,5}/open' ports | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
        local ip_address="$(grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' ports | sort -u | head -n 1)"
        echo -e "\n[*] Extracting information...\n"
        echo -e "\t[*] IP Address: $ip_address"
        echo -e "\t[*] Open ports: $ports\n"
        echo $ports | tr -d '\n' | xclip -sel clip
        echo -e "[*] Ports copied to clipboard\n"
    else
        echo "File 'ports' not found. Please run option 1 first to scan for open ports."
    fi
}
done
