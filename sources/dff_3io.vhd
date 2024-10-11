library ieee;
use ieee.std_logic_1164.all;

entity dff_3io is
   generic(
        BITS: natural := 18
   );
   port( 
        rst : in  std_logic_vector(0 downto 0);
        clk : in  std_logic;
        dx  : in  std_logic_vector(BITS-2 downto 0);
        dy  : in  std_logic_vector(BITS-2 downto 0);
        dz  : in  std_logic_vector(BITS-1 downto 0);
        qx  : out std_logic_vector(BITS-2 downto 0);
        qy  : out std_logic_vector(BITS-2 downto 0);
        qz  : out std_logic_vector(BITS-1 downto 0)
   );
end dff_3io;

architecture behavioral of dff_3io is
begin
    process (rst,clk) is
    begin
        if rst = "1" then 
            qx <= (others => '0');
            qy <= (others => '0');
            qz <= (others => '0');
        elsif clk = '1' and clk'event then
            qx <= dx;
            qy <= dy;
            qz <= dz;
        end if;
    end process;
end behavioral;