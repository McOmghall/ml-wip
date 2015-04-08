import pandas
import os
from locale import *
import locale
import matplotlib.pyplot as plt
import neurolab 


locale.setlocale(LC_NUMERIC, '')

fs = pandas.read_csv('./Ares.csv', sep=';', encoding='cp1252', parse_dates=[1,3,5,7,9,11], dayfirst=True)

# Separar por pares de columnas
materia_organica 	= pandas.DataFrame(fs[[fs.columns[0], fs.columns[1]]])
conductividad 		= pandas.DataFrame(fs[[fs.columns[2], fs.columns[3]]])
amonio		 	= pandas.DataFrame(fs[[fs.columns[4], fs.columns[5]]])
solidos			= pandas.DataFrame(fs[[fs.columns[6], fs.columns[7]]])
temperatura		= pandas.DataFrame(fs[[fs.columns[8], fs.columns[9]]])
lluvias			= pandas.DataFrame(fs[[fs.columns[10], fs.columns[11]]])
mareas                  = pandas.DataFrame(fs[[fs.columns[12], fs.columns[13]]])
oxigeno                 = pandas.DataFrame(fs[[fs.columns[14], fs.columns[15]]])

#Clean trailing NaNs
materia_organica 	= materia_organica.dropna()
conductividad 		= conductividad.dropna()
amonio			= amonio.dropna()
solidos			= solidos.dropna()
temperatura		= temperatura.dropna()
lluvias			= lluvias.dropna()
mareas			= mareas.dropna()
oxigeno			= oxigeno.dropna()

#Convertir a fechas la primera columna
materia_organica[materia_organica.columns[0]] 	= pandas.to_datetime(materia_organica[materia_organica.columns[0]], dayfirst=True)
conductividad[conductividad.columns[0]] 	= pandas.to_datetime(conductividad[conductividad.columns[0]], dayfirst=True)
amonio[amonio.columns[0]] 			= pandas.to_datetime(amonio[amonio.columns[0]], dayfirst=True)
solidos[solidos.columns[0]] 			= pandas.to_datetime(solidos[solidos.columns[0]], dayfirst=True)
temperatura[temperatura.columns[0]] 		= pandas.to_datetime(temperatura[temperatura.columns[0]], dayfirst=True)
lluvias[lluvias.columns[0]]		 	= pandas.to_datetime(lluvias[lluvias.columns[0]], dayfirst=True)
mareas[mareas.columns[0]]		 	= pandas.to_datetime(mareas[mareas.columns[0]], dayfirst=True)
oxigeno[oxigeno.columns[0]]		 	= pandas.to_datetime(oxigeno[oxigeno.columns[0]], dayfirst=True)


#Convertir a float la segunda
materia_organica[materia_organica.columns[1]] 	= materia_organica[materia_organica.columns[1]].map(locale.atof)
conductividad[conductividad.columns[1]] 	= conductividad[conductividad.columns[1]].map(locale.atof)
amonio[amonio.columns[1]] 			= amonio[amonio.columns[1]].map(locale.atof)
solidos[solidos.columns[1]] 			= solidos[solidos.columns[1]].map(locale.atof)
temperatura[temperatura.columns[1]] 		= temperatura[temperatura.columns[1]].map(locale.atof)
lluvias[lluvias.columns[1]] 			= lluvias[lluvias.columns[1]].map(locale.atof)
mareas[mareas.columns[1]] 			= mareas[mareas.columns[1]].map(locale.atof)
oxigeno[oxigeno.columns[1]] 			= oxigeno[oxigeno.columns[1]].map(locale.atof)


lluvias                 = lluvias[lluvias[lluvias.columns[1]] >= 0]


materia_organica        = pandas.Series(materia_organica[materia_organica.columns[1]].values, materia_organica[materia_organica.columns[0]])
conductividad           = pandas.Series(conductividad[conductividad.columns[1]].values, conductividad[conductividad.columns[0]])
amonio                  = pandas.Series(amonio[amonio.columns[1]].values, amonio[amonio.columns[0]])
solidos                 = pandas.Series(solidos[solidos.columns[1]].values, solidos[solidos.columns[0]])
temperatura             = pandas.Series(temperatura[temperatura.columns[1]].values, temperatura[temperatura.columns[0]])
lluvias                 = pandas.Series(lluvias[lluvias.columns[1]].values, lluvias[lluvias.columns[0]])
mareas                  = pandas.Series(mareas[mareas.columns[1]].values, mareas[mareas.columns[0]])
oxigeno                 = pandas.Series(oxigeno[oxigeno.columns[1]].values, oxigeno[oxigeno.columns[0]])


# Learn dataset
# Base dataset
input = pandas.concat([(lluvias.resample('H') - lluvias.resample('H').mean()) / (lluvias.resample('H').max() - lluvias.resample('H').min())
             , (mareas.resample('H') - mareas.resample('H').mean()) / (mareas.resample('H').max() - mareas.resample('H').min())
             , (conductividad.resample('H') - conductividad.resample('H').mean()) / (conductividad.resample('H').max() - conductividad.resample('H').min())]
             , axis = 1).dropna()

min_lluvias = input.min()[0]
max_lluvias = input.max()[0]
min_mareas  = input.min()[1]
max_mareas  = input.max()[1]

# Modified dataset with 8 2-hour windows for each parameter
input = pandas.concat([input[[0]].shift(1), input[[0]].shift(3), input[[0]].shift(5), input[[0]].shift(7), input[[0]].shift(9), input[[0]].shift(11), input[[0]].shift(13), input[[0]].shift(15)
	, input[[1]].shift(1), input[[1]].shift(3), input[[1]].shift(5), input[[1]].shift(7), input[[1]].shift(9), input[[1]].shift(11), input[[1]].shift(13), input[[1]].shift(15),	
	input[[2]]], axis = 1, ignore_index=True).dropna()


#Saved hourly interpolated dataset to file, to convert data to 
# 5 hour windows (i.e. 5 hour lluvias + 5 hour mareas to predict this hour conductividad)
import time
input.to_csv(time.strftime("%Y%m%d-%H%M%S") + "clean.csv")

output = input[[16]]
input  = input.drop(16, axis=1)

print(output)

# Create network with 3 layers, 10 inputs and random initialized
net = neurolab.net.newff([[min_lluvias, max_lluvias]
		, [min_lluvias, max_lluvias]
		, [min_lluvias, max_lluvias]
		, [min_lluvias, max_lluvias]
		, [min_lluvias, max_lluvias]
		, [min_lluvias, max_lluvias]
		, [min_lluvias, max_lluvias]
		, [min_lluvias, max_lluvias]
		, [min_mareas, max_mareas]
		, [min_mareas, max_mareas]
		, [min_mareas, max_mareas]
		, [min_mareas, max_mareas]
		, [min_mareas, max_mareas]
		, [min_mareas, max_mareas]
		, [min_mareas, max_mareas]
		, [min_mareas, max_mareas]]
	, [20, 10, 10, 1])

# Train network
error = net.train(input.values, output.values, epochs=500, show=50, goal=0.02)

net.save(time.strftime("%Y%m%d-%H%M%S") + ".rnasa")

# Simulate network
output['sim'] = net.sim(input.values)
error = output[16] - output['sim']

# Plot result
from pylab import *

figure, axes = subplots(nrows=2, ncols=1)

print(figure)
print(axes)
output.plot(ax=axes[0])
error.plot(ax=axes[1])

show()
