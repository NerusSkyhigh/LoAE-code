set terminal wxt size 700,600

set multiplot layout 2,1 columnsfirst


#################
## Bode Plot   ##
#################
set title "Bode Plot Low Pass Filter"
set xrange [50:25000]
set yrange [0.01:5]

set xlabel 'f [Hz]'
set ylabel 'Gain [dB]'

set grid
set logscale xy
plot 'data/ampl.csv' using ($1):($2/1.240) title 'Gain' with linespoints lw 0.5 ps 0.5


unset title
set xlabel 'f [Hz]'
set ylabel 'Phase [deg]'

set grid
unset logscale y
set yrange [-180:5]

plot 'data/phase.csv' using ($1):(-360*$1* 1e-6*$2) title 'Phase' with linespoints lw 0.5 ps 0.5


pause -1 "Hit return to continue"
