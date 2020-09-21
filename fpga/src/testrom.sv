/* Copyright 2018 ETH Zurich and University of Bologna.
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * File: $filename.v
 *
 * Description: Small ROM for testing dma access.
 */

// Auto-generated code
module testrom (
   input  logic         clk_i,
   input  logic         req_i,
   input  logic [63:0]  addr_i,
   output logic [63:0]  rdata_o
);
    localparam int RomSize = 16;

    const logic [RomSize-1:0][63:0] mem = {
        64'h0a0b0c0d_0e0f0000,
        64'h00000000_00000001,
        64'h00000000_00000002,
        64'h00000000_00000003,
        64'h00000000_00000004,
        64'h00000000_00000005,
        64'h00000000_00000006,
        64'h00000000_00000007,
        64'h00000000_00000008,
        64'h00000000_00000009,
        64'h00000000_0000000a,
        64'h00000000_0000000b,
        64'h00000000_0000000c,
        64'h00000000_0000000d,
        64'h00000000_0000000e,
        64'h00000000_0000000f
    };

    logic [$clog2(RomSize)-1:0] addr_q;

    always_ff @(posedge clk_i) begin
        if (req_i) begin
            addr_q <= addr_i[$clog2(RomSize)-1+3:3];
        end
    end

    // this prevents spurious Xes from propagating into
    // the speculative fetch stage of the core
    assign rdata_o = (addr_q < RomSize) ? mem[addr_q] : '0;
endmodule
