module dump();
    initial begin
        $dumpfile ("vga_core.vcd");
        $dumpvars (0, VGAcore);
        #1;
    end
endmodule
