class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)

    function new(string name = "fifo_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual fifo_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Failed to get vif")
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

        // The DUT processes the request at the intervening posedge.
        @(negedge vif.clk);
        vif.wr_en <= 0;
        vif.rd_en <= 0;
    endtask
endclass : fifo_driver
