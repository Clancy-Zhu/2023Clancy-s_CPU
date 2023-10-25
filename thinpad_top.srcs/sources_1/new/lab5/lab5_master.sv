module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,

    // TODO: 添加�??要的控制信号，例如按键开关？
    input wire [ADDR_WIDTH-1:0] base_addr_i,

    // wishbone master
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o
);

  // TODO: 实现实验 5 的内�??+串口 Master
  typedef enum logic [3:0] {
    IDLE,
    READ_WAIT_ACTION,
    READ_WAIT_CHECK,
    READ_DATA_ACTION,
    READ_DATA_DONE,
    WRITE_SRAM_ACTION,
    WRITE_SRAM_DONE,
    WRITE_WAIT_ACTION,
    WRITE_WAIT_CHECK,
    WRITE_DATA_ACTION,
    WRITE_DATA_DONE
  } state_t;

  state_t state;

  logic [ADDR_WIDTH-1:0] base_addr_reg;
  logic [ADDR_WIDTH-1:0] pointer;
  logic [ADDR_WIDTH-1:0] uart_addr;
  logic [DATA_WIDTH:0] wb_data_reg;
  logic uart_state;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      wb_cyc_o <= 0;
      wb_stb_o <= 0;
      wb_we_o <= 0;
      wb_adr_o <= '0;
      wb_dat_o <= '0;
      wb_sel_o <= '0;
      pointer <= '0;
      base_addr_reg[ADDR_WIDTH-1:2] <= base_addr_i[ADDR_WIDTH-1:2];
      base_addr_reg[1:0] <= '0;
      uart_addr <= 32'h10000000;
      wb_data_reg <= '0;
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          wb_stb_o <= 1;
          wb_cyc_o <= 1;
          wb_adr_o <= uart_addr + 5;  // 读取串口状�??
          wb_sel_o <= 4'b0010;
          wb_we_o <= 0;
          state <= READ_WAIT_ACTION;
        end
        READ_WAIT_ACTION: begin
          if (wb_ack_i) begin  // 读取串口状�??
            wb_stb_o <= 0;
            wb_cyc_o <= 0;
            uart_state <= wb_dat_i[8];
            state <= READ_WAIT_CHECK;
          end
        end
        READ_WAIT_CHECK: begin
          // 0x10000005[0] == 1
          if (uart_state) begin  // 串口有数�??
            wb_stb_o <= 1;
            wb_cyc_o <= 1;
            wb_adr_o <= uart_addr;  // 读取串口数据
            wb_sel_o <= 4'b0001;
            state <= READ_DATA_ACTION;
          end else begin
            state <= IDLE;
          end
        end
        READ_DATA_ACTION: begin
          if (wb_ack_i) begin  // 读取串口数据
            wb_stb_o <= 0;
            wb_cyc_o <= 0;
            wb_data_reg <= wb_dat_i;
            state <= READ_DATA_DONE;
          end
        end
        READ_DATA_DONE: begin
          wb_stb_o <= 1;
          wb_cyc_o <= 1;
          wb_adr_o <= base_addr_reg + pointer;  // 写入 SRAM
          wb_dat_o <= wb_data_reg;
          wb_sel_o <= 4'b0001;
          wb_we_o <= 1;
          state <= WRITE_SRAM_ACTION;
        end
        WRITE_SRAM_ACTION: begin
          if (wb_ack_i) begin  // 写入 SRAM 完成
            wb_stb_o <= 0;
            wb_cyc_o <= 0;
            pointer <= pointer + 4;
            state <= WRITE_SRAM_DONE;
          end
        end
        WRITE_SRAM_DONE: begin
          wb_stb_o <= 1;
          wb_cyc_o <= 1;
          wb_adr_o <= uart_addr + 5;  // 读取串口状�??
          wb_sel_o <= 4'b0010;
          wb_we_o <= 0;
          state <= WRITE_WAIT_ACTION;
        end
        WRITE_WAIT_ACTION: begin
          if (wb_ack_i) begin  // 读取串口状�??
            wb_stb_o <= 0;
            wb_cyc_o <= 0;
            uart_state <= wb_dat_i[13];
            state <= WRITE_WAIT_CHECK;
          end
        end
        WRITE_WAIT_CHECK: begin
          // 0x10000005[5] == 1
          if (uart_state) begin  // 串口空闲
            wb_stb_o <= 1;
            wb_cyc_o <= 1;
            wb_dat_o <= wb_data_reg;
            wb_adr_o <= uart_addr;  // 写入串口数据
            wb_sel_o <= 4'b0001;
            wb_we_o <= 1;
            state <= WRITE_DATA_ACTION;
          end else begin
            state <= WRITE_SRAM_DONE;
          end
        end
        WRITE_DATA_ACTION: begin
          if (wb_ack_i) begin  // 写入串口数据
            wb_stb_o <= 0;
            wb_cyc_o <= 0;
            state <= WRITE_DATA_DONE;
          end
        end
        WRITE_DATA_DONE: begin
          wb_we_o <= 0;
          state   <= IDLE;
        end
        default: begin
        end
      endcase
    end
  end

endmodule
