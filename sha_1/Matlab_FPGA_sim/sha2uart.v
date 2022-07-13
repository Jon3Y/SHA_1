module sha2uart(
    clk,
    rstn,
    uart_rx,
    uart_tx
);

input wire clk;
input wire rstn;
input wire uart_rx;
output wire uart_tx;

wire [159:0] dout;
wire dout_vld;
wire tx_done;
wire [7:0] data_tx;

reg send_en;
reg [4:0] cnt;
reg [159:0] dout_r;

// vio_0 u_vio_0(
//     .clk(clk),
//     .probe_in0(dout)
// );

uart2sha u_uart2sha(
    .clk(clk),
    .rstn(rstn),
    .uart_rx(uart_rx),
    .busy(),
    .dout(dout),
    .dout_vld(dout_vld)
);

uart_byte_tx u_uart_byte_tx(
    .clk(clk),
    .rstn(rstn),
    .send_en(send_en),
    .data(data_tx),
    .baud_set(3'd0),
    .uart_tx(uart_tx),
    .tx_done(tx_done),
    .uart_state()
);

//uart_tx;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        send_en <= 1'b0;
    end
    else if (cnt==5'd20) begin
        send_en <= 1'b0;
    end
    else if (dout_vld) begin
        send_en <= 1'b1;
    end
    else begin
        send_en <= send_en;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt <= 5'd0;
    end
    else if (cnt==5'd20) begin
        cnt <= 5'd0;
    end
    else if (tx_done) begin
        cnt <= cnt + 1'b1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dout_r <= 160'd0;
    end
    else if (dout_vld) begin
        dout_r <= dout;
    end
    else if (tx_done) begin
        dout_r <= (dout_r << 8);
    end
    else begin
        dout_r <= dout_r;
    end
end

assign data_tx = dout_r[159:152];

endmodule