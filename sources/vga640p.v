module vga640p(
    input wire i_pix_clk,   // 25 MHz
    input wire i_rst,       // just put 1'b0 here if reset is not required
    output wire o_hs,           
    output wire o_vs,           
    output wire o_frame_st,
    output wire [15:0] o_x,
    output wire [15:0] o_y,
    output wire o_active
);

	localparam HS_STA = 640 + 16;           // horizontal sync start
    localparam HS_END = 640 + 16 + 96;      // horizontal sync end
    localparam HA_STA = 0;                  // horizontal active pixel start
    localparam HA_END = 640;                // horizontal active pixel end
    localparam VS_STA = 480 + 10;           // vertical sync start
    localparam VS_END = 480 + 10 + 2;       // vertical sync end
    localparam VA_END = 480;                // vertical active pixel end
    localparam LINE   = 800;                // complete line
    localparam SCREEN = 525;                // complete screen

    reg [15:0] h_count = 0; // line position
    reg [15:0] v_count = 0; // screen position

    // generate sync signals
    assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END));
    assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END));

    // keep x and y bound within the active pixels
    assign o_x = (h_count >= HA_END) ? (HA_END - 1) : (h_count - HA_STA);
    assign o_y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);
    assign o_active = (h_count < HA_END) & (v_count < VA_END);
    
    // o_frame_st: high for one tick at the end of the final active pixel line
    assign o_frame_st = ((v_count == VA_END - 1) & (h_count == LINE));

    always @ (posedge i_pix_clk)
    begin
        if (i_rst)  // reset to start of frame
        begin
            h_count <= 0;
            v_count <= 0;
        end
        else
        begin
            if (h_count == LINE)  // end of line
            begin
                h_count <= 0;
                v_count <= v_count + 1;
            end
            else 
                h_count <= h_count + 1;
            if (v_count == SCREEN)  // end of screen
                v_count <= 0;
            end
        end
endmodule
