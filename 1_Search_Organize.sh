#!/bin/bash

cd || { echo "Failure, no such directory"; exit 1; } #перехордим в домашний каталог, в противном случае сообщение об ошибке

function task {				# функция для обработки файлов в директории
for f in "$dir1"/*			# цикл для перебора файлов
do
	if test -d "$f" ; then  # проверка - является ли файл директорией (аналогично "[[]]" )
		dir1=$f			# переход на уровень ниже
		task			# рекурсивный вызов функции для обработки файлов во вложенной директории
	else	
		local file
		file="${f##*/}"		
# выделение имени файла с расширением из абсолютного пути
		
		local name
		name="${file%.[^.]*}"		
# выделение имени файла без расширения с помощью регулярного выражения; можно также $(echo "$filename" | sed 's/\.[^.]*$//')

		local extension
		extension="${f##*.}"		
# выделение расширения файла; 
#можно также
		#local extension=$(echo "$file" | sed 's/^.*\.//') #с помощью sed

		local lastchange
		lastchange=$(ls -Rl "$f" | awk '{print $6, $7, $8}') #$8 ставит время, если в это году, в противном случае ставит год
#можно также:
		#local lastchange=$(date -Rr "$f") #выводить время последнего изменения в соответствии с RFC-2822
#можно также:
		#local lastchange=$(stat -c %y "$f") #пример: 2019-09-23 21:56:05.492022112 +0300

		local size
		size=$(du -k "$f" | awk '{print $1}') 
#размер в Кб, -m размер в мб, awk выводит только первое поле; 
#можно также: 
		#local size=$(wc -c "$f" | awk '{print$1}') #получение размера файла в байтах (выделение первого аргумента команды wc -c)

		local duration
		duration=$(ffprobe -i "$f" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal) 
#получение длины видео с помощью библиотеки ffmpeg
#можно также: 
		#local duration=$(ffmpeg -i "$f" 2>&1 | grep Duration | awk '{print $2}')  #компактнее, но с запятой в конце записи 

		echo -e "$name \t $extension \t $lastchange \t $size "kb" \t $duration" >> parser.xls		# составление строки вывода для файла .xls
		dir1=$dir		#возврат в первоначальную директорию
	fi
done
}

rm "$HOME/parser.xls"		# удаление выходного файла, если существует
echo -n "Write a full path to the directory:"		# вывод в командную строку предложения о вводе нужной папки для перебора
read -r dir		# считывание данных из командной строки
dir1=$dir		# переменная для использования в функции
task		# вызов функции
