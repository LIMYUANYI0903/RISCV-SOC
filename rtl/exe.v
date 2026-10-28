`include "defines.v"

module exe(
    input wire rst_i,

    //from id_exe
    input wire[`RDATA_WIDTH-1:0] op1_i,
    input wire[`RDATA_WIDTH-1:0] op2_i,
    input wire reg_we_i,
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire[`DATA_WIDTH-1:0] inst_i,
    input wire[`ADDR_WIDTH-1:0] inst_addr_i, //for j_b

    //to exe_mem
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,
    output reg reg_we_o,

    output reg mem_we_o,
    output reg[`ADDR_WIDTH-1:0] mem_addr_o,
    output reg[`DATA_WIDTH-1:0] mem_data_o,
    output reg[3:0] mem_op_o, //LB,LH,LW,LBU, LHU, SB, SH, SW

    //to pipe control
    output reg[`ADDR_WIDTH-1:0] jump_addr_o,
    output reg jump_enable_o
);

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];

    //------------------R-TYPE------------------------------
    wire [`RDATA_WIDTH-1:0] r_reg_wdata_o;
    wire r_reg_we_o;

    exe_type_r exe_type_r0(
        .rst_i(rst_i),
        .inst_i(inst_i),
        .op1_i(op1_i),
        .op2_i(op2_i),
        .reg_wdata_o(r_reg_wdata_o),
        .reg_we_o(r_reg_we_o)
     );

    //-------------------TYPE_I ,對於比較的operation，先在這邊做
    wire[31:0] sr_shift;
    wire[31:0] sr_shift_mask;
    assign sr_shift = op1_i >> op2_i[4:0];
    assign sr_shift_mask = 32'hffffffff >> op2_i[4:0];

    wire op1_ge_op2_signed;
    wire op1_ge_op2_unsigned;
    assign op1_ge_op2_signed = ($signed(op1_i) >= $signed(op2_i));
    assign op1_ge_op2_unsigned = (op1_i >= op2_i);

    //-------------STORE/LOAD--------------------------
    wire s_reg_we_o;
    wire[`RDATA_WIDTH-1:0] s_reg_wdata_o;
    wire[`DATA_WIDTH-1:0] s_mem_data_o;
    wire[`ADDR_WIDTH-1:0] s_mem_addr_o;
    wire s_mem_we_o;
    wire[3:0] s_mem_op_o;
    
    exe_type_s_l exe_type_s_l0(
        .rst_i(rst_i),
        .op1_i(op1_i),
        .op2_i(op2_i),
        .inst_i(inst_i),
        .reg_wdata_o(s_reg_wdata_o),
        .reg_we_o(s_reg_we_o),
        .mem_addr_o(s_mem_addr_o),
        .mem_data_o(s_mem_data_o),
        .mem_we_o(s_mem_we_o),
        .mem_op_o(s_mem_op_o)

    );

    //-------------JUMP--------------------------

    wire[`ADDR_WIDTH-1:0] b_jump_addr_o;
    wire b_jump_enable_o;
    exe_type_b_j exe_type_b_j0(
        .rst_i(rst_i),
        .inst_i(inst_i),
        .inst_addr_i(inst_addr_i),
        .op1_i(op1_i),
        .op2_i(op2_i),
        .jump_addr_o(b_jump_addr_o),
        .jump_enable_o(b_jump_enable_o)
    );

    always @(*) begin 
        if(rst_i == 1) begin
            reg_waddr_o = `ZERO_REG;
            reg_wdata_o = `ZERO;
            reg_we_o = `WRITE_DISABLE;
            mem_we_o = `WRITE_DISABLE;
            mem_addr_o = `ZERO;
            mem_data_o = `ZERO;
            mem_op_o = `MEM_NOP;
            jump_addr_o =  `ZERO;
            jump_enable_o = 1'b0;
        end
        else begin
            reg_waddr_o = `ZERO_REG;
            reg_wdata_o = `ZERO;
            reg_we_o = reg_we_i;
            mem_we_o   = `WRITE_DISABLE;
            mem_addr_o = `ZERO;
            mem_data_o = `ZERO;
            mem_op_o   = `MEM_NOP;
            jump_addr_o =  `ZERO;
            jump_enable_o = 1'b0;
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
            //----------------------TYPE_R_M-----------------------------  
                end 
                `INST_TYPE_R_M: begin
                    reg_waddr_o = reg_waddr_i;
                    reg_wdata_o = r_reg_wdata_o;
                    reg_we_o = r_reg_we_o;
                end
                `INST_TYPE_LUI,`INST_TYPE_AUIPC: begin
                    reg_waddr_o = reg_waddr_i;
                    reg_wdata_o = op1_i + op2_i;
                    reg_we_o = reg_we_i;
                end
                `INST_TYPE_S, `INST_TYPE_L: begin
                    reg_waddr_o = reg_waddr_i;
                    reg_wdata_o = s_reg_wdata_o;
                    reg_we_o = s_reg_we_o;
                    mem_we_o = s_mem_we_o;
                    mem_addr_o = s_mem_addr_o;
                    mem_data_o = s_mem_data_o;
                    mem_op_o = s_mem_op_o;
                end
            //----------------------TYPE_B_J-----------------------------  
                `INST_TYPE_B: begin 
                    jump_addr_o = b_jump_addr_o;
                    jump_enable_o = b_jump_enable_o;
                end
                `INST_TYPE_JAL, `INST_TYPE_JALR: begin
                    jump_addr_o = b_jump_addr_o;
                    jump_enable_o = b_jump_enable_o;
                    reg_waddr_o = reg_waddr_i;
                    reg_wdata_o = inst_addr_i+4;
                    reg_we_o = `WRITE_ENABLE;
                end
                default: begin
                    reg_waddr_o = `ZERO_REG;
                    reg_we_o = `WRITE_DISABLE;
                end            
            endcase
        end
    end

endmodule