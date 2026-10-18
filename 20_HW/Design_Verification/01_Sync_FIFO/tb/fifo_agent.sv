class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)

    uvm_analysis_port #(fifo_seq_item) mon_ap;
    
    fifo_sequencer sqr;
    fifo_driver    drv;
    fifo_monitor   mon;

    function new(string name = "fifo_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sqr    = fifo_sequencer::type_id::create("sqr", this);
        drv    = fifo_driver::type_id::create("drv", this);
        mon    = fifo_monitor::type_id::create("mon", this);
        mon_ap = new("mon_ap", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port.connect(sqr.seq_item_export);
        mon.mon_ap.connect(mon_ap);
    endfunction

endclass
