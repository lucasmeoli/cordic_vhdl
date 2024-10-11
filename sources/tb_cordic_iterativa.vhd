library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cordic_iterativa is
end tb_cordic_iterativa;

architecture tb_cordic_iterativa_arq of tb_cordic_iterativa is

    component cordic_iterativa is
        generic(
            BITS: natural := 18
        );
        port( 
            clk   : in std_logic;
            rst   : in std_logic_vector(0 downto 0);
            start : in std_logic_vector(0 downto 0);

            xi : in std_logic_vector(BITS-2 downto 0);
            yi : in std_logic_vector(BITS-2 downto 0);
            zi : in std_logic_vector(BITS-1 downto 0);

            xo : out std_logic_vector(BITS-2 downto 0);
            yo : out std_logic_vector(BITS-2 downto 0);
            zo : out std_logic_vector(BITS-1 downto 0)
        );
    end component;

    constant TB_BITS : natural :=18;

    signal tb_clk: std_logic := '0';
    signal tb_rst: std_logic_vector(0 downto 0) := "0";
    
    signal tb_xi: std_logic_vector(TB_BITS-2 downto 0) := std_logic_vector(to_signed(0,TB_BITS-1));
    signal tb_yi: std_logic_vector(TB_BITS-2 downto 0) := std_logic_vector(to_signed(0,TB_BITS-1));
    signal tb_zi: std_logic_vector(TB_BITS-1 downto 0) := std_logic_vector(to_signed(0,TB_BITS));
                                                                                  -- 131072 = 180°
                                                                                  -- 98304  = 135°
                                                                                  -- 65536  = 90°
                                                                                  -- 43690  = 60°
                                                                                  -- 32768  = 45°
                                                                                  -- 21845  = 30°
                                                                                  -- 18204  = 25°
                                                                                  -- 14563  = 20°

      signal tb_xo: std_logic_vector(TB_BITS-2 downto 0);
      signal tb_yo: std_logic_vector(TB_BITS-2 downto 0);
      signal tb_zo: std_logic_vector(TB_BITS-1 downto 0);

      signal tb_start : std_logic_vector(0 downto 0) := "0";

begin
    tb_clk <= not tb_clk after 10 ns;
    tb_rst <= "1" after 5 ns, "0" after 10 ns;

    -- roto 60° y despues roto 30°
    -- tb_start <= "1" after 40 ns, "0" after 100 ns, "1" after 440 ns, "0" after 500 ns;
    -- tb_xi <= std_logic_vector(to_signed(1000,TB_BITS-1)) after 10 ns, std_logic_vector(to_signed(824,TB_BITS-1)) after 420 ns;
    -- tb_yi <= std_logic_vector(to_signed(0,TB_BITS-1)) after 10 ns, std_logic_vector(to_signed(1427,TB_BITS-1)) after 420 ns;
    -- tb_zi <= std_logic_vector(to_signed(43690,TB_BITS)) after 10 ns, std_logic_vector(to_signed(21845,TB_BITS)) after 420 ns;

    -- roto 45° y roto 90°
    -- tb_start <= "1" after 40 ns, "0" after 100 ns, "1" after 440 ns, "0" after 500 ns;
    -- tb_xi <= std_logic_vector(to_signed(1000,TB_BITS-1)) after 10 ns;
    -- tb_yi <= std_logic_vector(to_signed(0,TB_BITS-1)) after 10 ns;
    -- tb_zi <= std_logic_vector(to_signed(32768,TB_BITS)) after 10 ns, std_logic_vector(to_signed(65536,TB_BITS)) after 420 ns;

    -- roto 135° y roto 180°
    tb_start <= "1" after 40 ns, "0" after 100 ns, "1" after 440 ns, "0" after 500 ns;
    tb_xi <= std_logic_vector(to_signed(1000,TB_BITS-1)) after 10 ns, std_logic_vector(to_signed(-5000,TB_BITS-1)) after 420 ns;
    tb_yi <= std_logic_vector(to_signed(0,TB_BITS-1)) after 10 ns, std_logic_vector(to_signed(-5000,TB_BITS-1)) after 420 ns;
    tb_zi <= std_logic_vector(to_signed(98304,TB_BITS)) after 10 ns, std_logic_vector(to_signed(131072,TB_BITS)) after 420 ns;


    DUT: cordic_iterativa
        generic map(
            BITS => TB_BITS
        )
        port map (
            clk   => tb_clk,
            rst   => tb_rst,
            start => tb_start,
            xi    => tb_xi,
            yi    => tb_yi,
            zi    => tb_zi,
            xo    => tb_xo,
            yo    => tb_yo,
            zo    => tb_zo
        );

end tb_cordic_iterativa_arq;