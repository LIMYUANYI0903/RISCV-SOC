`include "defines.v"

module ram(
    input wire clk_i,
    input wire rst_i,

    input wire we_i,
    input wire[`ADDR_WIDTH-1:0] addr_i,
    input wire[`DATA_WIDTH-1:0] data_i,
    output reg[`DATA_WIDTH-1:0] data_o
);

    reg[`DATA_WIDTH-1:0] mem[`MEM_SIZE-1:0];

    //----------STORE/LOAD---------------------
    //write
    always @(posedge clk_i) begin
        if(we_i == `WRITE_ENABLE && rst_i == 1'b0)
            mem[addr_i[`RAM_ADDR_WIDTH+1:2]] <= data_i;
    end

    //read 
    always @(*) begin
        if(rst_i == 1'b1) begin
            data_o = `ZERO;
        end else begin
            data_o = mem[addr_i[`RAM_ADDR_WIDTH+1:2]];
        end
    end
endmodule
