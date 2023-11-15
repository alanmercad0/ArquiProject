# Hooded Heights!
Created by Alan Mercado and Diego Lugo <br />

To run this game you will need to have ca65 and ld65 installed, along with an emulator. (We used mesen2 found at: https://github.com/SourMesen/Mesen2) <br />

Once you have all of this ready, you will need to run a few commands: <br />

ca65 src/animations.asm <br />
ca65 src/backgrounds.asm <br />
ca65 src/controllers.asm <br />
ca65 src/reset.asm <br />
ca65 src/final.asm   <br />
<br />
ld65 src/reset.o src/backgrounds.o  src/controllers.o src/animations.o src/final.o  -C nes.cfg -o final.nes <br />
<br />
We hope you enjoy our first attempt at making a NES game :)
