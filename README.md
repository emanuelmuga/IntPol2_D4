# Interpolador D4 IQ

**Programer** : Emanuel Murillo García
**Contact** :   emanuel.murillo@cinvestav.mx | 	emanuel.muga13@gmail.com

**Module Name** : intpol2_D4_IQ_CORE (TOP), Interpolador Cuadratico Diseño IV IQ
**Type** : Verilog module

#### Description : 

Obtine los valores interpolados entre tres datos de entrada, M0, M1, M2. Utilizando solo un multiplicador. Realiza la aproximación con: $$y = p0 + p1*xi + p2*(xi)^2$$. Donde $pi$  son los coeficientes calculados "On-the-fly" y xi el factor de interpolación. 
Se tiene dos entradas, una en Fase (I) y otra en cuadratura (Q).

# Files
- intpol2_D4_IQ_CORE.v  TOP (DUT sin interfaz)  :  [mods\id00001006\hdl\src]
- intpol2_D4_IQ_tb.v  Testbench del CORE  :  [mods\id00001006\hdl\sim]
- intpol2_Frac_IQ_tb_waves.do : waves .do

