module test_vio(
    clk,
    rstn,
    uart_rx
);

input wire clk;
input wire rstn;
input wire uart_rx;

wire [159:0] dout;

vio_0 u_vio_0(
    .clk(clk),
    .probe_in0(dout)
);

uart2sha u_uart2sha(
    .clk(clk),
    .rstn(rstn),
    .uart_rx(uart_rx),
    .busy(),
    .dout(dout),
    .dout_vld()
);

endmodule