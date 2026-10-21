`default_nettype none

module vfb_reset_ctrl_synchronizer #(
   parameter SYNC_LENGTH = 3
) (
   input  wire  clk_in,
   input  wire  clk_out,
   input  wire  rst_in,
   output logic rst_out
);

   // Cut path for analysis with set_false_path, but constrain maximum delay
   // via set_data_delay, which is always used even in spite of set_false_path
   (* altera_attribute = { "\
       -name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; \
       -name SDC_STATEMENT \"set_false_path \
       -to [get_keepers {*vfb_reset_ctrl_synchronizer:*|rst_sync[0]}]\"; \
       -name SDC_STATEMENT \"set_data_delay \
       -get_value_from_clock_period dst_clock_period -value_multiplier 10.0 \
       -to [get_keepers {*vfb_reset_ctrl_synchronizer:*|rst_sync[0]}] \" \
   "} *)

   // Ensure first-hop has 0 combi logic in path from feeding register, to
   // maximise settling time (T_{res}) and thus maximsing MTBF
   logic rst_in_pipe;

   // Synchronizer
   logic [SYNC_LENGTH-1:0] rst_sync;

   always_ff @(posedge clk_in) rst_in_pipe <= rst_in;

   always_ff @(posedge clk_out) begin
      for (int i = 0; i < SYNC_LENGTH; ++i) begin
         if (i == 0) begin
            rst_sync[0] <= rst_in_pipe;
         end else begin
            rst_sync[i] <= rst_sync[i-1];
         end
      end
   end

   assign rst_out = rst_sync[SYNC_LENGTH-1];

endmodule

`default_nettype wire
