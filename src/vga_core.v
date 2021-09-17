`default_nettype none
`timescale 1ns/1ns

module VGAcore 
    # (
        parameter NATIVE_HRES = 800,
        parameter FRONT_PORCH_H = 24,
        parameter SYNC_PULSE_H = 72,
        parameter BACK_PORCH_H = 128,

        parameter NATIVE_VRES = 600,
        parameter FRONT_PORCH_V = 1,
        parameter SYNC_PULSE_V = 2,
        parameter BACK_PORCH_V = 22,
        parameter RES_PRESCALER = 1
    ) (
        input wire clk,
        input wire reset,
        output wire drawing_pixels,
        output wire h_sync,
        output wire v_sync,
        output reg[10:0] hreadwire,
        output reg[10:0] vreadwire,
        input [11:0] pixstream,
        output reg[3:0] r,
        output reg[3:0] g,
        output reg[3:0] b
);

    /* expected frequency is 40Hz. Need to find such a prescaler that
       1. divides 800, 840, 968, 1056
       2. expects a clock that can be generated from 12MHz 

       common divisors of 800, 840, 968 and 1056 are 1, 2, 4, 8
       this means that frequencies are constrained to 40, 20, 10, 5 MHz

       with prescaler = 
    */

    reg [10:0] hscan_pos;
    reg [10:0] vscan_pos;
    reg [3:0] proposed_r;
    reg [3:0] proposed_b;
    reg [3:0] proposed_g;

    wire h_drawing_pixels, v_drawing_pixels;
    assign drawing_pixels = h_drawing_pixels & v_drawing_pixels;

    assign h_drawing_pixels = (hscan_pos >= 0 && hscan_pos < (NATIVE_HRES / RES_PRESCALER));
    
    assign h_sync = !((hscan_pos >= ((NATIVE_HRES + FRONT_PORCH_H) / RES_PRESCALER)) && (hscan_pos < ((NATIVE_HRES + FRONT_PORCH_H + SYNC_PULSE_H) / RES_PRESCALER)));
    
    assign v_drawing_pixels = (vscan_pos >= 0 && vscan_pos < NATIVE_VRES);
    assign v_sync = !((vscan_pos >= (NATIVE_VRES + FRONT_PORCH_V)) && (vscan_pos < (NATIVE_VRES + FRONT_PORCH_V + SYNC_PULSE_V)));

    assign r = proposed_r & {(4){drawing_pixels}};
    assign b = proposed_b & {(4){drawing_pixels}};
    assign g = proposed_g & {(4){drawing_pixels}};

    always @(posedge clk) begin
        if (!reset) begin
            hscan_pos = 0;
            vscan_pos = 0;
            proposed_r = {4'b0};
            proposed_g = {4'b0};
            proposed_b = {4'b0};
        end else begin

            hreadwire <= hscan_pos;
            vreadwire <= vscan_pos;

            /* advance horizontal scanline */
            hscan_pos = hscan_pos + 1'b1;
            proposed_r[0] <= pixstream[0];
            proposed_r[1] <= pixstream[1];
            proposed_r[2] <= pixstream[2];
            proposed_r[3] <= pixstream[3];

            proposed_g[0] <= pixstream[4];
            proposed_g[1] <= pixstream[5];
            proposed_g[2] <= pixstream[6];
            proposed_g[3] <= pixstream[7];

            proposed_b[0] <= pixstream[8];
            proposed_b[1] <= pixstream[9];
            proposed_b[2] <= pixstream[10];
            proposed_b[3] <= pixstream[11];

            if (hscan_pos == (1056 / RES_PRESCALER)) begin
                hscan_pos = 0;
                vscan_pos = vscan_pos + 1'b1;
            end

            if (vscan_pos == 628) begin
                vscan_pos = 0;
            end
        end
    end

endmodule