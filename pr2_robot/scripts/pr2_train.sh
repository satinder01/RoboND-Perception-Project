#! /bin/bash
# This script safely launches ros nodes with buffer time to allow param server population
x-terminal-emulator -e roslaunch pr2_robot pick_place_project.launch &
