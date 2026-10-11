`include "defines.v"

module id_type_i(
    input wire[`DATA_WIDTH-1:0] inst_i,

    //from regfile
    input wire[`RDATA_WIDTH-1:0] reg1_rdata_i,

    //to regfile
    output reg[`RADDR_WIDTH-1:0] reg1_raddr_o,
    output reg reg1_re_o,
    
    //decode result
    output reg[`RDATA_WIDTH-1:0] op1_o,//first value,operand1
    output reg[`RDATA_WIDTH-1:0] op2_o,//second value
    output reg reg_we_o,//write enable
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o
);

    wire[2:0] funct3 = inst_i[14:12];
    wire[4:0] rd = inst_i[11:7];
    wire[4:0] rs1 = inst_i[19:15];

    //type_i沒有rs2
    //wire[4:0] rs2 = inst_i[24:20];

    always @(*) begin
        //default
        reg1_raddr_o = `ZERO_REG;
        reg1_re_o = `READ_DISABLE;
        reg_we_o = `WRITE_DISABLE;
        reg_waddr_o = `ZERO_REG;
        op1_o = `ZERO;
        op2_o = `ZERO;
        
        case (funct3)
            `INST_ORI, `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ANDI: begin
                reg_we_o = `WRITE_ENABLE;
                reg_waddr_o = rd;
                reg1_re_o = `READ_ENABLE;
                reg1_raddr_o = rs1;
                op1_o = reg1_rdata_i;
                op2_o = {{20{inst_i[31]}}, inst_i[31:20]}; //12bit -> 32 bit
            end 
            `INST_SLLI: begin
                reg_we_o = `WRITE_ENABLE;
                reg_waddr_o = rd;
                reg1_re_o = `READ_ENABLE;
                reg1_raddr_o = rs1;
                op1_o = reg1_rdata_i;
                op2_o = {27'b0, inst_i[24:20]}; 
            end
            //SRLI & SRAI
            `INST_SRLI: begin
                reg_we_o = `WRITE_ENABLE;
                reg_waddr_o = rd;
                reg1_re_o = `READ_ENABLE;
                reg1_raddr_o = rs1;
                op1_o = reg1_rdata_i;
                op2_o = {{20{inst_i[31]}}, inst_i[31:20]};
            end
            default:begin
            end//default
        endcase
    end
endmodule