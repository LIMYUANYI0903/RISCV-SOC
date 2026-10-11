`include "defines.v"

module exe(
    input wire rst_i,

    //from id_exe
    input wire[`RDATA_WIDTH-1:0] op1_i,
    input wire[`RDATA_WIDTH-1:0] op2_i,
    input wire reg_we_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire[`DATA_WIDTH-1:0] inst_i,

    //to exe_mem
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,
    output reg reg_we_o
);

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];



    //--TYPE_I ,對於比較的operation，先在這邊做
    wire[31:0] sr_shift;
    wire[31:0] sr_shift_mask;
    assign sr_shift = op1_i >> op2_i[4:0];
    assign sr_shift_mask = 32'hffffffff >> op2_i[4:0];

    wire op1_ge_op2_signed;
    wire op1_ge_op2_unsigned;
    assign op1_ge_op2_signed = ($signed(op1_i) >= $signed(op2_i));
    assign op1_ge_op2_unsigned = (op1_i >= op2_i);



    always @(*) begin 
        if(rst_i == 1) begin
            reg_waddr_o = `ZERO_REG;
            reg_wdata_o = `ZERO;
            reg_we_o = `WRITE_DISABLE;
        end
        else begin
            reg_waddr_o = `ZERO_REG;
            reg_wdata_o = `ZERO;
            reg_we_o = reg_we_i;

            case (opcode)
            //------------------------TYPE_I--------------------------------
                `INST_TYPE_I: begin
                    reg_waddr_o = reg_waddr_i;
                    case(funct3)
                        `INST_ORI: begin
                            reg_wdata_o = op1_i | op2_i; //運算
                        end 
                        `INST_ADDI:begin
                            reg_wdata_o = $signed(op1_i) + $signed(op2_i); //運算
                        end 
                        `INST_ANDI:begin
                            reg_wdata_o = op1_i & op2_i;
                        end 
                        `INST_XORI:begin
                            reg_wdata_o = op1_i ^ op2_i;
                        end
                        `INST_SLTI: begin
                            //{32{(~op1_ge_op2_signed)}} & 32'h1
                            reg_wdata_o = {31'b0, ~op1_ge_op2_signed};//->0x01
                        end
                        `INST_SLTIU: begin
                            //{32{(~op1_ge_op2_unsigned)}} & 32'h1
                            reg_wdata_o = {31'b0, ~op1_ge_op2_unsigned};
                        end
                        `INST_SLLI: begin
                            if(funct7 == 7'b0000000) begin
                                reg_wdata_o = op1_i << op2_i[4:0];
                            end else begin
                                reg_waddr_o = `ZERO_REG;
                                reg_we_o = `WRITE_DISABLE;
                            end
                        end
                        `INST_SRLI: begin //together with SRAI
                            if(funct7 == 7'b0000000) begin
                                reg_wdata_o = op1_i >> op2_i[4:0];
                            end else if(funct7 == 7'b0100000) begin
                                reg_wdata_o = sr_shift | ({32{op1_i[31]}} & (~sr_shift_mask));
                            end else begin
                                reg_waddr_o = `ZERO_REG; 
                                reg_we_o = `WRITE_DISABLE;
                            end
                        end
                        default: begin
                            reg_waddr_o = `ZERO_REG;
                            reg_we_o = `WRITE_DISABLE;
                        end  
                    endcase   
                end 
                default: begin
                    reg_waddr_o = `ZERO_REG;
                    reg_we_o = `WRITE_DISABLE;
                end            
            endcase
        end
    end

endmodule