`default_nettype none
module hazard_controller (
    input  wire  if_flush_i,
    input  wire  id_flush_i,
    input  wire  ex_flush_i,
    input  wire  mem_flush_i,
    input  wire  wb_flush_i,
    input  wire  if_stall_i,
    input  wire  id_stall_i,
    input  wire  ex_stall_i,
    input  wire  mem_stall_i,
    input  wire  wb_stall_i,
    output logic _if_flush_o,
    output logic if_id_flush_o,
    output logic id_ex_flush_o,
    output logic ex_mem_flush_o,
    output logic mem_wb_flush_o,
    output logic _if_stall_o,
    output logic if_id_stall_o,
    output logic id_ex_stall_o,
    output logic ex_mem_stall_o,
    output logic mem_wb_stall_o
);
  always_comb begin
    _if_flush_o = 0;
    if_id_flush_o = 0;
    id_ex_flush_o = 0;
    ex_mem_flush_o = 0;
    mem_wb_flush_o = 0;
    _if_stall_o = 0;
    if_id_stall_o = 0;
    id_ex_stall_o = 0;
    ex_mem_stall_o = 0;
    mem_wb_stall_o = 0;
    if (wb_flush_i) begin
      _if_flush_o = 1;
      if_id_flush_o = 1;
      id_ex_flush_o = 1;
      ex_mem_flush_o = 1;
      mem_wb_flush_o = 1;
    end else if (mem_flush_i) begin
      _if_flush_o = 1;
      if_id_flush_o = 1;
      id_ex_flush_o = 1;
      ex_mem_flush_o = 1;
    end else if (ex_flush_i) begin
      _if_flush_o   = 1;
      if_id_flush_o = 1;
      id_ex_flush_o = 1;
    end else if (id_flush_i) begin
      _if_flush_o   = 1;
      if_id_flush_o = 1;
    end else if (if_flush_i) begin
      _if_flush_o = 1;
    end else if (wb_stall_i) begin
      _if_stall_o = 1;
      if_id_stall_o = 1;
      id_ex_stall_o = 1;
      ex_mem_stall_o = 1;
      mem_wb_stall_o = 1;
    end else if (mem_stall_i) begin
      _if_stall_o = 1;
      if_id_stall_o = 1;
      id_ex_stall_o = 1;
      ex_mem_stall_o = 1;
      mem_wb_flush_o = 1;
    end else if (ex_stall_i) begin
      _if_stall_o = 1;
      if_id_stall_o = 1;
      id_ex_stall_o = 1;
      ex_mem_flush_o = 1;
    end else if (id_stall_i) begin
      _if_stall_o   = 1;
      if_id_stall_o = 1;
      id_ex_flush_o = 1;
    end else if (if_stall_i) begin
      _if_stall_o   = 1;
      if_id_flush_o = 1;
    end
  end
endmodule
