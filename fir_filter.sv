// ============================================================
// N-Tap Parameterized FIR Filter — DUT
// UVM-friendly: valid/ready handshake, signed 16-bit I/O
// EDA Playground: paste into "design.sv"
// ============================================================

// ------------------------------------------------------------
// Interface — keeps DUT connections clean for UVM driver/monitor
// ------------------------------------------------------------
interface fir_if (input logic clk, rst_n);
  logic signed [15:0] data_in;
  logic               data_valid;
  logic signed [31:0] data_out;
  logic               out_valid;
endinterface

// ------------------------------------------------------------
// FIR Filter DUT
// KEY FIX: shift register updated with blocking assignments
// inside always_ff so MAC sees the NEW sample in shift_reg[0]
// on the same cycle it arrives — not one cycle later.
// ------------------------------------------------------------
module fir_filter #(
  parameter int N_TAPS = 8,
  parameter int DATA_W = 16,
  parameter int COEF_W = 16,
  parameter int ACC_W  = 32
)(
  input  logic                     clk,
  input  logic                     rst_n,
  input  logic signed [DATA_W-1:0] data_in,
  input  logic                     data_valid,
  output logic signed [ACC_W-1:0]  data_out,
  output logic                     out_valid
);

  // Symmetric low-pass coefficients (8-tap)
  localparam logic signed [COEF_W-1:0] COEFFS [0:N_TAPS-1] = '{
    16'sd256,  16'sd512,  16'sd1024, 16'sd2048,
    16'sd2048, 16'sd1024, 16'sd512,  16'sd256
  };

  // Shift register
  logic signed [DATA_W-1:0] shift_reg [0:N_TAPS-1];

  // Temporary accumulator (blocking — computed combinatorially inside ff)
  logic signed [ACC_W-1:0] acc;

  integer i;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < N_TAPS; i++)
        shift_reg[i] <= '0;
      data_out  <= '0;
      out_valid <= 1'b0;
    end else begin
      out_valid <= 1'b0;
      if (data_valid) begin
        // Shift register update using BLOCKING assignments
        // so shift_reg[0] = data_in immediately for MAC below
        for (i = N_TAPS-1; i > 0; i--)
          shift_reg[i] = shift_reg[i-1];  // blocking
        shift_reg[0] = data_in;            // blocking

        // MAC — now sees updated shift_reg including new data_in
        acc = '0;
        for (i = 0; i < N_TAPS; i++)
          acc = acc + shift_reg[i] * COEFFS[i];

        // Register output
        data_out  <= acc;
        out_valid <= 1'b1;
      end
    end
  end

endmodule
