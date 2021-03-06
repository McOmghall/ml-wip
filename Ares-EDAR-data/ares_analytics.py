# -*- coding: utf-8 -*-
import pandas
import os
from locale import *
import locale
import matplotlib.pyplot as plt
import neurolab 
from pylab import *
import numpy as np


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

#Añadir indice timeseries
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
input = pandas.concat([
             lluvias.resample('15Min') / lluvias.max() - lluvias.mean() / lluvias.max() 
             , mareas.resample('15Min').interpolate() / mareas.max() - mareas.mean() / mareas.max()
             , conductividad.resample('15Min') / conductividad.max() - conductividad.mean() / conductividad.max()
             ]
             , axis = 1)




min_lluvias = input.min()[0]
max_lluvias = input.max()[0]
min_mareas  = input.min()[1]
max_mareas  = input.max()[1]

print [min_lluvias, max_lluvias, min_mareas, max_mareas]

# Modified dataset with 8 2-hour windows for each parameter
param_array = pandas.DataFrame() 
for i in range(1, 41) :
  param_array = pandas.concat([param_array, input[[0]].shift(i * 2)], axis=1, ignore_index=True)

for i in range(1, 21) :
  param_array= pandas.concat([param_array, input[[1]].shift(i * 2)], axis=1, ignore_index=True)


input = pandas.concat([param_array, input[[2]]], axis = 1, ignore_index=True).dropna()
output = input.pop(input.columns[-1])


#Saved hourly interpolated dataset to file, to convert data to 
# 5 hour windows (i.e. 5 hour lluvias + 5 hour mareas to predict this hour conductividad)
import time

figure, axes = subplots(nrows=2, ncols=1)

output.plot(ax=axes[0])
input.plot(ax=axes[1])

show()

max_and_min = np.array([[min_lluvias, max_lluvias]]*40 + [[min_mareas, max_mareas]]*20)

# Create network with 3 layers, 10 inputs and random initialized
net = neurolab.net.newff(max_and_min, [5, 20, 10, 1])


# Train network
print net.trainf
print net.errorf
net.init()

output_train = np.array(output.values)
output_train = np.reshape(output_train, (output_train.size, 1))

print "input dimensions {}".format(input.ndim)
print "output dimensions {}".format(output_train.ndim)

print "train"

error = net.train(input.values, output_train, epochs=100, show=5, goal=0.02)

print error

# Simulate network

output_train = pandas.DataFrame() 
output_train['data'] = output.values
output_train['sim'] = net.sim(input.values)

error = output_train['data'] - output_train['sim']

print output_train
print error

# Plot result

figure, axes = subplots(nrows=2, ncols=1)

output_train.plot(ax=axes[0])
error.plot(ax=axes[1])

show()

#load test set
fs = pandas.read_csv('./Ares_test.csv', sep=';', encoding='cp1252', parse_dates=[1,3,5], dayfirst=True)

# Separar por pares de columnas
lluvias_test	    = pandas.DataFrame(fs[[fs.columns[0], fs.columns[1]]]).dropna()
mareas_test         = pandas.DataFrame(fs[[fs.columns[2], fs.columns[3]]]).dropna()
conductividad_test  = pandas.DataFrame(fs[[fs.columns[4], fs.columns[5]]]).dropna()

#Convertir a fechas la primera columna
lluvias_test[lluvias_test.columns[0]] 	          = pandas.to_datetime(lluvias_test[lluvias_test.columns[0]], dayfirst=True)
mareas_test[mareas_test.columns[0]] 	          = pandas.to_datetime(mareas_test[mareas_test.columns[0]], dayfirst=True)
conductividad_test[conductividad_test.columns[0]] = pandas.to_datetime(conductividad_test[conductividad_test.columns[0]], dayfirst=True)

#Convertir a float la segunda
lluvias_test[lluvias_test.columns[1]] 	          = lluvias_test[lluvias_test.columns[1]].map(locale.atof)
mareas_test[mareas_test.columns[1]] 	          = mareas_test[mareas_test.columns[1]].map(locale.atof)
conductividad_test[conductividad_test.columns[1]] = conductividad_test[conductividad_test.columns[1]].map(locale.atof)

#Añadir indice timeseries
lluvias_test        = pandas.Series(lluvias_test[lluvias_test.columns[1]].values, lluvias_test[lluvias_test.columns[0]])
mareas_test         = pandas.Series(mareas_test[mareas_test.columns[1]].values, mareas_test[mareas_test.columns[0]])
conductividad_test  = pandas.Series(conductividad_test[conductividad_test.columns[1]].values, conductividad_test[conductividad_test.columns[0]])


input_test = pandas.concat([
             lluvias_test.resample('15Min') / lluvias_test.max() - lluvias_test.mean() / lluvias_test.max() 
             , mareas_test.resample('15Min').interpolate() / mareas_test.max() - mareas_test.mean() / mareas_test.max()
             , conductividad_test.resample('15Min') / conductividad_test.max() - conductividad_test.mean() / conductividad_test.max()
             ]
             , axis = 1)

param_array_test = pandas.DataFrame() 
for i in range(1, 41) :
  param_array_test = pandas.concat([param_array_test, input_test[[0]].shift(i * 2)], axis=1, ignore_index=True)

for i in range(1, 21) :
  param_array_test = pandas.concat([param_array_test, input_test[[1]].shift(i * 2)], axis=1, ignore_index=True)

input_test  = pandas.concat([param_array_test, input_test[[2]]], axis = 1, ignore_index=True).dropna()
output_test = input_test.pop(input_test.columns[-1])
