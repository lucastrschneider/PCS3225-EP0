--------------------------------------------------------------------------------
--! @file alu_somador.vhd
--! @brief 8-bit ALU (S1A2)
--! @author Bruno Albertini (balbertini@usp.br)
--! @date 20200605

--! Last submission #1501
--------------------------------------------------------------------------------

-------------------------------------------------------
--! @author balbertini@usp.br
--! @brief 1-bit Full adder
--! @date 20191023
-------------------------------------------------------
entity fulladder is
  port (
    a, b, cin: in bit;
    s, cout: out bit
  );
end entity;
-------------------------------------------------------
architecture structural of fulladder is
  signal axorb: bit;
begin
  axorb <= a xor b;
  s <= axorb xor cin;
  cout <= (axorb and cin) or (a and b);
end architecture;

-------------------------------------------------------
--! @author balbertini@usp.br
--! @brief 8-bit ALU (S1A2)
-------------------------------------------------------
entity alu is
  port (
    A, B : in  bit_vector(3 downto 0); -- inputs
    F    : out bit_vector(3 downto 0); -- output
    S    : in  bit_vector(2 downto 0); -- op selection
    Z    : out bit; -- zero flag
    Ov   : out bit; -- overflow flag
    Co   : out bit -- carry out
    );
end entity alu;
-------------------------------------------------------
architecture structural of alu is
  component fulladder is
    port (
      a, b, cin: in bit;
      s, cout: out bit
    );
  end component;
  signal aluout, bi, res, cout: bit_vector(3 downto 0) := (others=>'0');
begin
  -- inverting b if necessary
  bi <= not(b) when s(2)='1' else b;
  -- full adders chain
  -- first carry-in = operation selector(2)
  fa0: fulladder port map(a(0),bi(0),s(2)   ,res(0),cout(0));
  fa1: fulladder port map(a(1),bi(1),cout(0),res(1),cout(1));
  fa2: fulladder port map(a(2),bi(2),cout(1),res(2),cout(2));
  fa3: fulladder port map(a(3),bi(3),cout(2),res(3),cout(3));
  -- MUX that select the output
  with S select aluout <=
    a and b when "000", -- AND
    a or  b when "001", -- OR
    res     when others; -- sum or sub
  -- Copying temporary signal to output
  F <= aluout;
end architecture structural;
