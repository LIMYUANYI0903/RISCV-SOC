`include "defines.v"

module pc_reg(
    input wire clk_i,
    input wire rst_i,
    output reg[`ADDR_WIDTH-1:0] pc_o,
    output reg ce_o, //Chip Enable

    input wire[5:0] stall_i,
    input wire flush_jump_i,  
    input wire[`ADDR_WIDTH-1:0] new_pc_i
);
    // 設定ce_o
    always @(posedge clk_i) begin
        if(rst_i==1'b1) begin
            ce_o <= 1'b0;
        end else begin
            ce_o <= 1'b1;
        end
    end

    //stall
    always @(posedge clk_i)  begin
        if (ce_o == 1'b0) begin
            pc_o <= 32'h0;
        end else if (flush_jump_i == 1'b1)
            pc_o <= new_pc_i; 
        else if (stall_i[0]==`STOP)
            pc_o <= pc_o;  //loop
        else begin
            pc_o <= pc_o + 4;
        end
    end

endmodule
