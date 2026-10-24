`include "defines.v"

module mem(
    input wire rst_i,

    //from exe_mem
    input wire[`RADDR_WIDTH-1:0] reg_waddr_i,
    input wire[`RDATA_WIDTH-1:0] reg_wdata_i,
    input wire reg_we_i,

    //for store/load
    input wire mem_we_i,
    input wire[`ADDR_WIDTH-1:0] mem_addr_i,
    input wire[`DATA_WIDTH-1:0] mem_data_i,
    input wire[3:0] mem_op_i, //LB,LH,LW,LBU, LHU, SB, SH, SW

    //to mem_wb
    output reg[`RADDR_WIDTH-1:0] reg_waddr_o,
    output reg[`RDATA_WIDTH-1:0] reg_wdata_o,
    output reg reg_we_o,

    //from ram
    input wire[`DATA_WIDTH-1:0] ram_data_i,

    //to ram
    output reg[`ADDR_WIDTH-1:0] ram_addr_o,
    output reg ram_w_request_o,
    output reg[`DATA_WIDTH-1:0] ram_data_o
);

    wire[1:0] ram_addr_offset;
    assign ram_addr_offset = mem_addr_i[1:0]; //0,1,2,3


    //for wb regfile
    always @(*) begin
        if(rst_i == 1) begin
            reg_waddr_o = `ZERO_REG;
            //reg_wdata_o = `ZERO;
            reg_we_o = `WRITE_DISABLE;
        end else begin
            reg_waddr_o = reg_waddr_i;
            //reg_wdata_o = reg_wdata_i;
            reg_we_o = reg_we_i;
        end
    end

    //for ram 
    always @(*) begin
        if(rst_i == 1) begin
            ram_addr_o = `ZERO;
            ram_data_o = `ZERO;
            ram_w_request_o = `WRITE_DISABLE;
        end else begin
            ram_addr_o = mem_addr_i;
            ram_data_o = `ZERO;
            ram_w_request_o = mem_we_i;
            case(mem_op_i)
                `LB: begin
                    case(ram_addr_offset)
                    2'b00:begin
                        reg_wdata_o = {{24{ram_data_i[7]}}, ram_data_i[7:0]};
                    end
                    2'b01:begin
                        reg_wdata_o = {{24{ram_data_i[15]}}, ram_data_i[15:8]};
                    end
                    2'b10:begin
                        reg_wdata_o = {{24{ram_data_i[23]}}, ram_data_i[23:16]};
                    end
                    default:begin
                        reg_wdata_o = {{24{ram_data_i[31]}}, ram_data_i[31:24]};
                    end
                    endcase
                end
                `LH: begin
                    if(ram_addr_offset==2'b00) begin
                        reg_wdata_o = {{16{ram_data_i[15]}}, ram_data_i[15:0]};
                    end else if(ram_addr_offset==2'b10) begin
                        reg_wdata_o = {{16{ram_data_i[31]}}, ram_data_i[31:16]};
                    end else
                        reg_wdata_o = `ZERO;
                end     
                `LW: begin
                    reg_wdata_o = ram_data_i;
                end
                `LBU: begin
                    case(ram_addr_offset)
                    2'b00:begin
                        reg_wdata_o = {24'h0, ram_data_i[7:0]};
                    end
                    2'b01:begin
                        reg_wdata_o = {24'h0, ram_data_i[15:8]};
                    end
                    2'b10:begin
                        reg_wdata_o = {24'h0, ram_data_i[23:16]};
                    end
                    default:begin
                        reg_wdata_o = {24'h0, ram_data_i[31:24]};
                    end
                    endcase
                end
                `LHU: begin
                    if(ram_addr_offset==2'b00) begin
                        reg_wdata_o = {16'h0, ram_data_i[15:0]};
                    end else if(ram_addr_offset==2'b10) begin
                        reg_wdata_o = {16'h0, ram_data_i[31:16]};
                    end else
                        reg_wdata_o = `ZERO;    
                end
                `SB: begin
                    ram_w_request_o = mem_we_i;
                    case (ram_addr_offset)
                    2'b00: begin
                        ram_data_o = {ram_data_i[31:8],mem_data_i[7:0]};
                    end
                    2'b01: begin
                        ram_data_o = {ram_data_i[31:16],mem_data_i[7:0], ram_data_i[7:0]};
                    end
                    2'b10:begin
                        ram_data_o = {ram_data_i[31:24],mem_data_i[7:0], ram_data_i[15:0]};
                    end
                    default:begin
                        ram_data_o = {mem_data_i[7:0], ram_data_i[23:0]};
                    end
                    endcase
                end
                `SH: begin
                    if(ram_addr_offset == 2'b00)begin
                        ram_data_o = {ram_data_i[31:16],mem_data_i[15:0]};
                    end else if(ram_addr_offset == 2'b10)begin
                        ram_data_o = {mem_data_i[15:0], ram_data_i[15:0]};
                    end else
                        ram_data_o = `ZERO;
                end
                `SW: begin
                    ram_data_o = mem_data_i;
                end
                default: begin
                    reg_wdata_o = reg_wdata_i;
                    ram_addr_o = `ZERO;
                    ram_data_o = `ZERO;
                    ram_w_request_o = `WRITE_DISABLE;
                end
            endcase
        end
    end
endmodule