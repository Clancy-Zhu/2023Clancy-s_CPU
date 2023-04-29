module sram_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output reg [SRAM_ADDR_WIDTH-1:0] sram_addr,  //BaseRAM地址
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,  //BaseRAM数据 三态门 高阻态只允许输入，否则只允许输出
    output reg sram_ce_n,  //BaseRAM片选，低有效
    output reg sram_oe_n,  //BaseRAM读使能，低有效
    output reg sram_we_n,  //BaseRAM写使能，低有效
    output reg [SRAM_BYTES-1:0] sram_be_n  //BaseRAM字节使能，低有效
);

  typedef enum logic [2:0] {
    IDLE,
    READ,
    READ2,
    WRITE,
    WRITE2,
    WRITE3,
    DONE
  } state_t;

  state_t state;
  logic [SRAM_ADDR_WIDTH-1:0] sram_addr_reg;
  logic sram_ce_n_reg, sram_oe_n_reg, sram_we_n_reg;
  logic [SRAM_BYTES-1:0] sram_be_n_reg;
  wire [31:0] sram_data_i_comb;
  reg [31:0] sram_data_o_comb;
  reg [31:0] sram_data_reg;
  reg sram_data_t_comb;

  assign sram_data = sram_data_t_comb ? 32'bz : sram_data_o_comb;
  assign sram_data_i_comb = sram_data;

  // TODO: 实现 SRAM 控制器
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      sram_addr_reg <= 0;
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          wb_ack_o <= 1'b0;
          sram_data_o_comb <= 32'b0;
          sram_data_t_comb <= 1'b1;  //不论读写 首个阶段都是高阻态
          if (wb_cyc_i && wb_stb_i) begin
            sram_addr_reg <= wb_adr_i >> SRAM_BYTE_WIDTH;  //地址翻译
            sram_be_n_reg <= ~wb_sel_i;
            if (wb_we_i) begin
              sram_ce_n_reg <= 1'b0;
              sram_oe_n_reg <= 1'b1;
              sram_we_n_reg <= 1'b1;
              state <= WRITE;
            end else begin
              sram_ce_n_reg <= 1'b0;
              sram_oe_n_reg <= 1'b0;
              sram_we_n_reg <= 1'b1;
              state <= READ;
            end
          end
        end
        READ: begin
          wb_dat_o <= sram_data_i_comb;
          state <= READ2;
        end
        READ2: begin
          sram_ce_n_reg <= 1'b1;
          sram_oe_n_reg <= 1'b1;
          wb_ack_o <= 1'b1;
          state <= DONE;
        end
        WRITE: begin  //读取32bit的数据
          sram_data_reg <= sram_data_i_comb;  //通过o_comb输出
          state <= WRITE2;
        end
        WRITE2: begin  //开始写
          sram_we_n_reg <= 1'b0;
          sram_data_t_comb <= 1'b0;  //只能写，不能读
          sram_data_o_comb[7:0] <= (sram_be_n_reg[0] ? sram_data_reg[7:0] : wb_dat_i[7:0]);
          sram_data_o_comb[15:8] <= (sram_be_n_reg[1] ? sram_data_reg[15:8] : wb_dat_i[15:8]);
          sram_data_o_comb[23:16] <= (sram_be_n_reg[2] ? sram_data_reg[23:16] : wb_dat_i[23:16]);
          sram_data_o_comb[31:24] <= (sram_be_n_reg[3] ? sram_data_reg[31:24] : wb_dat_i[31:24]);
          state <= WRITE3;
        end
        WRITE3: begin  //写完
          sram_data_t_comb <= 1'b1;
          sram_we_n_reg <= 1'b1;
          sram_ce_n_reg <= 1'b1;
          sram_oe_n_reg <= 1'b1;
          wb_ack_o <= 1'b1;
          state <= DONE;
        end
        DONE: begin
          wb_ack_o <= 1'b0;
          state <= IDLE;
        end

      endcase
    end
  end

  always_comb begin
    sram_addr = sram_addr_reg;
    sram_ce_n = sram_ce_n_reg;
    sram_oe_n = sram_oe_n_reg;
    sram_we_n = sram_we_n_reg;
    sram_be_n = sram_be_n_reg;
  end


endmodule
