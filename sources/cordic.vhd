library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic is
    generic(
        BITS: natural := 18
    );
    port( 
        etapa : in std_logic_vector(BITS-3 downto 0);
        atan  : in std_logic_vector(BITS-1 downto 0);

        xi : in std_logic_vector(BITS-2 downto 0);
        yi : in std_logic_vector(BITS-2 downto 0);
        zi : in std_logic_vector(BITS-1 downto 0);

        xo : out std_logic_vector(BITS-2 downto 0);
        yo : out std_logic_vector(BITS-2 downto 0);
        zo : out std_logic_vector(BITS-1 downto 0)
    );
end cordic;

architecture cordic_arq of cordic is
    signal di : std_logic_vector(0 downto 0); 

    signal xi_aux   : std_logic_vector(BITS-2 downto 0);
    signal yi_aux   : std_logic_vector(BITS-2 downto 0);
    signal atan_aux : std_logic_vector(BITS-1 downto 0);

    signal xi_shift : std_logic_vector(BITS-2 downto 0);
    signal yi_shift : std_logic_vector(BITS-2 downto 0);

begin
    -- Determino el MSB del angulo de entrada
    di <= zi(zi'left downto zi'left);

    -- X --
    xi_shift <= std_logic_vector(shift_right(signed(xi), to_integer(unsigned(etapa))));
    xi_aux <= xi_shift when di = "0" else not(xi_shift);
    xo <= std_logic_vector(unsigned(xi) + unsigned(yi_aux) + unsigned(not(di)));

    -- Y --
    yi_shift <= std_logic_vector(shift_right(signed(yi), to_integer(unsigned(etapa))));
    yi_aux <= yi_shift when di = "1" else not(yi_shift);
    yo <= std_logic_vector(unsigned(yi) + unsigned(xi_aux) + unsigned(di));

    -- Z --
    atan_aux <= atan when di = "1" else not(atan);
    zo <= std_logic_vector(unsigned(zi) + unsigned(atan_aux) + unsigned(not(di)));
end cordic_arq;