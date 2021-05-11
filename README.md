# flightgear-saitek
flightgear-saitek is a project for the open source flight simulator FlightGear. 
The purpose is to support all Saitek/Logitech panels in Flightgear perfectly. Currently the Saitek/Logitech 
radio panel and the Multi panel is supported.

## Goal
The goal of this project is to support input devices as realistic as possible.
For the default Cessna 172P, all buttons that are pressed on the hardware devices, do not only just work but even 
animate correctly in the software rendered simulation.
The project contains an input adapter which has the goal to provide a standardised way of accessing standard inputs and displays of most aircrafts. 
It can be used by any input device / external display to interface with a lot of aircrafts. 
And there is an option to add deviations from the defaults in order to "misuse" buttons on a certain hardware device 
for other functions in certain instruments.


## Status
Currently this is not part of FlightGear - it hopefully will be soon.

It already works very well in Linux and in Windows. 
In Windows, the number displays sometime work, sometime do not work. This is caused by the 
Windows 10 "enhanced power management" and X-Plane and MS FS 2020 are affected the same way.
There is a work-around: follow the steps given here: https://github.com/pfefferFlight/flightgear-saitek/issues/2#issuecomment-832503167


## How to install?
Click on the download-button above (downloading the repository), unzip it 
and place the files and folders as described in the file "install_saitek_panels.txt"

## Running FlightGear
If you plug in your device, after you started FlightGear, go to the menu, click on "debug" and "reload input" for FlightGear to recognise it.
After starting FlightGear, turn a knob or press a button on your device in order for the displays to become active, they will not become active automatically.


