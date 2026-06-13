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

#