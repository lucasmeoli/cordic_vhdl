library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_iterativa is
    generic(
        BITS: natural := 18 --Las etapas equivalen a BITS-2
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
end cordic_iterativa;

architecture cordic_iterativa_arq of cordic_iterativa is
    
    component cordic is
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
    end component;
    
        component dff_3io is
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
    end component;
    
    type z_signals is array (natural range <>) of std_logic_vector(BITS-1 downto 0);  -- 17 bits
    
    constant ATAN  : z_signals(0 to 15) := (("001000000000000000"),  -- 32768
                                            ("000100101110010000"),  -- 19344
                                            ("000010011111101101"),  -- 10221
                                            ("000001010001000100"),  -- 5188
                                            ("000000101000101100"),  -- 2604
                                            ("000000010100010111"),  -- 1303
                                            ("000000001010001100"),  -- 652
                                            ("000000000101000110"),  -- 326
                                            ("000000000010100011"),  -- 163
                                            ("000000000001010001"),  -- 81
                                            ("000000000000101001"),  -- 41 
                                            ("000000000000010100"),  -- 20
                                            ("000000000000001010"),  -- 10
                                            ("000000000000000101"),  -- 5
                                            ("000000000000000011"),  -- 3
                                            ("000000000000000001")); -- 1

    signal contador     : std_logic_vector(BITS-3 downto 0) := (others => '0');
    
    -- Entradas del ffd
    signal xi_ffd : std_logic_vector(BITS-2 downto 0) := (others => '0');
    signal yi_ffd : std_logic_vector(BITS-2 downto 0) := (others => '0');
    signal zi_ffd : std_logic_vector(BITS-1 downto 0) := (others => '0');

    -- Salidas del ffd que son entradas al cordic
    signal xo_ffd : std_logic_vector(BITS-2 downto 0);
    signal yo_ffd : std_logic_vector(BITS-2 downto 0);
    signal zo_ffd : std_logic_vector(BITS-1 downto 0);

    -- Salidas del cordic
    signal xo_cordic : std_logic_vector(BITS-2 downto 0);
    signal yo_cordic : std_logic_vector(BITS-2 downto 0);
    signal zo_cordic : std_logic_vector(BITS-1 downto 0);

    signal atan_aux : std_logic_vector(BITS-1 downto 0);

    type state_type is (IDLE, COUNTING, DONE);
    signal state : state_type := IDLE;

    -- Precordic signals
    signal cuadrante : std_logic_vector(1 downto 0);
    
    signal zi_precordic : std_logic_vector(BITS-1 downto 0);
    signal xi_precordic : std_logic_vector(BITS-2 downto 0);
    signal yi_precordic : std_logic_vector(BITS-2 downto 0);

    -- Precordi Zi    
    function precordic_z (z_in:std_logic_vector; cuad: std_logic_vector) return std_logic_vector is
        variable z_aux : std_logic_vector(BITS-1 downto 0);

        begin
            if cuad = "01" then -- Angulo entre 90 y 180
                z_aux := std_logic_vector(unsigned(z_in) - 2**(BITS-1));
            elsif cuad = "10" then -- Angulo entre -90 y -180
                z_aux := std_logic_vector(unsigned(z_in) + 2**(BITS-1));
            else 
                z_aux := z_in;
            end if;
        return z_aux;
    end function;
    
    -- Precordic
    function precordic (x_in:std_logic_vector; cuad: std_logic_vector) return std_logic_vector is
        variable x_aux : std_logic_vector(BITS-2 downto 0);
        
        begin
            if cuad = "01" or cuad = "10" then -- Angulo entre 90 y 180 o entre -90 y -180
                x_aux := std_logic_vector(unsigned(not(x_in))+1);
            else 
                x_aux := x_in;
            end if;
        return x_aux;
    end function;
begin
    
    cordic_inst: cordic
        generic map(
            BITS => 18
        )
        port map(
            xi    => xo_ffd,
            yi    => yo_ffd,
            zi    => zo_ffd,
            xo    => xo_cordic,
            yo    => yo_cordic,
            zo    => zo_cordic,
            etapa => contador,
            atan  => atan_aux
        );
    

    dff_3io_inst: dff_3io
        port map(
            rst => rst,
            clk => clk,
            dx  => xi_ffd,
            dy  => yi_ffd,
            dz  => zi_ffd,
            qx  => xo_ffd,
            qy  => yo_ffd,
            qz  => zo_ffd
        );

    -- precordic
    cuadrante <= zi(zi'left downto zi'left-1);
    xi_precordic <= precordic(xi, cuadrante); 
    yi_precordic <= precordic(yi, cuadrante); 
    zi_precordic <= precordic_z(zi, cuadrante);

    -- FF con start para saber si rote
    xi_ffd <= xi_precordic when (state = IDLE) else xo_cordic;
    yi_ffd <= yi_precordic when (state = IDLE) else yo_cordic;
    zi_ffd <= zi_precordic when (state = IDLE) else zo_cordic;

    atan_aux <= ATAN(to_integer(unsigned(contador)));

    process(clk)
    begin
        if rst = "1" then
            contador <= (others => '0');
            state <= IDLE;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = "1" then
                        state <= COUNTING;
                    end if;

                when COUNTING =>
                    if unsigned(contador) = 15 then
                        state <= DONE;
                        contador <= (others => '0');
                        xo <= xo_cordic;
                        yo <= yo_cordic;
                        zo <= zo_cordic;
                    else
                        contador <= std_logic_vector(unsigned(contador) + 1);
                        xo <= (others => '0');
                        yo <= (others => '0');
                        zo <= (others => '0');
                    end if;

                when DONE =>
                    if start = "0" then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end cordic_iterativa_arq;