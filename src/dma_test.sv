// Test module that reads a DMA address every 100 ms
// and writes the value to the LEDs on the board.
module dma_test (
    input  clk_i,
    input  rst_ni,
    output reg [7:0] leds_o,
    output ariane_axi::req_t axi_req_o,
    input  ariane_axi::resp_t axi_resp_i
);

    reg [27:0] count = 0;
    reg busy = 1'b0;

    parameter [2:0] await_begin = 0, 
                    await_send = 1,
                    request_read = 2,
                    await_read = 3,
                    await_handshake = 4,
                    process_read = 5;
    
    reg [2:0] state;


    always @(posedge clk_i) begin
        if (~rst_ni) begin
            state <= await_begin;
            count <= 0;
            leds_o <= 0;
            busy <= 0;

            // Initialize Address Read channel
            axi_req_o.ar_valid  <= 0;
            // axi_req_o.ar.addr   <= 64'h7000_0000;
            // axi_req_o.ar.addr   <= 64'h0;
            // axi_req_o.ar.addr   <= 64'h0001_0000;
            axi_req_o.ar.addr   <= 64'hBC000000;
            axi_req_o.ar.id     <= 4'b1;
            axi_req_o.ar.len    <= 0;
            axi_req_o.ar.size   <= 3;
            axi_req_o.ar.burst  <= 0;
            axi_req_o.ar.lock   <= 0;
            axi_req_o.ar.cache  <= 0;
            axi_req_o.ar.prot   <= 0;
            axi_req_o.ar.qos    <= 0;
            axi_req_o.ar.region <= 0;

            axi_req_o.aw_valid <= 0;            
            axi_req_o.w_valid  <= 0;
            axi_req_o.b_ready  <= 0;
            axi_req_o.r_ready  <= 0;
        end

        else begin
            case(state)

                // Wait 5 seconds before the first request
                await_begin : begin
                    if(count == 28'hEE6B280) begin
                        state <= await_send;
                        count <= 0;
                    end
                    else begin
                        state <= await_begin;
                        count <= count + 1;
                    end
                end

                // Wait 1 s between requests
                await_send : begin
                    if(count == 28'h2FAF080) begin
                        state <= request_read;
                        busy <= 1;
                        count <= 0;
                    end 
                    else begin
                        state <= await_send;
                        busy <= 0;
                        count <= count + 1;
                    end
                end

                request_read : begin
                    axi_req_o.ar_valid <= 1'b1;
                    state <= await_handshake;
                end

                await_handshake : begin
                    if(axi_resp_i.ar_ready == 1'b1) begin
                        axi_req_o.ar_valid <= 1'b0;
                        state <= await_read;
                    end
                    else begin
                        axi_req_o.ar_valid <= 1'b1;
                        state <= await_handshake;
                    end
                end

                await_read : begin
                    if(axi_resp_i.r_valid == 1'b1) begin
                        state <= process_read;
                        axi_req_o.r_ready <= 1'b0;
                    end
                    else begin
                        state <= await_read;
                        axi_req_o.r_ready <= 1'b1;
                    end
                end

                process_read : begin
                    leds_o <= axi_resp_i.r.data[7:0];
                    state <= await_send;
                    busy <= 0;
                end
            endcase
        end
    end

    xlnx_ila_axi ila_axi_dma (
        .clk(clk_i),

        // AR Channel
        .probe0(axi_req_o.ar.id),
        .probe1(axi_req_o.ar.addr),
        .probe2(axi_req_o.ar.len), 
        .probe3(axi_req_o.ar.size), 
        .probe4(axi_req_o.ar.burst),
        .probe5(axi_req_o.ar.lock),
        .probe6(axi_req_o.ar.cache),
        .probe7(axi_req_o.ar.prot),
        .probe8(axi_req_o.ar.qos),
        .probe9(axi_req_o.ar.region),
        .probe10(axi_req_o.ar_valid),
        .probe11(axi_resp_i.ar_ready),

        // R Channel
        .probe12(axi_resp_i.r.id),
        .probe13(axi_resp_i.r.data),
        .probe14(axi_resp_i.r.resp),
        .probe15(axi_resp_i.r.last),
        .probe16(axi_resp_i.r_valid),
        .probe17(axi_req_o.r_ready),

        // Non-AXI 1-bit
        .probe18(rst_ni),
        .probe19(busy),
        .probe20(state[2]),
        .probe21(state[1]),
        .probe22(state[0]),

        // Non-AXI 32-bit
        .probe23(count),
        .probe24(0),
        .probe25(0),
        .probe26(0),
        .probe27(0)
    );

endmodule
