`timescale 1ns / 1ps
module lab5_tb;

  wire clk_50M, clk_11M0592;

  reg push_btn;  // BTN5 �撘?�喉�撣行��頝荔����嗡蛹 1
  reg reset_btn;  // BTN6 憭��嚗蒂瘨��菔楝嚗�銝銝? 1

  reg [3:0] touch_btn;  // BTN1~BTN4嚗��桀��喉����嗡蛹 1
  reg [31:0] dip_sw;  // 32 雿���喉��典�N�銝? 1

  wire [15:0] leds;  // 16 雿? LED嚗��箸 1 �嫣漁
  wire [7:0] dpy0;  // �啁�蝞∩�雿縑�瘀��撠�對�颲 1 �嫣漁
  wire [7:0] dpy1;  // �啁�蝞⊿�雿縑�瘀��撠�對�颲 1 �嫣漁

  wire [31:0] base_ram_data;  // BaseRAM �唳嚗� 8 雿� CPLD 銝脣�批�典鈭?
  wire [19:0] base_ram_addr;  // BaseRAM �啣�
  wire[3:0] base_ram_be_n;    // BaseRAM 摮�雿輯嚗�������雿輻摮�雿輯嚗窈靽�銝? 0
  wire base_ram_ce_n;  // BaseRAM �?�雿��?
  wire base_ram_oe_n;  // BaseRAM 霂颱蝙�踝�雿��?
  wire base_ram_we_n;  // BaseRAM �蝙�踝�雿��?

  wire [31:0] ext_ram_data;  // ExtRAM �唳
  wire [19:0] ext_ram_addr;  // ExtRAM �啣�
  wire[3:0] ext_ram_be_n;    // ExtRAM 摮�雿輯嚗�������雿輻摮�雿輯嚗窈靽�銝? 0
  wire ext_ram_ce_n;  // ExtRAM �?�雿��?
  wire ext_ram_oe_n;  // ExtRAM 霂颱蝙�踝�雿��?
  wire ext_ram_we_n;  // ExtRAM �蝙�踝�雿��?

  wire txd;  // �渲�銝脣�?垢
  wire rxd;  // �渲�銝脣�交蝡?

  // CPLD 銝脣
  wire uart_rdn;  // 霂颱葡��縑�瘀�雿��?
  wire uart_wrn;  // �葡��縑�瘀�雿��?
  wire uart_dataready;  // 銝脣�唳��憟?
  wire uart_tbre;  // �?�格�敹?
  wire uart_tsre;  // �唳�?�瘥�敹?

  // Windows �?閬釣�楝敺��泵�蓮銋�靘� "D:\\foo\\bar.bin"
  parameter BASE_RAM_INIT_FILE = "/tmp/main.bin"; // BaseRAM ����隞塚�霂瑚耨�嫣蛹摰���撖寡楝敺?
  parameter EXT_RAM_INIT_FILE = "/tmp/eram.bin";  // ExtRAM ����隞塚�霂瑚耨�嫣蛹摰���撖寡楝敺?

  initial begin
    // �刻��隞亥摰�瘚�颲摨�嚗�憒�
    dip_sw = 32'h80000000;
    touch_btn = 0;
    reset_btn = 0;
    push_btn = 0;

    #100;
    reset_btn = 1;
    #100;
    reset_btn = 0;

    // TODO: �寞摰���雿�瘙��芸�銋��Ｙ�颲摨�
    for (integer i = 0; i < 20; i = i + 1) begin
      #100;  // 蝑� 100ns
      push_btn = 1;  // �� push_btn �
      #100;  // 蝑� 100ns
      push_btn = 0;  // �曉� push_btn �
    end

    // 璅⊥� PC ��銝脣嚗� FPGA �?�蝚?
    uart.pc_send_byte(8'h31);  // ASCII '1'
    #1000;
    uart.pc_send_byte(8'h32);  // ASCII '2'
    #1000;
    uart.pc_send_byte(8'h33);  // ASCII '3'
    #1000;
    uart.pc_send_byte(8'h34);  // ASCII '4'
    #1000;
    uart.pc_send_byte(8'h35);  // ASCII '5'

    // PC �交�唳�桀�嚗��其遛����葉��箸�?

    // 蝑�銝?畾菜�湛�蝏�隞輻�
    #100000 $finish;
  end

  // 敺�霂�瑁挽霈?
  lab5_top dut (
      .clk_50M(clk_50M),
      .clk_11M0592(clk_11M0592),
      .push_btn(push_btn),
      .reset_btn(reset_btn),
      .touch_btn(touch_btn),
      .dip_sw(dip_sw),
      .leds(leds),
      .dpy1(dpy1),
      .dpy0(dpy0),
      .txd(txd),
      .rxd(rxd),
      .uart_rdn(uart_rdn),
      .uart_wrn(uart_wrn),
      .uart_dataready(uart_dataready),
      .uart_tbre(uart_tbre),
      .uart_tsre(uart_tsre),
      .base_ram_data(base_ram_data),
      .base_ram_addr(base_ram_addr),
      .base_ram_ce_n(base_ram_ce_n),
      .base_ram_oe_n(base_ram_oe_n),
      .base_ram_we_n(base_ram_we_n),
      .base_ram_be_n(base_ram_be_n),
      .ext_ram_data(ext_ram_data),
      .ext_ram_addr(ext_ram_addr),
      .ext_ram_ce_n(ext_ram_ce_n),
      .ext_ram_oe_n(ext_ram_oe_n),
      .ext_ram_we_n(ext_ram_we_n),
      .ext_ram_be_n(ext_ram_be_n),
      .flash_d(),
      .flash_a(),
      .flash_rp_n(),
      .flash_vpen(),
      .flash_oe_n(),
      .flash_ce_n(),
      .flash_byte_n(),
      .flash_we_n()
  );

  // �園�皞?
  clock osc (
      .clk_11M0592(clk_11M0592),
      .clk_50M    (clk_50M)
  );

  // CPLD 銝脣隞輻�璅∪�
  cpld_model cpld (
      .clk_uart(clk_11M0592),
      .uart_rdn(uart_rdn),
      .uart_wrn(uart_wrn),
      .uart_dataready(uart_dataready),
      .uart_tbre(uart_tbre),
      .uart_tsre(uart_tsre),
      .data(base_ram_data[7:0])
  );
  // �渲�銝脣隞輻�璅∪�
  uart_model uart (
      .rxd(txd),
      .txd(rxd)
  );
  // BaseRAM 隞輻�璅∪�
  sram_model base1 (
      .DataIO(base_ram_data[15:0]),
      .Address(base_ram_addr[19:0]),
      .OE_n(base_ram_oe_n),
      .CE_n(base_ram_ce_n),
      .WE_n(base_ram_we_n),
      .LB_n(base_ram_be_n[0]),
      .UB_n(base_ram_be_n[1])
  );
  sram_model base2 (
      .DataIO(base_ram_data[31:16]),
      .Address(base_ram_addr[19:0]),
      .OE_n(base_ram_oe_n),
      .CE_n(base_ram_ce_n),
      .WE_n(base_ram_we_n),
      .LB_n(base_ram_be_n[2]),
      .UB_n(base_ram_be_n[3])
  );
  // ExtRAM 隞輻�璅∪�
  sram_model ext1 (
      .DataIO(ext_ram_data[15:0]),
      .Address(ext_ram_addr[19:0]),
      .OE_n(ext_ram_oe_n),
      .CE_n(ext_ram_ce_n),
      .WE_n(ext_ram_we_n),
      .LB_n(ext_ram_be_n[0]),
      .UB_n(ext_ram_be_n[1])
  );
  sram_model ext2 (
      .DataIO(ext_ram_data[31:16]),
      .Address(ext_ram_addr[19:0]),
      .OE_n(ext_ram_oe_n),
      .CE_n(ext_ram_ce_n),
      .WE_n(ext_ram_we_n),
      .LB_n(ext_ram_be_n[2]),
      .UB_n(ext_ram_be_n[3])
  );

  // 隞�隞嗅�頧? BaseRAM
  initial begin
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(BASE_RAM_INIT_FILE, "rb");
    if (!n_File_ID) begin
      n_Init_Size = 0;
      $display("Failed to open BaseRAM init file");
    end else begin
      n_Init_Size = $fread(tmp_array, n_File_ID);
      n_Init_Size /= 4;
      $fclose(n_File_ID);
    end
    $display("BaseRAM Init Size(words): %d", n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
      base1.mem_array0[i] = tmp_array[i][24+:8];
      base1.mem_array1[i] = tmp_array[i][16+:8];
      base2.mem_array0[i] = tmp_array[i][8+:8];
      base2.mem_array1[i] = tmp_array[i][0+:8];
    end
  end

  // 隞�隞嗅�頧? ExtRAM
  initial begin
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(EXT_RAM_INIT_FILE, "rb");
    if (!n_File_ID) begin
      n_Init_Size = 0;
      $display("Failed to open ExtRAM init file");
    end else begin
      n_Init_Size = $fread(tmp_array, n_File_ID);
      n_Init_Size /= 4;
      $fclose(n_File_ID);
    end
    $display("ExtRAM Init Size(words): %d", n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
      ext1.mem_array0[i] = tmp_array[i][24+:8];
      ext1.mem_array1[i] = tmp_array[i][16+:8];
      ext2.mem_array0[i] = tmp_array[i][8+:8];
      ext2.mem_array1[i] = tmp_array[i][0+:8];
    end
  end
endmodule
