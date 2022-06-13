//sha_1 core;

module sha_1_core(
    clk,
    rstn,
    din,
    din_vld,
    use_pre_cv,
    sha_1_end,
    busy,
    dout,
    dout_vld  
);

input wire clk;
input wire rstn;
input wire [31:0] din;
input wire din_vld;
input wire use_pre_cv;          //1-use last h0~h1 cal value;
input wire sha_1_end;           //all block cal done;
output reg busy;                //module in cal;
output wire [159:0] dout; 
output reg dout_vld; 

parameter [31:0] H0_INIT = 32'h67452301,
                 H1_INIT = 32'hEFCDAB89,
                 H2_INIT = 32'h98BADCFE,
                 H3_INIT = 32'h10325476,
                 H4_INIT = 32'hC3D2E1F0;

/*------------------------------w(t) gen------------------------------*/
reg w_busy;
reg [6:0] cnt_w;
reg [31:0] w_reg[0:15];
wire [31:0] w_next_xor;
wire [31:0] w_next;

//cal new w(t);
assign w_next_xor = w_reg[13] ^ w_reg[8] ^ w_reg[2] ^ w_reg[0];
assign w_next = {w_next_xor[30:0], w_next_xor[31]};

//set cycle busy;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_busy <= 1'b0;
    end
    else if (din_vld) begin
        w_busy <= 1'b1;
    end
    else if (cnt_w == 7'd79) begin
        w_busy <= 1'b0;
    end
    else begin
        w_busy <= w_busy;
    end
end

//counter 80 cycle;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt_w <= 7'd0;
    end
    else if (cnt_w == 7'd79) begin
        cnt_w <= 7'd0;
    end
    else if (din_vld || w_busy) begin
        cnt_w <= cnt_w + 1'b1;
    end
end

//set w_reg[15], din input;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_reg[15] <= 32'd0;
    end
    else if (din_vld) begin
        w_reg[15] <= din;
    end
    else if (w_busy) begin
        w_reg[15] <= w_next;
    end
end

//gen w_reg shift;
generate
    genvar i;
    for (i=0; i<15; i=i+1) begin: gen_w_reg
    always @(posedge clk) begin
        if (w_busy) begin
            w_reg[i] <= w_reg[i+1];
        end
    end
    end    
endgenerate

/*-------------------------A/B/C/D/E update-------------------------*/
reg din_vld_d;
reg [1:0] k_f_state;
reg [31:0] a_reg;
reg [31:0] b_reg;
reg [31:0] c_reg;
reg [31:0] d_reg;
reg [31:0] e_reg;
reg [31:0] f_t;
reg [31:0] k_t;
reg a_e_busy;
reg a_e_busy_d;
reg [31:0] h0;
reg [31:0] h1;
reg [31:0] h2;
reg [31:0] h3;
reg [31:0] h4;
wire din_vld_posedge;
wire [31:0] a_next;
wire a_e_busy_negedge;

//din_vld posedge detc;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        din_vld_d <= 1'b0;
    end
    else begin
        din_vld_d <= din_vld;
    end
end
assign din_vld_posedge = ((!din_vld_d) & (din_vld));

//k(t), f(t) state change;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        k_f_state <= 2'd0;
    end
    else if (din_vld_posedge) begin
        k_f_state <= 2'd0;
    end
    else if (cnt_w == 7'd20) begin
        k_f_state <= 2'd1;
    end
    else if (cnt_w == 7'd40) begin
        k_f_state <= 2'd2;
    end
    else if (cnt_w == 7'd60) begin
        k_f_state <= 2'd3;
    end
    else begin
        k_f_state <= k_f_state;
    end
end

//switch f_t k_t cal;
always @(*) begin
    case (k_f_state)
        2'd0: begin
            f_t = (b_reg & c_reg) | ((~b_reg) & d_reg);
            k_t = 32'h5A827999;
        end
        2'd1: begin
            f_t = b_reg ^ c_reg ^ d_reg;
            k_t = 32'h6ED9EBA1;
        end
        2'd2: begin
            f_t = (b_reg & c_reg) | (b_reg & d_reg) | (c_reg & d_reg);
            k_t = 32'h8F1BBCDC;
        end
        2'd3: begin
            f_t = b_reg ^ c_reg ^ d_reg;
            k_t = 32'hCA62C1D6;
        end
        default: begin
        end
    endcase
end

//cal next A;
assign a_next = ({a_reg[26:0], a_reg[31:27]} + f_t + e_reg + w_reg[15] + k_t);

//A~E cycle cal;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        a_e_busy <= 1'b0;
    end
    else if (din_vld | w_busy) begin
        a_e_busy <= 1'b1;
    end
    else begin
        a_e_busy <= 1'b0;
    end
end

//a_e_busy negedge detc;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        a_e_busy_d <= 1'b0;
    end
    else begin
        a_e_busy_d <= a_e_busy;
    end
end
assign a_e_busy_negedge = ((!a_e_busy) & a_e_busy_d); 

//initial & update A~E;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        a_reg <= H0_INIT;
        b_reg <= H1_INIT;
        c_reg <= H2_INIT;
        d_reg <= H3_INIT;
        e_reg <= H4_INIT;
    end
    else if (din_vld_posedge) begin
        if (use_pre_cv) begin
            a_reg <= h0;
            b_reg <= h1;
            c_reg <= h2;
            d_reg <= h3;
            e_reg <= h4;
        end
        else begin
            a_reg <= H0_INIT;
            b_reg <= H1_INIT;
            c_reg <= H2_INIT;
            d_reg <= H3_INIT;
            e_reg <= H4_INIT;
        end
    end
    else if (a_e_busy) begin
        a_reg <= a_next;
        b_reg <= a_reg;
        c_reg <= {b_reg[1:0], b_reg[31:2]};
        d_reg <= c_reg;
        e_reg <= d_reg;
    end
end

//initial & update h0~h4;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        h0 <= H0_INIT;
        h1 <= H1_INIT;
        h2 <= H2_INIT;
        h3 <= H3_INIT;
        h4 <= H4_INIT;
    end
    else if (din_vld_posedge) begin
        if (!use_pre_cv) begin
            h0 <= H0_INIT;
            h1 <= H1_INIT;
            h2 <= H2_INIT;
            h3 <= H3_INIT;
            h4 <= H4_INIT;
        end
    end
    else if (a_e_busy_negedge) begin
        if (sha_1_end) begin
            h0 <= h0 + a_reg;
            h1 <= h1 + b_reg;
            h2 <= h2 + c_reg;
            h3 <= h3 + d_reg;
            h4 <= h4 + e_reg;
        end
        else begin
            h0 <= a_reg;
            h1 <= b_reg;
            h2 <= c_reg;
            h3 <= d_reg;
            h4 <= e_reg;
        end
    end
end

//output dout;
assign dout = {h0, h1, h2, h3, h4};

//output dout_vld;
always @(posedge clk  or negedge rstn) begin
    if (!rstn) begin
        dout_vld <= 1'b0;
    end
    else if (a_e_busy_negedge) begin
        dout_vld <= 1'b1;
    end
    else begin
        dout_vld <= 1'b0;
    end
end

//output busy;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        busy <= 1'b0;
    end
    else if (din_vld_posedge) begin
        busy <= 1'b1;
    end
    else if (a_e_busy_negedge) begin
        busy <= 1'b0;
    end
end

endmodule