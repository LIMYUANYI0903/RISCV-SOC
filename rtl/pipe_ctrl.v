`include "defines.v"

module pipe_ctrl(

    input wire rst_i,
 
    //input wire  stallreq_from_if_i,  //waiting ROM delay
    input wire  stallreq_from_id_i,  //load hazard 
  
    //from exe
    input wire[`ADDR_WIDTH-1:0] jump_addr_i,
    input wire jump_enable_i,

    /* signals to other stages of the pipeline  ----*/
    output reg[5:0] stall_o,  // stall request to PC,IF_ID, ID_EX, EX_MEM, MEM_WB， one bit for one stage respectively
    
    output reg flush_jump_o, //flush if_id, id_exe, 
    output reg[`ADDR_WIDTH-1:0] new_pc_o
    );

    assign flush_jump_o = jump_enable_i; 
    assign new_pc_o = jump_addr_i;

    always @ (*) begin
        if(rst_i == 1'b1) begin
            stall_o = 6'b000000;
        // stall request from id: stop PC,IF_ID, ID_EXE
        end else if(stallreq_from_id_i == `STOP) begin
            stall_o = 6'b000111;
        end else begin
            stall_o = 6'b000000;
        end // if
    end // always

    

endmodule

		// stall request from if: stop the PC,IF_ID, ID_EXE
        //end else if(stallreq_from_if_i == `STOP) begin
        //    stall_o = 6'b000111;