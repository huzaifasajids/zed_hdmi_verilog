
# Verilog HDMI 1.4 on Zedboard (ADV7511)

This project demonstrates HDMI display implementation on the ZedBoard FPGA.  
The design outputs a 640x480 resolution test pattern through the HDMI port.  

All logic is written purely in *Verilog* – no Xilinx IP cores were used.  
This makes the design fully customizable and a great learning resource for understanding video signal generation on FPGAs.  

🔹 Key Features:  
- HDMI output on ZedBoard (Zynq-7000 FPGA)
- Programming the ADV7511 HDMI Transmitter using I2C  
- 640x480 resolution test pattern 
- 100% Verilog implementation (no IP cores)  
- Educational reference for FPGA video projects  


## Screenshots

![Color Bars Pattern](media/colored.jpg)

![Grayscale Bars Pattern](media/grayscale.jpg)

## Demo

The following video demonstrates the program running on Zedboard and displaying the test pattern on the HDMI connected screen.

![Watch the video](https://www.youtube.com/shorts/rypr4o7kEKw)

## Reusability

With minor tweaks, the project can be reused with all FPGA boards that use the ADV7511 HDMI 1.4 Transmitter. Most of Xilinx based FPGAs utilize the ADV7511 chip. Some prominent examples are listed below:

- Zedboard 
- ZC702
- ZC706
- KC705
- AC701
- SP701
- VC707

## Support

Hire me through email huzaifanustian@gmail.com or contact me through any of the platforms listed below

<a href="https://www.fiverr.com/s/Q7V2NLj">
  <img src="https://logos-world.net/wp-content/uploads/2020/12/Fiverr-Symbol.png" width="80">
</a>
