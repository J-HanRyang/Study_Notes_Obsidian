class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    uvm_analysis_port #(fifo_seq_item) mon_ap;
    virtual fifo_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Failed to get vif")
        mon_ap = new("mon_ap", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            collect_item();
        end
    endtask

    virtual task collect_item();
        fifo_seq_item fifo_item;
        @(posedge vif.clk);
        if (vif.rst_n !== 1'b1) return;

        fifo_item = fifo_seq_item::type_id::create("fifo_item");
        fifo_item.wr_en = vif.wr_en;
        fifo_item.rd_en = vif.rd_en;
        fifo_item.wdata = vif.wdata;
        fifo_item.full = vif.full;
        fifo_item.empty = vif.empty;

        @(negedge vif.clk);
        if (vif.rst_n !== 1'b1) return;

        fifo_item.rdata = vif.rdata;
        mon_ap.write(fifo_item);
    endtask
endclass : fifo_monitor
