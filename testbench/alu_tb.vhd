--------------------------------------------------------------------------------
--! @file alu_somador_tb.vhd
--! @brief Testbench for 8-bit ALU (S1A3)
--! @author Bruno Albertini (balbertini@usp.br)
--! @date 20200605
--------------------------------------------------------------------------------
library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.floor;

entity alu_tb is
end entity alu_tb;

architecture dut of alu_tb is
  component  alu is
    port (
      A, B : in  bit_vector(3 downto 0); -- inputs
      F    : out bit_vector(3 downto 0); -- output
      S    : in  bit_vector(2 downto 0); -- op selection
      Z    : out bit; -- zero flag
      Ov   : out bit; -- overflow flag
      Co   : out bit -- carry out
      );
  end component;
  signal A, B, F: bit_vector(3 downto 0) := (others=>'0');
  signal S: bit_vector(2 downto 0) := (others=>'0');
  signal Ze, Ov, Co: bit;
  signal an, bn: integer;
begin
  -- in1, in2, out, selection, flags (zero, overflow, carry-out)
  dut: alu port map (A, B, F, S, Ze, Ov, Co);

  stim: process is
    -- helper function to convert a bit_vector to string
    function to_bstring(bv : bit_vector) return string is
      alias    bv_norm : bit_vector(1 to bv'length) is bv;
      variable b_str_v : string(1 to 3);  -- bit image with quotes around
      variable res_v   : string(1 to bv'length);
    begin
      for idx in bv_norm'range loop
        b_str_v := bit'image(bv_norm(idx));
        res_v(idx) := b_str_v(2);
      end loop;
      return res_v;
    end function;
    -- helper function to print all outputs and expected outputs
    function printall(
      a,b,f:bit_vector(3 downto 0); -- real values of a, b, and c
      aexp,bexp,fexp:integer; -- expected values of a, b, and c
      z,zexp:bit -- real and expected values for z
    ) return string is
    begin
      return LF& -- LF is Line Feed, a newline char
        " A="&to_bstring(a)&" expected "&to_bstring(bit_vector(to_unsigned(aexp,4)))&LF&
        " B="&to_bstring(b)&" expected "&to_bstring(bit_vector(to_unsigned(bexp,4)))&LF&
        " F="&to_bstring(f)&" expected "&to_bstring(bit_vector(to_unsigned(fexp,4)))&LF&
        " Z="&bit'image(z)(2)&" expected "&bit'image(zexp)(2);
    end function;
    -- variables to keep the calculated result
    variable res: integer;
    variable Zexp: bit;
  begin
    report "BOT";
    for an in 0 to 15 loop
      for bn in 0 to 15 loop
          A <= bit_vector(to_unsigned(an,4));
          B <= bit_vector(to_unsigned(bn,4));
          -- AND test
          S <= "000";
          res := to_integer(to_unsigned(an,4) and to_unsigned(bn,4));
          if res=0 then Zexp := '1'; else Zexp := '0'; end if;
          wait for 1 ns;
          assert ((F = bit_vector(to_unsigned(res,4))) and (Ze=Zexp))
          report "Error on A&B: " & printall(A,B,F,an,bn,res,Ze,Zexp)
          severity failure;
          -- OR test
          S <= "001";
          res := to_integer(to_unsigned(an,4) or to_unsigned(bn,4));
          if res=0 then Zexp := '1'; else Zexp := '0'; end if;
          wait for 1 ns;
          assert ((F = bit_vector(to_unsigned(res,4))) and (Ze=Zexp))
          report "Error on A|B: " & printall(A,B,F,an,bn,res,Ze,Zexp)
          severity failure;
          -- + test
          S <= "010";
          res := to_integer(to_unsigned(an,4) + to_unsigned(bn,4));
          if res=0 then Zexp := '1'; else Zexp := '0'; end if;
          wait for 1 ns;
          assert ((F = bit_vector(to_unsigned(res,4))) and (Ze=Zexp))
          report "Error on A+B: " & printall(A,B,F,an,bn,res,Ze,Zexp)
          severity failure;
          -- - test
          S <= "110";
          res := to_integer(to_unsigned(an,4) - to_unsigned(bn,4));
          if res=0 then Zexp := '1'; else Zexp := '0'; end if;
          wait for 1 ns;
          assert ((F = bit_vector(to_unsigned(res,4))) and (Ze=Zexp))
          report "Error on A-B: " & printall(A,B,F,an,bn,res,Ze,Zexp)
          severity failure;
      end loop;
    end loop;

    report "EOT";
    wait;
  end process;
end dut;
