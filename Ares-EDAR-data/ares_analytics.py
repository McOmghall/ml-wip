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

input = pandas.concat([(lluvias.resample('H') - lluvias.resample('H').mean()) / (lluvias.resample('H').max() - lluvias.resample('H').min())
                       , (mareas.resample('H') - mareas.resample('H').mean()) / (mareas.resample('H').max() - mareas.resample('H').min())
                       , (conductividad.resample('H') - conductividad.resample('H').mean()) / (conductividad.resample('H').max() - conductividad.resample('H').min())]
                    , axis = 1).dropna()
print(input[[0, 1, 2]].values)

perceptron = neurolab.net.newff([[input.min()[0], input.max()[0]], [input.min()[1], input.max()[1]]], [5, 1])
err = perceptron.train(input[[0, 1]].values, input[[2]].values, epochs=2000, goal=1, show=10)

print(err)
print("Ok")

input[3] = perceptron.sim(input[[0, 1]].values)
input[[2, 3]].plot()
plt.show()
