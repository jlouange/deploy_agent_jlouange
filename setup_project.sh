#!/usr/bin/env bash
echo "============================="
echo "Attendance tracker deployment"
echo "============================="

#checking wether python is on the system
if python3 --version &> /dev/null; then
    echo "Python is installed on the system"
    echo "---------------------------------"

else
    echo "----------------------------------"
    echo -e "Python is not found! \n First install python"
    exit 1
fi

echo "========================================"

#Creating the core directory structure

read -r -p "Enter project name identifier: " version

directory_name="attendance_tracker_$version"

mkdir -p "$directory_name"/{Helpers,reports}

if [ -d "$directory_name" ]; then
    echo "Directory $directory_name created successfully"
    echo "-----------------------------------------------"
else  
    echo "ERROR: Directory creation failed"
    echo "--------------------------------"
    exit 1
fi


#I copied our resource files to our directory structure

cp attendance_checker.py "$directory_name/"

if [ -f "$directory_name/attendance_checker.py" ]; then
    echo "Deployment verified: attendance_checker.py is present."
else
    echo "Error: attendance_checker.py missing."
fi

cp assets.csv "$directory_name"/Helpers

if [ -f "$directory_name/Helpers/assets.csv" ]; then
    echo "Deployment verified: assets.csv is present."
else
    echo "Error: assets.csv missing."
fi

cp config.json "$directory_name"/Helpers

if [ -f "$directory_name/Helpers/config.json" ]; then
    echo "Deployment verified: config.json is present."
else
    echo "Error: config.json missing."
fi

cp reports.log "$directory_name"/reports

if [ -f "$directory_name/reports/reports.log" ]; then
    echo "Deployment verified: reports.log is present."
else
    echo "Error: reports.log missing."
fi



