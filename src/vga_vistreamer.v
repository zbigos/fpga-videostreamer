`default_nettype none
`timescale 1ns/1ns

module vga_vistreamer(
    input clk,
    input btn,
    input reset,
    output vga_h_sync,
    output vga_v_sync,
    output reg[3:0] vga_r,
    output reg[3:0] vga_g,
    output reg[3:0] vga_b,
);


    wire core_busy;
    wire clock_36mhz;
    reg[10:0] h_readwire, v_readwire;
    reg[11:0] pixstream;

    pll pll36(
        .clock_in(clk),
        .clock_out(clock_36mhz),
    );
    
    cache globcache(
        .reset(reset),
        .btn(btn),
        .clk(clock_36mhz),
        .hread_ptr(h_readwire),
        .vread_ptr(v_readwire),
        .h_sync_ref(vga_h_sync),
        .odata(pixstream),
    );

    VGAcore core(
        .clk(clock_36mhz),
        .reset(reset),
        .drawing_pixels(core_busy),
        .h_sync(vga_h_sync),
        .v_sync(vga_v_sync),
        .pixstream(pixstream),
        .hreadwire(h_readwire),
        .vreadwire(v_readwire),
        .r(vga_r),
        .g(vga_g),
        .b(vga_b)
    );

endmodule
