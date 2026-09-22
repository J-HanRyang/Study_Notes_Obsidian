module arbiter #(
    parameter N = 4
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [N-1:0] req,
    output logic [N-1:0] grant
);

    logic [N-1:0] last_grant;
    logic [N-1:0] masked_req;
    logic [N-1:0] grant_masked;
    logic [N-1:0] grant_unmasked;

    // mask 생성
    assign masked_req = last_grant & req;

    // 각각 Fixed Priority 적용
    assign grant_masked = ;
    assign grant_unmasked = ;

    // grant 생성
    assign grant = masked_req & (~masked_req + 1);

    // last_grant 저장
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) last_grant <= '0;
        else if () last_grant <= ;
    end

endmodule
