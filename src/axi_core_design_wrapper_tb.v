`timescale 1 ns / 1 ps
// lib IP_Integrator_Lib
module axi_core_design_wrapper_tb ();
reg ACLK;
reg ARESETN;

initial begin
  ACLK = 1'b0;
  forever begin
    ACLK = #20 ~ACLK;
  end
end

initial begin
  ARESETN = 1'b0;
  repeat (16) @(posedge ACLK);
  #1;
  ARESETN = 1'b1;
  repeat (3000) @(posedge ACLK);
  $finish;
end

axi_core_design axi_core_design_i
       (.ACLK(ACLK),
        .ARESETN(ARESETN));
endmodule
