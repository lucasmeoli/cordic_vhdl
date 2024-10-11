import numpy as np

def cordic_angles(num_iterations):
    return np.arctan(2.0 ** -np.arange(num_iterations))

def cordic_rotation(x_in, y_in, z_in, num_iterations):
    x = x_in
    y = y_in
    z = z_in
    angles = cordic_angles(num_iterations)

    for i in range(num_iterations):
        if z < 0:
            x_new = x + (y >> i)
            y_new = y - (x >> i)
            z_new = z + angles[i]
        else:
            x_new = x - (y >> i)
            y_new = y + (x >> i)
            z_new = z - angles[i]
        
        x, y, z = x_new, y_new, z_new
    
    return x, y, z

# Entradas
x_in = 19000
y_in = 9500
z_in_degrees = 60
z_in = np.deg2rad(z_in_degrees)  
num_iterations = 16  # Precisión de 16 bits

# Ejecutar el algoritmo CORDIC
x_out, y_out, z_out = cordic_rotation(x_in, y_in, z_in, num_iterations)

# Mostrar los resultados
print(f"Zin radianes: {z_in}")
print(f"Xout: {x_out}")
print(f"Yout: {y_out}")
print(f"Zout (en grados): {np.rad2deg(z_out)}")
