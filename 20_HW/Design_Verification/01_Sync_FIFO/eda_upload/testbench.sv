// Current learning snapshot: agent/env/test/top are not implemented yet.
`include "uvm_macros.svh"
import uvm_pkg::*;

// ---- fifo_if.sv ----
interface fifo_if #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4
) (
    input logic clk
);

    logic                  rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic                  full;
    logic                  empty;

endinterface  //fifo_if


// ---- fifo_seq_item.sv ----
class fifo_seq_item extends uvm_sequence_item;
    `uvm_object_utils(fifo_seq_item)

    rand bit wr_en;
    rand bit rd_en;
    rand bit [31:0] wdata;

    function new(string name = "fifo_seq_item");
        super.new(name);
    endfunction  //new()

endclass  //fifo_seq_item extends uvm_sequence_item


// ---- fifo_write_sequence.sv ----
class fifo_write_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_write_sequence)

    bit [31:0] data = 32'hA5;

    function new(string name = "fifo_write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_seq_item fifo_item;
        fifo_item = fifo_seq_item::type_id::create("write_item");

        start_item(fifo_item);
        fifo_item.wr_en = 1;
        fifo_item.rd_en = 0;
        fifo_item.wdata = data;
        finish_item(fifo_item);
    endtask

endclass : fifo_write_sequence


// ---- fifo_read_sequence.sv ----
class fifo_read_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_read_sequence)

    function new(string name = "fifo_read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_seq_item fifo_item;
        fifo_item = fifo_seq_item::type_id::create("read_item");

        start_item(fifo_item);
        fifo_item.wr_en = 0;
        fifo_item.rd_en = 1;
        fifo_item.wdata = 0;
        finish_item(fifo_item);
    endtask

endclass : fifo_read_sequence


// ---- fifo_sequence.sv ----
class fifo_sequence extends uvm_sequence #(fifo_seq_item);
    `uvm_object_utils(fifo_sequence)

    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_write_sequence write_seq;
        fifo_read_sequence  read_seq;

        write_seq = fifo_write_sequence::type_id::create("write_seq");
        read_seq = fifo_read_sequence::type_id::create("read_seq");

        write_seq.data = 32'hA5;
        write_seq.start(m_sequencer, this);
        read_seq.start(m_sequencer, this);
    endtask

endclass : fifo_sequence


// ---- fifo_sequencer.sv ----
class fifo_sequencer extends uvm_sequencer #(fifo_seq_item);
    `uvm_component_utils(fifo_sequencer)

    function new(string name = "fifo_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

endclass  //fifo_Sequencer extends uvm_sequencer


// ---- fifo_driver.sv ----
class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)

    function new(string name = "fifo_driver", uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    virtual fifo_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Failed to get vif");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        vif.wr_en <= 0;
        vif.rd_en <= 0;
        vif.wdata <= 0;

        wait (vif.rst_n === 1);

        forever begin
            fifo_seq_item fifo_item;
            `uvm_info("DRV", "Wait for item from sqr", UVM_LOW)

            seq_item_port.get_next_item(fifo_item);
            drive_item(fifo_item);
            seq_item_port.item_done();

            `uvm_info("DRV", "Sent item from driver", UVM_LOW)
        end
    endtask

    virtual task drive_item(fifo_seq_item fifo_item);
        @(negedge vif.clk);
        vif.wr_en <= fifo_item.wr_en;
        vif.rd_en <= fifo_item.rd_en;
        vif.wdata <= fifo_item.wdata;

        // @(posedge) -> dut 

        @(negedge vif.clk);
        vif.wr_en <= 0;
        vif.rd_en <= 0;
    endtask

endclass  //fifo_driver extends uvm_driver
