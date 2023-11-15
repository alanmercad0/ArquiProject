# Hooded Heights!
Created by Alan Mercado and Diego Lugo

To run this game you will need to have ca65 and ld65 installed, along with an emulator. (We used mesen2 found at: https://github.com/SourMesen/Mesen2)

Once you have all of this ready, you will need to run a few commands:


ca65 src/animations.asm 

ca65 src/backgrounds.asm

ca65 src/controllers.asm

ca65 src/reset.asm

ca65 src/final.asm   


ld65 src/reset.o src/backgrounds.o  src/controllers.o src/animations.o src/final.o  -C nes.cfg -o final.nes


We hope you enjoy our first attempt at making a NES game :)
