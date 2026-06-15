#!/usr/bin/env bash
echo "============================="
echo "Attendance tracker deployment"
echo "============================="


archiving(){ #the function responsible for archiving an incomplete process
  echo -e "\n[!]\n The Process is interupted... \n Archiving current state..."

  if [[ -d "$directory_name" ]]; then
    tar -czf "attendance_tracker_${version}_archive" "$directory_name"
    echo "Progress Archived in attendance_tracker_${version}_archive"

    rm -rf "$directory_name"
    echo "Incomplete directory $directory_name removed "

  else
    echo "Archiving current state..."
    echo "[!] THERE IS NOTHING TO ARCHIVE..."

  fi
  echo "Quitting..."
  exit 1

}

trap archiving SIGINT

restore(){

  if [ -d "$directory_name" ]; then
      echo "[!] Cleaning up partial directory: $directory_name"
      rm -rf "$directory_name"

  fi

}
#checking wether python is on the system
if python3 --version &> /dev/null; then
    echo "Python is installed on the system"
    echo "_____________________________________"

else
    echo ""
    echo -e "Python is not found! \n First install python"
    restore
    exit 1
fi


#Creating the core directory structure

read -r -p "Enter project name identifier: " version

directory_name="attendance_tracker_$version"

if [ -e "$directory_name" ]; then
    echo "ERROR: Directory $directory_name already exists!"
    exit 1
fi

mkdir -p "$directory_name"/{Helpers,reports}


if [ -d "$directory_name" ]; then
    echo "Directory $directory_name created successfully"
    echo "-----------------------------------------------"
else  
    echo "ERROR: Directory creation failed"
    echo "--------------------------------"
    restore
    exit 1
fi


#I copied our resource files to our directory structure

#cp attendance_checker.py "$directory_name/"

cat << 'EOF' > "$directory_name/attendance_checker.py"

import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()

EOF

if [ -f "$directory_name/attendance_checker.py" ]; then
    echo "Deployment verified: attendance_checker.py is present."
    echo "------------------------------------------------------"
else
    echo "Error: attendance_checker.py missing."
    echo "------------------------------------------------------"
    restore
    exit 1
fi

#cp assets.csv "$directory_name"/Helpers

cat << 'EOF' > "$directory_name/Helpers/assets.csv"

Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0

EOF



if [ -f "$directory_name/Helpers/assets.csv" ]; then
    echo "Deployment verified: assets.csv is present."
    echo "-------------------------------------------------------"

else
    echo "Error: assets.csv missing."
    echo "----------------------------------------------------------"
    restore
    exit 1
fi

#cp config.json "$directory_name"/Helpers

cat << 'EOF' > "$directory_name/Helpers/config.json"

{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}


EOF


if [ -f "$directory_name/Helpers/config.json" ]; then
    echo "Deployment verified: config.json is present."
else
    echo "Error: config.json missing."
    echo "---------------------------------------------"
    restore
    exit 1
fi

#cp reports.log "$directory_name"/reports

cat << 'EOF' > "$directory_name/reports/reports.log"

--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.


EOF

if [ -f "$directory_name/reports/reports.log" ]; then
    echo "Deployment verified: reports.log is present."
    echo "--------------------------------------------"
else
    echo "Error: reports.log missing."
    echo "---------------------------------------------"
    restore
    exit 1
fi

#updating threshold values
read -r -p "You want to update the attendance thresholds?[Y/N]: " choice

case "$choice" in
    [Yy]*)
        while true; do
            read -r -p "Warning threshold(default 75%): " warning
            warning=${warning:-75}
            warning=${warning%[%]*}
            
            if [[ "$warning" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [ "$(echo "$warning >= 0 && $warning <= 100" | bc -l)" -eq 1 ]; then
                break
            else
                echo "Enter a valid input from 0 to 100"
            fi
        done

        while true; do
            read -r -p "Failure threshold(default 50%): " failure
            failure=${failure:-50}
            failure=${failure%[%]*}
            
            # Use bc to validate decimals between 0 and 100
            if [[ "$failure" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [ "$(echo "$failure >= 0 && $failure <= 100" | bc -l)" -eq 1 ]; then
                break
            else
                echo "Enter a valid input from 0 to 100"
            fi
        done

        sed -i "s/\"warning\": [0-9.]*/\"warning\": $warning/" "$directory_name/Helpers/config.json"
        sed -i "s/\"failure\": [0-9.]*/\"failure\": $failure/" "$directory_name/Helpers/config.json"

        echo "Threshold updated successfully to $warning% and $failure%"
        ;;
    [Nn]*)
        echo "Keeping default thresholds (75% and 50%)"
        ;;
    *)
        echo "Input invalid. Keeping default thresholds. Please enter Y or N next time."
        echo "Deleting the created directory $directory_name"
        rm -r "$directory_name"
        exit 1
        ;;

esac

echo "============================================"