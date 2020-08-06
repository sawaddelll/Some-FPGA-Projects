# Snake

For a digital design course, I worked on a version of the Snake video game implemented on an FPGA. A short demo of the game can be seen here. 
The game handled 3 players, 2 of which used an android app communicating with the FPGA over Bluetooth, and the game was shown on a VGA display. It was a group project but I wrote almost all of the SystemVerilog related to the game logic—controlling the movement of the snakes, and how they interacted or changed length—as well as how all of that information + user input was stored and then displayed over VGA.

P.S. The provided video driver that we used was also something I worked with a lot for the academic research I was doing at the same time, as the project was to connect that video driver to an existing camera driver for the DE1_SoC (so that students could adjust the resolution of the camera output, making the camera and driver easier to work with).
