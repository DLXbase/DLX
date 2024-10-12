library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_IRAM is
end entity;

architecture test of tb_IRAM is

  constant RAM_DEPTH : integer := 48;
  constant I_SIZE : integer := 32;

  -- Signals to connect to the IRAM entity
  signal Rst  : std_logic;
  signal Addr : std_logic_vector(I_SIZE - 1 downto 0);
  signal Dout : std_logic_vector(I_SIZE - 1 downto 0);

  -- Instantiate the IRAM component
  component IRAM
    generic (
      RAM_DEPTH : integer := 48;
      I_SIZE : integer := 32
    );
    port (
      Rst  : in  std_logic;
      Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
      Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );
  end component;

begin

  -- Instantiate IRAM
  uut: IRAM
    generic map (
      RAM_DEPTH => RAM_DEPTH,
      I_SIZE => I_SIZE
    )
    port map (
      Rst => Rst,
      Addr => Addr,
      Dout => Dout
    );

  -- Test process to stimulate inputs
  stimulus_proc: process
    variable addr_value : integer := 0;
  begin
    -- Apply reset
	wait for 5 ns;
    Rst <= '1';
    wait for 10 ns;
    Rst <= '0';
    wait for 10 ns;

    -- Test read addresses
    for addr_value in 0 to RAM_DEPTH - 1 loop
      Addr <= std_logic_vector(to_unsigned(addr_value, I_SIZE));
      wait for 10 ns;
      --report "Address: " & integer'image(addr_value) & " Data: " & std_logic_vector'image(Dout);
    end loop;

    -- Stop simulation
    wait;
  end process stimulus_proc;

end architecture test;
