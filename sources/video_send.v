`timescale 1ns / 1ps

module video_send(
    input i_clk,
    input i_rst,
    input i_config_ok,
    input i_grayscale,
    // HDMI Output
    output o_hdmi_vsync,
    output o_hdmi_hsync,
    output o_hdmi_de,
    output o_hdmi_clk,
    output [15:0] o_hdmi_data
);

assign o_hdmi_clk = i_clk;

wire [15:0] pixel_x, pixel_y;
vga640p display(
    .i_pix_clk      (i_clk          ),
    .i_rst          (i_rst          ),
    .o_hs           (o_hdmi_hsync   ),
    .o_vs           (o_hdmi_vsync   ),
    .o_frame_st     (               ),
    .o_x            (pixel_x        ),
    .o_y            (pixel_y        ),
    .o_active       (o_hdmi_de      )
);

localparam BAR_WIDTH = 80;  
wire [2:0] bar_index = pixel_x / BAR_WIDTH;

reg [7:0] data_y;
reg [7:0] data_cb;
reg [7:0] data_cr;

always @* begin
    if (i_grayscale == 0)
    begin
        case (bar_index)
            3'd0: {data_y, data_cb, data_cr} = {8'hEB, 8'h80, 8'h80}; // White  (Y=235, Cb=128, Cr=128)
            3'd1: {data_y, data_cb, data_cr} = {8'hDD, 8'h0F, 8'h8B}; // Yellow
            3'd2: {data_y, data_cb, data_cr} = {8'hBC, 8'h9A, 8'h0F}; // Cyan
            3'd3: {data_y, data_cb, data_cr} = {8'h40, 8'h66, 8'hF1}; // Red
            3'd4: {data_y, data_cb, data_cr} = {8'hAD, 8'h29, 8'h1A}; // Green
            3'd5: {data_y, data_cb, data_cr} = {8'h1F, 8'hF1, 8'h75}; // Blue
            3'd6: {data_y, data_cb, data_cr} = {8'h10, 8'h80, 8'h80}; // Black (Y=16)
            3'd7: {data_y, data_cb, data_cr} = {8'h4F, 8'hD7, 8'hE6}; // Magenta
        endcase
    end else begin
        case (bar_index)
            3'd0: {data_y, data_cb, data_cr} = {8'hEB, 8'h80, 8'h80};
            3'd1: {data_y, data_cb, data_cr} = {8'hCB, 8'h80, 8'h80};
            3'd2: {data_y, data_cb, data_cr} = {8'hAB, 8'h80, 8'h80};
            3'd3: {data_y, data_cb, data_cr} = {8'h8B, 8'h80, 8'h80};
            3'd4: {data_y, data_cb, data_cr} = {8'h6B, 8'h80, 8'h80};
            3'd5: {data_y, data_cb, data_cr} = {8'h4B, 8'h80, 8'h80};
            3'd6: {data_y, data_cb, data_cr} = {8'h2B, 8'h80, 8'h80};
            3'd7: {data_y, data_cb, data_cr} = {8'h10, 8'h80, 8'h80};
        endcase
    end
end

assign o_hdmi_data = pixel_x[0] ? {data_cr, data_y} : {data_cb, data_y};
 
endmodule
