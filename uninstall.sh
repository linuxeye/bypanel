#!/bin/sh
# Author:  Justo <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: ByPanel for Linux/Darwin 64bit
#
# Project home page:
#       https://github.com/linuxeye/bypanel

# Environment variables definition
KERNEL_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
case "${KERNEL_NAME}" in
darwin*)
  BASE_PATH=${BASE_PATH:-$HOME/bypanel}
  VOLUME_PATH=${VOLUME_PATH:-$HOME/bypanel/data}
  BYPANEL_PATH=${BYPANEL_PATH:-$HOME/bypanel/bin/bypanel}
  ;;
*)
  BASE_PATH=${BASE_PATH:-/opt/bypanel}
  VOLUME_PATH=${VOLUME_PATH:-/data}
  BYPANEL_PATH=${BYPANEL_PATH:-/usr/bin/bypanel}
  # Check if user is root
  [ $(id -u) != "0" ] && {
    printf "\033[31mError: You must be root to run this script\033[0m\n"
    exit 1
  }
  ;;
esac

WEBROOT_PATH="${VOLUME_PATH}/webroot"
LOGS_PATH="${VOLUME_PATH}/logs"

# Colored output functions
echo_red() {
  printf "\033[31m$1\033[0m\n"
}

echo_green() {
  printf "\033[32m$1\033[0m\n"
}

echo_yellow() {
  printf "\033[33m$1\033[0m\n"
}

# Show warning information
show_warning() {
  echo_yellow "========================================================"
  echo_yellow "                    WARNING! WARNING! WARNING!           "
  echo_yellow "========================================================"
  echo_yellow "Executing this script will uninstall ByPanel and its related components."
  echo_yellow "The following operations will be performed:"
  echo_yellow "1. Stop Docker related containers"
  echo_yellow "2. Stop ByPanel services"
  echo_yellow "3. Delete ByPanel"
  echo_yellow "4. Optional: Delete website root directory (requires user confirmation)"
  echo_yellow "5. Optional: Delete app data directory (requires user confirmation)"
  echo_yellow "6. Optional: Delete logs directory (requires user confirmation)"
  echo_yellow "7. Optional: Stop Docker (requires user confirmation)"
  echo_yellow ""
  echo_red   "This operation is irreversible, please ensure you have backed up all important data!"
  echo_yellow "========================================================"
}

# User confirmation
confirm_uninstall() {
  echo
  while true; do
    read -e -p "Confirm to continue uninstalling ByPanel? (y/n): " confirm
    case "${confirm}" in
      [Yy]* ) return 0 ;;
      [Nn]* | "" ) echo_red "Uninstall operation cancelled" && exit 1 ;;
      * ) echo "Please enter y or n" ;;
    esac
  done
}

# Stop ByPanel services and containers
stop_bypanel() {
   # Stop Docker containers
  bypanel down
  echo_green "Docker containers stopped and removed"
  
  echo "Stopping ByPanel services..." 
  # Stop system services
  case "${KERNEL_NAME}" in
    linux* )
      if command -v systemctl > /dev/null; then
        systemctl stop bypanel > /dev/null 2>&1 || true
        systemctl disable bypanel > /dev/null 2>&1 || true
        rm -f /etc/systemd/system/bypanel.service /etc/profile.d/bypanel.sh
        systemctl daemon-reload
      else
        service bypanel stop > /dev/null 2>&1 || true
      fi
      ;;
    darwin* )
      launchctl unload -w /Library/LaunchDaemons/com.bypanel.service.plist > /dev/null 2>&1 || true
      rm -f /Library/LaunchDaemons/com.bypanel.service.plist
      ;;
  esac
}

# Clean ByPanel files
clean_bypanel() {

  echo "Cleaning ByPanel files..."
  # Delete main program directory
  if [ -d "${BASE_PATH}" ]; then
    rm -rf "${BASE_PATH}"
    echo_green "Deleted ${BASE_PATH}"
  fi

  if [ -f "${BYPANEL_PATH}" ]; then
    rm -f "${BYPANEL_PATH}"
    echo_green "Deleted ${BYPANEL_PATH}"
  fi

  if [ -d "${VOLUME_PATH}/backups" ]; then
    rm -rf "${VOLUME_PATH}/backups"
    echo_green "Deleted ${VOLUME_PATH}/backups"
  fi
}

# Clean webroot directory (requires user confirmation)
clean_webroot() {
  if [ -d "${WEBROOT_PATH}" ]; then
    echo
    echo_yellow "Note: Webroot directory ${WEBROOT_PATH} contains your website files"
    while true; do
      read -e -p "Do you want to delete the webroot directory and all its contents? This operation is irreversible! (y/n): " confirm
      case "${confirm}" in
        [Yy]* )
          rm -rf "${WEBROOT_PATH}"
          echo_green "Deleted webroot directory ${WEBROOT_PATH}"
          break
          ;;
        [Nn]* | "" )
          echo_yellow "Retained webroot directory ${WEBROOT_PATH}"
          break
          ;;
        * )
          echo "Please enter y or n"
          ;;
      esac
    done
  fi
}

# Clean app data (requires user confirmation for each directory)
clean_app_data() {
  # Get all matching data directories
  APP_DIRS=$(ls ${VOLUME_PATH} 2>/dev/null | grep -E '^(pgsql-|mariadb-|mysql-|percona-|mongo-|redis|rabbitmq|activemq|sftpgo|zookeeper)')

  if [ -n "${APP_DIRS}" ]; then
    echo
    echo_yellow "Note: The following app data directories contain your data:"
    echo_yellow "${APP_DIRS}"
    
    # Loop through each directory and ask for confirmation individually
    for dir in ${APP_DIRS}; do
      dir_path="${VOLUME_PATH}/${dir}"
      while true; do
        read -e -p "Do you want to delete the directory '${dir}' and all its contents? This operation is irreversible! (y/n): " confirm
        case "${confirm}" in
          [Yy]* )
            rm -rf "${dir_path}"
            echo_green "Deleted data directory: ${dir_path}"
            break
            ;;
          [Nn]* | "" )
            echo_yellow "Retained data directory: ${dir_path}"
            break
            ;;
          * )
            echo "Please enter y or n"
            ;;
        esac
      done
    done
  fi
}

# Clean logs directory (requires user confirmation)
clean_logs() {
  if [ -d "${LOGS_PATH}" ]; then
    echo
    echo_yellow "Note: Logs directory ${LOGS_PATH} contains app logs"
    while true; do
      read -e -p "Do you want to delete the logs directory and all its contents? This operation is irreversible! (y/n): " confirm
      case "${confirm}" in
        [Yy]* )
          rm -rf "${LOGS_PATH}"
          echo_green "Deleted logs directory ${LOGS_PATH}"
          break
          ;;
        [Nn]* | "" )
          echo_yellow "Retained logs directory ${LOGS_PATH}"
          break
          ;;
        * )
          echo "Please enter y or n"
          ;;
      esac
    done
  fi
}

# stop Docker (requires user confirmation)
stop_docker() {
  if command -v docker > /dev/null; then
    echo
    echo_yellow "Note: Docker may be used by other applications"
    while true; do
      read -e -p "Do you want to stop the Docker service? (y/n): " confirm
      case "${confirm}" in
        [Yy]* )
          echo "Stopping Docker service..."
          if command -v systemctl > /dev/null; then
            systemctl stop docker > /dev/null 2>&1 || true
            systemctl disable docker > /dev/null 2>&1 || true
          else
            service docker stop > /dev/null 2>&1 || true
          fi
          echo_green "Docker service stopped"
          break
          ;;
        [Nn]* | "" )
          echo_yellow "Retained Docker service running state"
          break
          ;;
        * )
          echo "Please enter y or n"
          ;;
      esac
    done
  fi
}

# Main function
main() {
  # Show warning and confirmation
  show_warning
  confirm_uninstall
  
  # Execute uninstall steps
  stop_bypanel
  clean_bypanel
  clean_webroot
  clean_app_data
  stop_docker
  clean_logs
  
  # Clean empty directories
  if [ -d "${VOLUME_PATH}" ] && [ -z "$(ls -A "${VOLUME_PATH}")" ]; then
    rm -rf "${VOLUME_PATH}"
    echo_green "Deleted empty directory ${VOLUME_PATH}"
  fi
  
  # Uninstall complete
  echo_yellow "========================================================"
  echo_green "ByPanel uninstallation complete!"
  echo_yellow "========================================================"
}

# Execute main function
main
