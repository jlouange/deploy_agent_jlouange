# deploy_agent_jlouange
A shell script that automates the creation of the workspace, configures settings via the command line, and handles system signals gracefully.H

## How to run the script.

```text
Open your terminal with bash pre installed on it.
check if the directory contains the file 
```bash setup_project.sh ```

if it is found:

Run:

```bash
./setup_project.sh
```

Or alternatively you can do:

```bash
bash setup_project.sh
```
and follow the instructions!

## How to trigger the archive feature.

There is an archive feature in the script which 
archives the exit state of the process when the user presses
**` CTRL + C`** while the script is running.

Here the SIGNAL is captured by utilising the `trap` command  
to intercept the SIGINT signal sent when the user presses Ctrl + c
and then the archive is made with the command:

```bash
tar -cfz ...
```

the form of the archive is:

```bash
attendance_tracker_{input}_archive
```

