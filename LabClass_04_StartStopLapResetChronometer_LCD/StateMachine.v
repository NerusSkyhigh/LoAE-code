module StateMachine(input clk_in,
                    input PULSE_A, input PULSE_B,

                    output reg [2:0] state, // Current state. The nomenclature is the same as in the assignment
                    output reg reset_pulse);


  reg OLD_PULSE_A, OLD_PULSE_B;

  always @(posedge clk_in) begin
    if( (PULSE_A & ~OLD_PULSE_A) | (PULSE_B & ~OLD_PULSE_B)) begin
      reset_pulse <= 0;
    end

    if( state == 0 ) begin
      // State 0
      if(PULSE_A & ~OLD_PULSE_A) begin
        state <= 2;
        // Do something
      end /* else if(PULSE_B & ~OLD_PULSE_B) begin
        // Do nothing :(
      end */
    end else if (state == 1) begin
      // State 1
      if(PULSE_A & ~OLD_PULSE_A) begin
        state <= 2;
        // Do something
      end else if(PULSE_B & ~OLD_PULSE_B) begin
        state <= 0;
        reset_pulse <= 1;
        // Reset pulse!
      end
    end else if (state == 2) begin
      // State 2
      if(PULSE_A & ~OLD_PULSE_A) begin
        state <= 1;
        // Do something
      end else if(PULSE_B & ~OLD_PULSE_B) begin
        state <= 3;
        // Do something
      end
    end else if (state == 3) begin
      // State 3
      if(PULSE_A & ~OLD_PULSE_A) begin
        state <= 4;
        // Do something
      end else if(PULSE_B & ~OLD_PULSE_B) begin
        state <= 2;
        // Do something
      end
    end else if (state == 4) begin
      // State 4
      if(PULSE_A & ~OLD_PULSE_A) begin
        state <= 3;
        // Do something
      end else if(PULSE_B & ~OLD_PULSE_B) begin
        state <= 1;
        // Do something
      end
    end else begin
      // State 5-8, why are you even here?
      // Fallback to a default state
      state <= 0;
    end

    OLD_PULSE_A <= PULSE_A;
    OLD_PULSE_B <= PULSE_B;
  end

endmodule
