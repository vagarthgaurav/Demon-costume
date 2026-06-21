# Demon Costume

This project is the electronics part of a demon costume. The costume is a work in progress. The hardware design is completed. It will be eventually be integrated into the costume which is intended to be worn in festivals. 

It contains three custom PCBs. The wings open and close driven by linear actuators. It can also drive multiple RGB led chains. It is controlled wirelessly with a remote.

---

## demonBoard

<img src="images/demonBoard.JPG" width="500"/>

The Main controller. ESP32-C3 Wroom drives two linear actuators for the wings and has connectors for the LED boards. It is powered by a 3S Lipo. 

---

## demonSpawn

<img src="images/demonSpawn.JPG" width="500"/>

The remote that controls the main board. Also an ESP32-C3 Wroom, talks to the demonBoard over ESP-now protocol. It is powered by 18650 Li-Ion cell with USB-C charging. Has 5V LED outputs so it can be integrated into something like a sword.

---

## demonLight

<img src="images/demonLight.JPG" width="500"/>

Small board with a single WS2813B RGB LED. Boards can be chained together and they are screwed onto 3D printed thorns.

<img src="images/ThornLight.JPG" width="500"/>
