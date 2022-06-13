`timescale 1ns/1ns
module sha_1_core_tb;

reg clk;
reg rstn;
reg [31:0] din;
reg din_vld;
reg use_pre_cv;
reg sha_1_end;
wire busy;
wire [159:0] dout;
wire dout_vld;

sha_1_core u_sha_1_core(
    .clk(clk),
    .rstn(rstn),
    .din(din),
    .din_vld(din_vld),
    .use_pre_cv(use_pre_cv),
    .sha_1_end(sha_1_end),
    .busy(busy),
    .dout(dout),
    .dout_vld(dout_vld)
);

initial clk = 1'b1;
always #5 clk = ~clk;

initial begin
    rstn = 1'b0;
    #20
    rstn = 1'b1;
    #10
    din_vld = 1'b0;
    use_pre_cv = 1'b0;
    sha_1_end = 1'b1;
    #15
    din_vld = 1'b1;
    din = 32'hf1f1f1ce;
    #5
    repeat(12) begin
        #10;
        din = 32'hf1f1f1f2;
    end
    #10
    din = 32'h80000000;
    #10
    din = 32'h0;
    #10
    din = 32'h000001A0;
    #10
    din_vld = 1'b0;
    #2000
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule
