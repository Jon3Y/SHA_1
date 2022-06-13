module uart2sha(
    clk,
    rstn,
    uart_rx,
    busy,
    dout,
    dout_vld
);

input wire clk;
input wire rstn;
input wire uart_rx;
output wire busy;             
output wire [159:0] dout; 
output wire dout_vld;

wire [7:0] data_rx;
wire rx_done;
wire [31:0] fifo_out;
wire full;
wire empty;
wire pop;
reg [3:0] rx_cnt;
reg [31:0] data2fifo;
reg push;
reg pop_p;

ila_0 u_ila_0(
	.clk(clk), 
	.probe0(pop_p), 
	.probe1(pop), 
	.probe2(fifo_out),
    .probe3(full), 
	.probe4(empty)
);

uart_byte_rx u_uart_byte_rx(
    .clk(clk),
    .rstn(rstn),
    .uart_rx(uart_rx),
    .baud_set(3'd0),
    .data_byte(data_rx),
    .rx_done(rx_done)
);

sync_fifo u_sync_fifo(
    .clk(clk),
    .rstn(rstn),
    .push(push),
    .pop(pop),
    .din(data2fifo),
    .dout(fifo_out),
    .full(full),
    .empty(empty)
);

sha_1_core u_sha_1_core(
    .clk(clk),
    .rstn(rstn),
    .din(fifo_out),
    .din_vld(pop),
    .use_pre_cv(1'b0),
    .sha_1_end(1'b1),
    .busy(busy),
    .dout(dout),
    .dout_vld(dout_vld)  
);

//uart receive counter;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rx_cnt <= 4'd0;
    end
    else if (rx_cnt == 4'd4) begin
        rx_cnt <= 4'd0;
    end
    else if (rx_done) begin
        rx_cnt <= rx_cnt + 1'b1;
    end
end

//8bit rxdata to 32bit rxdata;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data2fifo <= 32'd0;
    end
    else if (rx_done) begin
        data2fifo <= {data2fifo[23:0], data_rx[7:0]};
    end
end

//push to fifo en;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        push <= 1'b0;
    end
    else if (rx_cnt == 4'd4) begin
        push <= 1'b1;
    end
    else begin
        push <= 1'b0;
    end
end

//pop fifo to empty;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        pop_p <= 1'b0;
    end
    else if (full) begin
        pop_p <= 1'b1;
    end
    else if (empty) begin
        pop_p <= 1'b0;
    end
    else begin
        pop_p <= pop_p;
    end
end
assign pop = (pop_p & (!empty));

endmodule