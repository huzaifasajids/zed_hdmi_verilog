`timescale 1ns / 1ps

module hdmi_config(
    input  wire i_clk_25MHz,
    input  wire i_rst,
    output wire o_config_ok,
    output wire o_iic_scl,
    inout  wire io_iic_sda
);

    wire        no_ack  ;
    wire        finish  ;
    wire        dout_en ;
    wire [7:0]  dout    ;
    wire        start   ;
    wire        wr_rd_en;
    wire [7:0]  addr    ;
    wire [7:0]  din     ;
    wire        iic_main;
    
    adv7511_device_config adv7511_device_config_i(
        .i_clk      (i_clk_25MHz),
        .i_rst      (i_rst      ),
        .i_no_ack   (no_ack     ),
        .i_finish   (finish     ),
        .i_dout_en  (dout_en    ),
        .i_dout     (dout       ),
        .o_start    (start      ),
        .o_wr_rd_en (wr_rd_en   ),
        .o_addr     (addr       ),
        .o_din      (din        ),
        .o_iic_main (iic_main   ),
        .o_config_ok(o_config_ok)
    );

    iic_interface iic_interface_i(
        .i_clk      (i_clk_25MHz), // 200Mhz
        .i_rst      (i_rst      ),
        .i_start    (start      ),
        .i_wr_rd_en (wr_rd_en   ), // 0: write , 1 read
        .i_addr     (addr       ),
        .i_din      (din        ),
        .o_dout_en  (dout_en    ),
        .o_dout     (dout       ),
        .o_no_ack   (no_ack     ),
        .o_finish   (finish     ),
        .i_iic_main (iic_main   ),
        .o_scl      (o_iic_scl  ), // 400Khz
        .io_sda     (io_iic_sda )
    );
    
endmodule
