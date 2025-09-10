`timescale 1ns / 1ps

module iic_interface(
    input           i_clk,
    input           i_rst,
    input           i_start,
    input           i_wr_rd_en, // 0: write , 1 read
    input  [7:0]    i_addr,
    input  [7:0]    i_din,
    output          o_dout_en,
    output [7:0]    o_dout,
    output          o_no_ack,
    output          o_finish,
    input           i_iic_main,
    output          o_scl,
    inout           io_sda
);
    
//    parameter [15:0] freq_scl = 500; // 100Mhz/200khz
//    parameter [15:0] freq_scl = 372; // 74.25Mhz/200khz
    parameter [15:0] freq_scl = 324; // 64.796Mhz/200khz
    parameter [15:0] freq_scl_rising = freq_scl >> 2;
    parameter [15:0] freq_scl_falling = (freq_scl >> 2) + (freq_scl >> 1);
    
    parameter [6:0]  device_id      = 7'b0111_001;
    parameter [6:0]  device_main    = 7'b1110_100;
    parameter [7:0]  switch_iic_main = 8'b0010_0000; // ADV7511 IIC
    
    parameter [0:0]  write_sign = 1'b0;
    parameter [0:0]  read_sign = ~write_sign;
    parameter [0:0]  sda_out_sign = 'b1;
    parameter [0:0]  sda_in_sign = ~sda_out_sign;
    
    parameter [3:0] state_idle      = 'h0;
    parameter [3:0] state_ready     = 'h1;
    parameter [3:0] state_start     = 'h2;
    parameter [3:0] state_write     = 'h3;
    parameter [3:0] state_ack_wr    = 'h4;
    parameter [3:0] state_read      = 'h5;
    parameter [3:0] state_ack_rd    = 'h6;
    parameter [3:0] state_no_ack    = 'h7;
    parameter [3:0] state_stop      = 'h8;
    
    reg [3:0] state = 'd0;
    
    reg [7:0]   data_send = 'd0;
    reg [3:0]   num_frame = 'd0;
    
    reg start_r;
    reg start_rising;
    reg         wr_rd_en_r  = 'd0;
    reg [7:0]   addr_r      = 'd0;
    reg [7:0]   din_r       = 'd0;
    reg         iic_main_r  = 'd0;
    
    reg [23:0]  dff_data = 'd0;
    reg [7:0]   dff_timing_bit = 'd0;
    reg [7:0]   dff_timing_frame = 'd0;
    
    reg [15:0] cnt_cycle = 'd0;
    reg pulse_cycle = 'd0;
    
    reg sda_data_en = 'd0;
    reg [7:0] sda_data_receive = 'd0;
    
    reg sda_t;
    reg sda_dout;
    wire sda_din;
    
    reg scl;
    reg pulse_scl_rising = 'd0;
    reg pulse_scl_falling = 'd0;
    
    reg ack_reg;
    reg no_ack;
    reg finish;
    
    assign io_sda = (sda_t == sda_out_sign)? sda_dout: 1'bz;
    assign sda_din = (sda_t == sda_in_sign)? io_sda: 1'b0;
    assign o_scl = scl;
    
    assign o_dout_en = sda_data_en;
    assign o_dout = sda_data_receive;
    
    assign o_no_ack = no_ack;
    assign o_finish = finish;
    
    //----------------------- pulse signal --------------------
    always@(posedge i_clk)
        if(state == state_idle)
            cnt_cycle <= 'd0;
        else if(cnt_cycle == freq_scl - 'd1)
            cnt_cycle <= 'd0;
        else
            cnt_cycle <= cnt_cycle + 'd1;
    
    always@(posedge i_clk)
        if(cnt_cycle == freq_scl - 'd1)
            pulse_cycle <= 'd1;
        else
            pulse_cycle <= 'd0;
    
    always@(posedge i_clk)
        if(cnt_cycle == freq_scl_rising - 'd1)
            pulse_scl_rising <= 'd1;
        else
            pulse_scl_rising <= 'd0;
    
    always@(posedge i_clk)
        if(cnt_cycle == freq_scl_falling - 'd1)
            pulse_scl_falling <= 'd1;
        else
            pulse_scl_falling <= 'd0;
    //--------------------------------------------------------
    
    // start signal
    always@(posedge i_clk) begin
        start_r <= i_start;
        start_rising <= ~start_r & i_start;
        end
    
    // din buff
    always@(posedge i_clk)
        if(i_start) begin
            wr_rd_en_r <= i_wr_rd_en;
            addr_r     <= i_addr    ;
            din_r      <= i_din     ;
            iic_main_r <= i_iic_main;
            end
        else begin
            wr_rd_en_r <= wr_rd_en_r;
            addr_r     <= addr_r    ;
            din_r      <= din_r     ;
            iic_main_r <= iic_main_r;
            end
    
    // sda & state
    always@(posedge i_clk)
        case(state)
            state_idle: begin
                sda_t <= sda_out_sign;
                sda_dout <= 'd1;
                dff_timing_bit <= 'd0;
                dff_timing_frame <= 'd0;
                sda_data_en <= 'd0;
                sda_data_receive <= 'd0;
                ack_reg <= 'd0;
                no_ack <= 'd0;
                finish <= 'd0;
                
                if(iic_main_r)
                    dff_data <= {device_main,wr_rd_en_r,switch_iic_main,8'd0};
                else
                
                if(wr_rd_en_r == write_sign)
                    dff_data <= {{device_id,write_sign},addr_r,din_r}; // write
                else
                    dff_data <= {{device_id,write_sign},addr_r,{device_id,read_sign}}; // read
                
                if(start_rising)
                    state <= state_ready;
                else
                    state <= state_idle;
                end
            state_ready: begin
                sda_t <= sda_out_sign;
                sda_dout <= 'd1;
                
                if(pulse_cycle)
                    state <= state_start;
                else
                    state <= state_ready;
                end
            state_start: begin
                sda_t <= sda_out_sign;
                sda_dout <= 'd0;
                
                if(pulse_cycle)
                    state <= state_write;
                else
                    state <= state_start;
                end
            state_write: begin
                sda_t <= sda_out_sign;
                sda_dout <= dff_data[23];
                if(pulse_cycle) begin
                    dff_data <= dff_data << 1;
                    dff_timing_bit <= {dff_timing_bit[6:0],1'b1};
                    end
                else begin
                    dff_data <= dff_data;
                    dff_timing_bit <= dff_timing_bit;
                    end
                
                if(pulse_cycle & dff_timing_bit[6])
                    state <= state_ack_wr;
                else
                    state <= state_write;
                end
            state_ack_wr: begin
                sda_t <= sda_in_sign;
                dff_timing_bit <= 'd0;
                if(pulse_scl_rising)
                    ack_reg <= sda_din;
                else
                    ack_reg <= ack_reg;
                if(pulse_cycle)
                    dff_timing_frame <= {dff_timing_frame[6:0],1'b1};
                else
                    dff_timing_frame <= dff_timing_frame;
                
                if(pulse_cycle & ack_reg)
                    state <= state_no_ack;
                
                else if(pulse_cycle & iic_main_r)
                    if(wr_rd_en_r == read_sign)
                        state <= state_read;
                    else if(dff_timing_frame[0])
                        state <= state_stop;
                    else
                        state <= state_write;
                
                else if(pulse_cycle & ~dff_timing_frame[0])
                    state <= state_write;
                else if(pulse_cycle & ~dff_timing_frame[1] & (wr_rd_en_r == write_sign)) // write data
                    state <= state_write;
                else if(pulse_cycle & ~dff_timing_frame[1] & (wr_rd_en_r == read_sign)) // read restart
                    state <= state_ready;
                else if(pulse_cycle & (wr_rd_en_r == write_sign)) // write finish
                    state <= state_stop;
                else if(pulse_cycle & (wr_rd_en_r == read_sign)) // read data
                    state <= state_read;
                else
                    state <= state_ack_wr;
                end
            state_read: begin
                sda_t <= sda_in_sign;
                if(pulse_scl_rising)
                    ack_reg <= sda_din;
                else
                    ack_reg <= ack_reg;
                if(pulse_cycle) begin
                    sda_data_receive <= {sda_data_receive[6:0],ack_reg};
                    dff_timing_bit <= {dff_timing_bit[6:0],1'b1};
                    end
                else begin
                    sda_data_receive <= sda_data_receive;
                    dff_timing_bit <= dff_timing_bit;
                    end
                
                if(pulse_cycle & dff_timing_bit[6])
                    state <= state_ack_rd;
                else
                    state <= state_read;
                end
            state_ack_rd: begin
                sda_t <= sda_out_sign;
                sda_dout <= 'd1; // NACK
                dff_timing_bit <= 'd0;
                if(pulse_cycle) begin
                    sda_data_en <= 'd1;
                    dff_timing_frame <= {dff_timing_frame[6:0],1'b1};
                    end
                else begin
                    sda_data_en <= 'd0;
                    dff_timing_frame <= dff_timing_frame;
                    end
                
                if(pulse_cycle)
                    state <= state_stop;
                else
                    state <= state_ack_rd;
                end
            state_no_ack: begin
                no_ack <= 'd1;
                state <= state_stop;
                end
            state_stop: begin
                sda_t <= sda_out_sign;
                sda_dout <= 'd0;
                sda_data_en <= 'd0;
                if(pulse_cycle)
                    finish <= 'd1;
                else
                    finish <= 'd0;
                
                if(pulse_cycle)
                    state <= state_idle;
                else
                    state <= state_stop;
                end
            
            default: begin
                state <= state_idle;
                end
        endcase
    
    // scl
    always@(posedge i_clk)
        case(state)
            state_idle: begin
                scl <= 'd1;
                end
            state_stop,state_ready: begin
                if(pulse_scl_rising)
                    scl <= 'd1;
                else
                    scl <= scl;
                end
            default: begin
                if(pulse_scl_rising)
                    scl <= 'd1;
                else if(pulse_scl_falling)
                    scl <= 'd0;
                else
                    scl <= scl;
                end
        endcase
  
endmodule
