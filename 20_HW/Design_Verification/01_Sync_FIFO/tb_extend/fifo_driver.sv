class fifo_driver extends uvm_driver #(fifo_seq_item);
    `uvm_component_utils(fifo_driver)
    virtual fifo_if vif;
    int unsigned completed_count = 0;

    function new(string name = "fifo_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Failed to get vif")
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_seq_item item;
        vif.rst_n <= 0;
        vif.wr_en <= 0;
        vif.rd_en <= 0;
        vif.wdata <= 0;
        vif.request_id <= 0;
        apply_reset();

        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            completed_count++;
            seq_item_port.item_done();
        end
    endtask

    virtual task apply_reset();
        // Driver is the only reset owner, including initial reset.
        vif.rst_n <= 0;
        vif.wr_en <= 0;
        vif.rd_en <= 0;
        repeat (3) @(negedge vif.clk);
        vif.rst_n <= 1;
    endtask

    virtual task drive_item(fifo_seq_item item);
        @(negedge vif.clk);
        vif.request_id <= completed_count + 1;
        if (item.do_reset) begin
            apply_reset();
        end else begin
            vif.wr_en <= item.wr_en;
            vif.rd_en <= item.rd_en;
            vif.wdata <= item.wdata;
            @(negedge vif.clk);
            vif.wr_en <= 0;
            vif.rd_en <= 0;
        end
        `uvm_info("DRV", $sformatf("id=%0d reset=%0b wr=%0b rd=%0b data=%08h",
                                   completed_count + 1, item.do_reset,
                                   item.wr_en, item.rd_en, item.wdata),
                  UVM_HIGH)
    endtask
endclass : fifo_driver
