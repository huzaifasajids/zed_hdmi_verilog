`timescale 1ns / 1ps

module zed_hdmi(
    // Clock Interface
    input i_clk100MHz,
    
    // Control Signals
    input i_rst,
    input i_grayscale,
    
    // HDMI Interface
    input i_hdmi_int,
    input i_hdmi_spdif_out,
    output o_hdmi_spdif,
    output o_hdmi_vsync,
    output o_hdmi_hsync,
    output o_hdmi_de,
    output o_hdmi_clk,
    output [15:0] o_hdmi_data,
    output o_hdmi_iic_scl,
    inout  io_hdmi_iic_sda
);

    wire clk_25MHz;
    wire config_ok;
    
    assign o_hdmi_spdif = 1'b0;
    
    clock_divider #(
        .DIVIDEBY(4)
    ) clock_divider_i(
        .i_clk          (i_clk100MHz    ),
        .i_rst          (i_rst          ),
        .o_clk          (clk_25MHz      )
    );
    
    hdmi_config hdmi_config_i(
        .i_clk_25MHz    (clk_25MHz      ),
        .i_rst          (i_rst          ),
        .o_config_ok    (config_ok      ),
        .o_iic_scl      (o_hdmi_iic_scl ),
        .io_iic_sda     (io_hdmi_iic_sda)
    );
    
    video_send video_send_i(
        .i_clk          (clk_25MHz      ),
        .i_rst          (i_rst          ),
        .i_config_ok    (config_ok      ),
        .i_grayscale    (i_grayscale    ),
        .o_hdmi_vsync   (o_hdmi_vsync   ),
        .o_hdmi_hsync   (o_hdmi_hsync   ),
        .o_hdmi_de      (o_hdmi_de      ),
        .o_hdmi_clk     (o_hdmi_clk     ),
        .o_hdmi_data    (o_hdmi_data    )
    ); 
    
endmodule
