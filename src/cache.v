
module cache 
    # (
        parameter NATIVE_HRES = 800,
        parameter NATIVE_VRES = 600,
        parameter BITPERPIXEL = 12,
    ) (
        input reset,
        input clk,
        input [10:0]hread_ptr,
        input [10:0]vread_ptr,
        input h_sync_ref,
        output reg[BITPERPIXEL-1: 0] odata,
        input btn,
);
    reg [BITPERPIXEL-1: 0] mem [0: NATIVE_HRES - 1];
    integer i;

    always @(posedge clk) begin
        if (!reset) begin
            for(i = 0; i < NATIVE_HRES; i = i + 1) begin
                mem[i] = (i << 1);
            end
        end else begin
            if (h_sync_ref) begin
                odata = mem[hread_ptr];
            end else begin
                for(i = 0; i < NATIVE_HRES/4; i = i + 1) begin
                    mem[i] <= {(12){btn}}; 
                end
            end
        end
    end
endmodule