`default_nettype none

/* Reset controller for an intel_vvp_vfb instance
*
* On ANY reset input, will hold both output reset high until a negedge has been
* detected on ALL reset inputs. Then, holds reset high for another
* RESET_LENGTH cycles, before releasing both output resets
*
* mem_clk was chosen for controller logic, as mem_rst_out is to be released
* first
*/
module vfb_reset_ctrl #(
   parameter RESET_CNTR_BITS = 8,
   localparam RESET_LENGTH = 1 << RESET_CNTR_BITS
) (
   input wire mem_clk,  // VFB mem_clk (memory clock)
   input wire main_clk, // VFB main_clk (video clock)

   input wire mem_rst_in,
   input wire main_rst_in,

   output logic mem_rst_out,
   output logic main_rst_out
);

   localparam RESET_LENGTH_W_EXT = $clog2(RESET_LENGTH) + 1;

   logic main_rst_in_mem_clk;

   // synchronise main_rst_in to mem_clk
   //
   // assumes main_rst_in persists longer than a single mem_clk period
   vfb_reset_ctrl_synchronizer #(
      .SYNC_LENGTH(3)
   ) main_rst_in_sync_inst (
      .clk_in (main_clk),
      .clk_out(mem_clk),
      .rst_in (main_rst_in),
      .rst_out(main_rst_in_mem_clk)
   );

   logic [RESET_LENGTH_W_EXT-1:0] rst_cntr;

   // Reset extender
   always_ff @(posedge mem_clk) begin
      if (main_rst_in_mem_clk || mem_rst_in) begin
         rst_cntr <= RESET_LENGTH - 2;  // deliberate -2; count from 254 to -1
      end else begin
         if (!rst_cntr[RESET_LENGTH_W_EXT-1]) begin
            rst_cntr <= rst_cntr - 1;
         end
      end
   end

   assign mem_rst_out = !rst_cntr[RESET_LENGTH_W_EXT-1];

   vfb_reset_ctrl_synchronizer #(
      .SYNC_LENGTH(3)
   ) main_rst_out_sync_inst (
      .clk_in (mem_clk),
      .clk_out(main_clk),
      .rst_in (mem_rst_out),
      .rst_out(main_rst_out)
   );

endmodule

`default_nettype wire
