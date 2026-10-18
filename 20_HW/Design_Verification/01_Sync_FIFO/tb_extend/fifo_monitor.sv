class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)
    uvm_analysis_port #(fifo_seq_item) mon_ap;
    virtual fifo_if vif;

    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Failed to get vif")
        mon_ap = new("mon_ap", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever collect_item();
    endtask

    virtual task collect_item();
        fifo_seq_item item;
        @(posedge vif.clk);
        item = fifo_seq_item::type_id::create("observed_item");
        // DUT uses NBA, so these are the pre-edge request and flags.
        item.rst_n = vif.rst_n;
        item.request_id = vif.request_id;
        item.wr_en = vif.wr_en;
        item.rd_en = vif.rd_en;
        item.wdata = vif.wdata;
        item.full = vif.full;
        item.empty = vif.empty;

        // Read output and resulting flags after DUT has updated.
        // Driver changes at negedge with NBA; monitor reads old inputs here.
        @(negedge vif.clk);
        if (vif.rst_n !== 1'b1) item.rst_n = 0;
        item.rdata = vif.rdata;
        item.full_after = vif.full;
        item.empty_after = vif.empty;
        `uvm_info("MON", $sformatf(
            "id=%0d rst_n=%b req=%b%b accept=%b%b wdata=%08h rdata=%08h flags=%b%b -> %b%b",
            item.request_id, item.rst_n, item.wr_en, item.rd_en,
            item.wr_en && !item.full, item.rd_en && !item.empty,
            item.wdata, item.rdata, item.full, item.empty,
            item.full_after, item.empty_after), UVM_HIGH)
        // Fresh object each cycle. Subscribers treat it as read-only.
        mon_ap.write(item);
    endtask
endclass : fifo_monitor
