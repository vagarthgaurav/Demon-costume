# Demon costume

Consists of Three different PCB's as part of a Demon Costume.

## demonBoard 

The main control board of the costume. It uses an ESP32-C3 Wroom microcontroller module to control 2 Linear actuators that open and close a set of wings. There are also connectors for connecting the custome RGB LED board string. 

## demonSpawn 

The remote control that communicates with the demonBoard using wifi or bluetooth. The board uses an ESP32-C3 Wroom microcontroller. It is powered by a 18650 Li-Ion battery. The battery can be charged with USB C via the onboard charge controller. The board can also power 5V RGB LED's and can be integrated into a handheld accessory like a sword. 

## demonLight

A custom PCB that carries a WS2813B RGB LED. The boards can be connected in series. It also has M2 screw terminal's to screw in thorns. 

