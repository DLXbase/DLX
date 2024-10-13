library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity RWMEM_TB is
end entity RWMEM_TB;

architecture TB of RWMEM_TB is
    -- Component declaration of the DRAM module
    component RWMEM is
        generic(
            file_path: string;
            file_path_init: string;
            Data_size : natural := 32;
            Instr_size: natural := 32;
            RAM_DEPTH:  natural := 128;
            data_delay: natural := 0
        );
        port (
            CLK            : in std_logic;
            RST            : in std_logic;
            ADDR           : in std_logic_vector(Instr_size - 1 downto 0);
            ENABLE         : in std_logic;
            WRITENOTREAD   : in std_logic;
            IN_DATA        : in std_logic_vector(Data_size-1 downto 0);
            DATA_READY     : out std_logic;
            OUT_DATA       : out std_logic_vector(Data_size-1 downto 0)
        );
    end component;

    -- Signals for driving the DUT (Device Under Test)
    signal CLK         : std_logic := '0';
    signal RST         : std_logic := '0';
    signal ADDR        : std_logic_vector(31 downto 0);
    signal ENABLE      : std_logic := '0';
    signal READNOTWRITE: std_logic := '0';
    signal IN_DATA     : std_logic_vector(31 downto 0);
    signal DATA_READY  : std_logic;
    signal OUT_DATA    : std_logic_vector(31 downto 0);

    -- Clock period (assume 10 ns for simplicity)
    constant CLK_PERIOD: time := 10 ns;

begin
    -- Instantiate the DRAM component
    UUT: RWMEM
        generic map(
            file_path => "/home/ms24.11/Desktop/DLX/DLX(HW_CU)/output_file.mem",
            file_path_init => "/home/ms24.11/Desktop/DLX/DLX(HW_CU)/test.asm.mem",
            Data_size => 32,
            Instr_size => 32,
            RAM_DEPTH => 128,
            data_delay => 0
        )
        port map(
            CLK => CLK,
            RST => RST,
            ADDR => ADDR,
            ENABLE => ENABLE,
            READNOTWRITE => READNOTWRITE,
            IN_DATA => IN_DATA,
            DATA_READY => DATA_READY,
            OUT_DATA => OUT_DATA
        );

    -- Clock generation process
    CLK_GEN: process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process to test the DRAM
    STIMULUS: process
    begin
        -- Reset the system
        RST <= '1';
        wait for 20 ns;
        RST <= '0';
        wait for 20 ns;

        -- Write data to the DRAM
        ENABLE <= '1';
        WRITENOTREAD <= '1';  -- Write operation
        ADDR <= x"00000000";  -- Address 0
        IN_DATA <= x"01234567";
        wait for 40 ns;

        -- Write another value at a different address
        ADDR <= x"00000001";  -- Address 1
        IN_DATA <= x"FEDCBA98";
        wait for 40 ns;

        -- Read the first value from DRAM
        WRITENOTREAD <= '0';  -- Read operation
        ADDR <= x"00000000";  -- Address 0
        wait for 40 ns;
        
        -- Check the output data (OUT_DATA should now contain the first written value)
        assert OUT_DATA = x"01234567"
        report "Test failed at address 0" severity error;

        -- Read the second value from DRAM
        ADDR <= x"00000001";  -- Address 1
        wait for 40 ns;

        -- Check the output data (OUT_DATA should now contain the second written value)
        assert OUT_DATA = x"FEDCBA98"
        report "Test failed at address 1" severity error;

        -- End simulation
        wait;
    end process;

end architecture TB;
