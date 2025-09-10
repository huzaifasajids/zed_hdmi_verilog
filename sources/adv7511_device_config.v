`timescale 1ns / 1ps

module adv7511_device_config(
    input           i_clk,
    input           i_rst,
    input           i_no_ack,
    input           i_finish,
    input           i_dout_en,
    input  [7:0]    i_dout,
    output          o_start,
    output          o_wr_rd_en,
    output [7:0]    o_addr,
    output [7:0]    o_din,
    output          o_iic_main,
    output          o_config_ok
);
    
    parameter [23:0] time_powerup = 'd14_850_000;
    parameter [7:0] register_num = 'd40;
        
    parameter [3:0] state_initial       = 'd0; // waite power 200ms
    parameter [3:0] state_idle          = 'd1;
    parameter [3:0] state_config_switch = 'd2; // config IIC 1-to-8 Bus Switch
    parameter [3:0] state_write         = 'd3;
    parameter [3:0] state_wait_ack      = 'd4;
    parameter [3:0] state_finish        = 'd5;
    parameter [3:0] state_read_hpd      = 'd6;
    parameter [3:0] state_hpd_data      = 'd7;
    
    reg [3:0] state = 'd0;
    
    reg [23:0] cnt_powerup = 'd0;
    
    reg         start    = 'd0;
    reg         wr_rd_en = 'd0;
    reg         iic_main = 'd0;
    
    reg [7:0]   num_config = 'd0;
    reg [15:0]  config_sign = 'd0;
    
    reg         phd_sign = 'd0;
    reg         config_ok = 'd0;
  
always@(posedge i_clk)
        case(num_config)
            //                   { addr,  din}
            'd0: config_sign <= {8'h42,8'h00}; // read hdp (check at the end of configuring HDMI)
               
            'd1: config_sign <= {8'h15,8'h01}; //I/P Formatt 4:2:2 Seperate synchs
            'd2: config_sign <= {8'h16,8'h38}; // O/P Formatt 4:4:4  RGB    // For Style 1 = 0x38
            'd3 : config_sign <= {8'h41,8'h10}; //Power Up the txr.
            'd4: config_sign <= {8'h48,8'h08}; //Right Justified
            'd5: config_sign <= {8'h55,8'h00}; //o/p Format RGB formatt
            'd6: config_sign <= {8'h56,8'b0010_1000}; //16:9 Aspect ratio to out put
            'd7 : config_sign <= {8'h98,8'h03}; //ADI Recommended write_7511
            'd8 : config_sign <= {8'h9a,8'he0}; //ADI Recommended write_7511
            'd9 : config_sign <= {8'h9c,8'h30}; //ADI Recommended write_7511
            'd10: config_sign <= {8'h9d,8'h61}; //ADI Recommended write_7511
            'd11: config_sign <= {8'ha2,8'ha4}; //ADI Recommended write_7511
            'd12: config_sign <= {8'ha3,8'ha4}; //ADI Recommended write_7511
            'd13: config_sign <= {8'he0,8'hd0}; //ADI Recommended write_7511
            'd14: config_sign <= {8'hf9,8'h00}; //ADI Recommended write_7511
            'd15: config_sign <= {8'h18,8'hAC};
            'd16: config_sign <= {8'h19,8'h53};
            'd17: config_sign <= {8'h1A,8'h08};
            'd18: config_sign <= {8'h1B,8'h00};
            'd19: config_sign <= {8'h1C,8'h00};
            'd20: config_sign <= {8'h1D,8'h00};
            'd21: config_sign <= {8'h1E,8'h19};
            'd22: config_sign <= {8'h1F,8'hD6};
            'd23: config_sign <= {8'h20,8'h1C};
            'd24: config_sign <= {8'h21,8'h56};
            'd25: config_sign <= {8'h22,8'h08};
            'd26: config_sign <= {8'h23,8'h00};
            'd27: config_sign <= {8'h24,8'h1E};
            'd28: config_sign <= {8'h25,8'h88};
            'd29: config_sign <= {8'h26,8'h02};
            'd30: config_sign <= {8'h27,8'h91};
            'd31: config_sign <= {8'h28,8'h1F};
            'd32: config_sign <= {8'h29,8'hFF};
            'd33: config_sign <= {8'h2A,8'h08};
            'd34: config_sign <= {8'h2B,8'h00};
            'd35: config_sign <= {8'h2C,8'h0E};
            'd36: config_sign <= {8'h2D,8'h85};
            'd37: config_sign <= {8'h2E,8'h18};
            'd38: config_sign <= {8'h2F,8'hBE};
            'd39: config_sign <= {8'haf,8'h06};//HDMI Mode - 6

            default: config_sign <= 'd0;
        endcase


    always@(posedge i_clk)
        case(state)
            state_initial: begin
                if(i_rst)
                    cnt_powerup <= 'd0;
                else
                    cnt_powerup <= cnt_powerup + 'd1;
                
                if(cnt_powerup == time_powerup - 'd1)
                    state <= state_idle;
                else
                    state <= state_initial;
                end
            state_idle: begin
                cnt_powerup <= 'd0;
                start <= 'd1;
                iic_main <= 'd1;
                num_config <= 'd1;
                wr_rd_en <= 'd0;
                config_ok <= 'd0;
                phd_sign <= 'd0;
                
                state <= state_config_switch;
                end
            state_config_switch: begin
                start <= 'd0;
                iic_main <= 'd0;
                wr_rd_en <= 'd0;
                
                if(i_finish)
                    state <= state_write;
                else
                    state <= state_config_switch;
                end
            
            state_write: begin
                start <= 'd1;
                wr_rd_en <= 'd0;
                
                state <= state_wait_ack;
                end
            state_wait_ack: begin
                start <= 'd0;
                if(i_finish)
                    num_config <= num_config + 'd1;
                else
                    num_config <= num_config;
                
                if(i_finish & i_no_ack)
                    state <= state_initial;
                else if(i_finish & (num_config == register_num - 'd1))
                    state <= state_finish;
                else if(i_finish)
                    state <= state_write;
                else
                    state <= state_wait_ack;
                end
            state_finish: begin
                num_config <= 'd0;
                state <= state_read_hpd;
                end
            
            state_read_hpd: begin
                start <= 'd1;
                wr_rd_en <= 'd1;
                
                state <= state_hpd_data;
                end
            state_hpd_data: begin
                start <= 'd0;
                wr_rd_en <= 'd0;
                num_config <= 'd0;
                config_ok <= phd_sign;
                if(i_dout_en)
                    phd_sign <= i_dout[6];
                else
                    phd_sign <= phd_sign;
                
                if(i_finish & i_no_ack)
                    state <= state_initial;
                else if(i_finish & ~phd_sign)
                    state <= state_initial;
                else if(i_finish)
                    state <= state_read_hpd;
                else
                    state <= state_hpd_data;
                end
            
            default: begin
                state <= state_initial;
                end
        endcase

    assign o_start      = start;
    assign o_wr_rd_en   = wr_rd_en;
    assign o_iic_main   = iic_main;
    assign o_addr       = config_sign[15:8];
    assign o_din        = config_sign[7:0];
    assign o_config_ok  = config_ok;
    
endmodule