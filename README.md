
# Verilog HDMI 1.4 on Zedboard (ADV7511)

This project demonstrates a pure Verilog implementation of HDMI video output on the ZedBoard FPGA, targeting the ADV7511 HDMI transmitter.  

It generates a 640x480 test pattern and configures the HDMI interface without using any vendor IP cores, making it a fully customizable and educational reference for FPGA video signal generation.

The design uses YCbCr color configuration with 4:2:2 compression ratio. 

🔹 **Key Features:**
- HDMI output on ZedBoard (Zynq-7000 FPGA)
- ADV7511 HDMI Transmitter configuration via I2C 
- 640x480 resolution test pattern 
- 100% Verilog implementation (no IP cores)  
- Modular and reusable design for other Xilinx FPGAs with ADV7511

---

## Design Structure

The design is broken down into 2 major components. hdmi_config module configures the ADV7511 chip and is easily reusable for other development boards. video_send module generates the video timings (which can be changed to produce other resolutions) and also produces the test pattern.

```
zed_hdmi.v (Top)
│
├── clock_divider.v
│
├── hdmi_config.v
│    ├── adv7511_device_config.v
│    └── iic_interface.v
│
└── video_send.v
     └── vga640p.v
```

---

## Files Overview

- **zed_hdmi.v**: Top-level module connecting all submodules and I/O.
- **clock_divider.v**: Produces required clock frequencies for video and I2C.
- **iic_interface.v**: Implements I2C protocol for ADV7511 configuration.
- **adv7511_device_config.v**: Contains ADV7511 register configuration logic.
- **hdmi_config.v**: Manages overall HDMI initialization and configuration sequence.
- **vga640p.v**: Generates 640x480 VGA timing.
- **video_send.v**: Produces the test pattern. Handles HDMI video signal generation and synchronization.
- **zedboard.xdc**: Design constraints file.
- **zed_hdmi.bit**: Programmable bit file for zedboard.

---

## Results

#### Screenshots
The Switches SW0 and SW1 are mapped in the constraints file for reset and grayscale respectively. SW1 can be used to switch between color pattern and grayscale pattern.

<table>
  <tr>
    <td align="center">
      <img src="https://i.postimg.cc/NKwMdFKz/colored.jpg" alt="Color Bars Pattern" width="250"/><br/>
      <sub><b>Color Bars Pattern</b></sub>
    </td>
    <td align="center">
      <img src="https://i.postimg.cc/HVMn0XkM/grayscale.jpg" alt="Grayscale Bars Pattern" width="250"/><br/>
      <sub><b>Grayscale Bars Pattern</b></sub>
    </td>
  </tr>
</table>

#### Demo

The following video demonstrates the program running on Zedboard and displaying the test pattern on the HDMI connected screen.

<a href="https://www.youtube.com/shorts/rypr4o7kEKw" target="_blank" >
  <img src="https://img.youtube.com/vi/rypr4o7kEKw/0.jpg" alt="Watch the demo video" width="300"/>
  <br/>
</a>

---

## Reusability

With minor tweaks in constraints file and ensuring proper clock division, the project can be reused with all FPGA boards that use the ADV7511 HDMI 1.4 Transmitter. Most of Xilinx based FPGAs utilize the ADV7511 chip. Some prominent examples are listed below:

<table align="center">
  <tr>
    <td align="center" width="120" height="30">Zedboard</td>
    <td align="center" width="120">ZC702</td>
    <td align="center" width="120">ZC706</td>
    <td align="center" width="120">KC705</td>
    <td align="center" width="120">Arty Z7</td>
  </tr>
  <tr>
    <td align="center" width="120" height="30">AC701</td>
    <td align="center" width="120">SP701</td>
    <td align="center" width="120">VC707</td>
    <td align="center" width="120">Nexys Video</td>
    <td align="center" width="120">MiniZed</td>
  </tr>
</table>

---

## 🔗 Useful Links
&nbsp;&nbsp;&nbsp;&nbsp;1. [Zedboard Hardware User Guide](https://files.digilent.com/resources/programmable-logic/zedboard/ZedBoard_HW_UG_v2_2.pdf)  
&nbsp;&nbsp;&nbsp;&nbsp;2. [ADV7511 Hardware Users Guide](https://www.analog.com/media/en/technical-documentation/user-guides/ADV7511_Hardware_Users_Guide.pdf)  
&nbsp;&nbsp;&nbsp;&nbsp;3. [ADV7511 Programming Guide](https://www.analog.com/media/en/technical-documentation/user-guides/ADV7511_Programming_Guide.pdf)  
&nbsp;&nbsp;&nbsp;&nbsp;4. [Xilinx FPGA HDMI-1.4 (understanding the basics)](https://www.hackster.io/nikilthapa/xilinx-fpga-hdmi1-4-you-must-know-first-78d774)  
&nbsp;&nbsp;&nbsp;&nbsp;5. [Zedboard HDMI design using Xilinx IP Cores](https://www.youtube.com/watch?v=BstMo5OwsjI)  

---

## Support

If you found this project useful, consider donating USDT (*TRC20 - Tron Network only*) at  
**USDT <img src="https://i.postimg.cc/C1F9TJgF/pngwing-com.png" width="13"/> Address**: `TJH5a6D8Rvy5KQ9JpLzaBJuZLvpJQb3apW` 

For more FPGA consulting or custom project ideas, contact me via the platforms below.

<table align="center" style="border: none;">
  <tr align="center" style="border: none;">
    <td align="center" width="100" height="100" style="border: none;">
      <a href="mailto:huzaifanustian@gmail.com">
      <img src="https://pngimg.com/uploads/email/small/email_PNG100741.png">
      </a>
    </td>
    <td align="center" width="100" height="100" style="border: none;">
      <a href="https://www.linkedin.com/in/huzaifa-sajid/">
      <img src="https://i.postimg.cc/P5CSsx78/toppng-com-gradient-blue-linkedin-vector-png-800x800.png">
      </a>
    </td>
    <td align="center" width="100" height="100" style="border: none;">
      <a href="https://www.fiverr.com/homesterech">
      <img src="https://i.postimg.cc/ydKqXxFH/fiverr.png">
      </a>
    </td>
    <td align="center" width="100" height="100" style="border: none;">
      <a href="https://www.upwork.com/freelancers/huzaifasajid3">
      <img src="https://i.postimg.cc/hP3Pc8q3/Upwork.png">
      </a>
    </td>
  </tr>
</table>