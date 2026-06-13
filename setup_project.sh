#!/usr/bin/env bash
echo "============================="
echo "Attendance tracker deployment"
echo "============================="


archiving(){ #the function responsible for archiving an incomplete process
  echo -e "[!]\n The Process is interupted... \n Archiving current state..."

  if [[ -d "$directory_name" ]]; then
    tar -czf "attendance_tracker_${version}_archive" "$directory_name"
    echo "Progress Archived in attendance_tracker_${version}_archive"

    rm -r "$directory_name"
    echo "Incomplete directory $directory_name removed "
  fi
  exit 1
}

trap archiving SIGINT


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
    echo "------------------------------------------------------"
else
    echo "Error: attendance_checker.py missing."
    echo "------------------------------------------------------"
fi

cp assets.csv "$directory_name"/Helpers

if [ -f "$directory_name/Helpers/assets.csv" ]; then
    echo "Deployment verified: assets.csv is present."
    echo "-------------------------------------------------------"

else
    echo "Error: assets.csv missing."
    echo "----------------------------------------------------------"
fi

cp config.json "$directory_name"/Helpers

if [ -f "$directory_name/Helpers/config.json" ]; then
    echo "Deployment verified: config.json is present."
else
    echo "Error: config.json missing."
    echo "---------------------------------------------"
fi

cp reports.log "$directory_name"/reports

if [ -f "$directory_name/reports/reports.log" ]; then
    echo "Deployment verified: reports.log is present."
    echo "--------------------------------------------"
else
    echo "Error: reports.log missing."
    echo "---------------------------------------------"
fi

echo "=================================="

#updating threshold values
read -r -p "You want to update the attendance thresholds?[Y/N]: " choice

case "$choice" in
  [Yy]*)
    read -r -p "Enter warning threshold(default 75%): " warning
    warning=${warning:-75}
    warning=${warning%[%]*}
    read -r -p "Enter failure threshold(default 50%): " failure
    failure=${failure:-50}
    failure=${failure%[%]*}

    if [[ "$warning" =~ ^[0-9]+$ && "$failure" =~ ^[0-9]+$ ]]; then

      sed -i "s/75/$warning/g" "$directory_name/Helpers/config.json"
      sed -i "s/50/$failure/g" "$directory_name/Helpers/config.json"

      echo "Threshold updated successfully to $warning% and $failure%"
    else
      echo "Error: Thresholds must be numeric values. Update aborted."

    fi
    

    ;;
  [Nn]*)
      echo "Keeping default thresholds (75% and 50%)"
    ;;
    *)
      echo "Invalid input skipping updates..."
      exit 1
esac