# #!/bin/bash

# # Function to check if a port is open
# is_port_open() {
#     local port=$1
#     if netstat -tuln | grep -q ":$port"; then
#         return 0
#     else
#         return 1
#     fi
# }

# # Check if ports 80 and 8080 are open
# port_80_open=false
# port_8080_open=false

# if is_port_open 80; then
#     port_80_open=true
# fi

# if is_port_open 8080; then
#     port_8080_open=true
# fi

# # If either port is open, show a popup and ask if they can be closed
# if $port_80_open || $port_8080_open; then
#     message="Ports status:\n"
#     if $port_80_open; then
#         message+="Port 80 is open\n"
#     else
#         message+="Port 80 is closed\n"
#     fi

#     if $port_8080_open; then
#         message+="Port 8080 is open\n"
#     else
#         message+="Port 8080 is closed\n"
#     fi

#     zenity --question --title="Port Check" --text="$message\nCan I close the open ports 80 and 8080?"

#     if [ $? -eq 0 ]; then
#         if $port_80_open; then
#             sudo fuser -k 80/tcp
#             echo "Port 80 closed"
#         fi
#         if $port_8080_open; then
#             sudo fuser -k 8080/tcp
#             echo "Port 8080 closed"
#         fi
#     else
#         echo "Ports not closed"
#     fi
# else
#     echo "Both ports 80 and 8080 are closed. Continuing..."
# fi


# #!/bin/bash

# # Function to check if a port is open
# check_port() {
#     local port=$1
#     if nc -zv 127.0.0.1 $port 2>&1 | grep -q 'succeeded'; then
#         echo "Port $port is open or already in use. "
#         return 1
#     else
#         echo "Port $port is available."
#         return 0
#     fi
# }


# read -p "Ensure the port 80 and 8080 must be available to run the complete package of application (y/n): " verify_port

# if [ "$verify_port" == "y" ]; then

#     # Check ports 80 and 8080
#     check_port 80
#     port_80_status=$?

#     check_port 8080
#     port_8080_status=$?

#     if [ $port_80_status -eq 0 ] && [ $port_8080_status -eq 0 ]; then
#         echo "Both ports are available. Proceeding to the next step."
#     else
#         echo "Both ports 80 and 8080 must be available to run this application."
#     fi

# else 
#     echo "Port 80 and 8080 must be available to run this application."
# fi



#!/bin/bash

# Function to check if Docker is installed
check_docker_installed() {
    if command -v docker &> /dev/null
    then
        echo "Docker is installed."
        return 0
    else
        echo "Docker is not installed."
        return 1
    fi
}

check_docker_compose_installed() {
    if command -v docker-compose &> /dev/null
    then
        echo "Docker Compose is installed."
        return 0
    else
        echo "Docker Compose is not installed."
        return 1
    fi
}


# Check if Docker is installed
if check_docker_installed
then
    check_docker_installed_status=$?

    if check_docker_compose_installed
    then
        check_docker_compose_installed_status=$?
        # Check if the user is in the Docker group
        if groups $USER | grep &>/dev/null "\bdocker\b"
        then
            echo "User is already in the Docker group."
        else
            echo "Please add User in the Docker group....."
        fi
        check_user_dockergroup_status=$?

    else
        echo "Please first install Docker Compose"
    fi

    if [ $check_docker_installed_status -eq 0 ] && [ $check_docker_compose_installed_status -eq 0 ] && [ $check_user_dockergroup_status -eq 0 ]  ; then
        echo "docker, docker-compose and user configured with docker are available. Proceeding to the next step."
    else
        echo "Both docker and docker-compose must be available to run this application."
    fi


else
    echo "please first install Docker"
fi

# Further steps can be added here
echo "Proceeding with the next steps..."





