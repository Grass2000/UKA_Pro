#!/system/bin/sh

clear
dir="/data/local/binary"
export PATH=/data/local/binary:$PATH
#export LD_LIBRARY_PATH="/data/local/binary/lib"
#PS3=" =>: "
/data/local/binary/lib/busybox find /data/local/UnpackerSystem/gen_keys -maxdepth 1 -empty -exec busybox rm -rf {} \; 2>/dev/null
/data/local/binary/lib/busybox find /data/local/UnpackerSystem/extract_keys -maxdepth 1 -empty -exec busybox rm -rf {} \; 2>/dev/null

config="config/$pack_d"

free_place() {
	unset get_size
	unset get_size_print

	echo
	echo
	echo ".....Введите желаемый размер свободного места для собираемого образа в мегабайтах:"
	echo
	read a && set -- "$a"
	if [ $(echo $?) -eq 0 ]; then
		if busybox test "$(busybox expr "$a" \* "1" 2>/dev/null)"; then
			get_size="$(busybox expr "$a" \* 1024 \* 1024 / 4096 \* 4096)"
			get_size_print="$a"
			set -- "$get_size"
		else
			get_size="0"
			get_size_print="0"
			set -- "$get_size"
		fi
	else
		echo
		echo ".....Ошибка!"
		echo
	fi
	clear
	echo
	echo ".....Установлен желаемый размер свободного места для собираемого образа ~ "$get_size_print" mb"
	echo
	return
}

nn1() {

	echo
	echo "     Выбор папки сохранения образа    "
	echo "     -----------------------------    "
	echo
	echo ".....При вводе 0, папка сохранения: /data/local/UnpackerSuper/output"
	echo ".....При вводе 1, папка сохранения: /data/local/UnpackerSuper"
	echo ".....Введите 0, 1, или свой путь к папке сохранения образа..."
	#echo "  например: 0"
	#echo "  например: /sdcard/test"
	#echo "  пример ввода: /storage/F960-18E7"
	echo
	read h && if [ "$h" = "0" ]; then
		outdir=/data/local/UnpackerSystem
		set -- $outdir

		clear
		echo
		echo "     Установлена папка сохранения выходного образа:"
		echo "     $outdir"
	elif [ "$h" = "1" ]; then
		outdir=/data/local/UnpackerSuper
		set -- $outdir

		clear
		echo
		echo "     Установлена папка сохранения выходного образа:"
		echo "     $outdir"
	elif [ -d "$h" ]; then
		outdir=$h
		set -- $outdir

		clear
		echo
		echo "     Установлена папка сохранения выходного образа:"
		echo "     $outdir"
	else
		clear
		echo
		echo ".....Папки сохранения не существует!"
		nn
		return
	fi
	return
}

inf_space_menu() {
	free_space="$(busybox df -h "$outdir" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
	echo "    В папке свободно: "$free_space""
	return
}

qsn() {
	if [ -f /data/local/binary/path_list.txt ]; then
		v=$(for a in $(busybox cat /data/local/binary/path_list.txt); do

			echo "$a"
		done)

		set -- $v

		if [ ! -z "$v" ]; then
			clear
			echo
			echo ".....Выберите выходную папку из списка в файле /data/local/binary/path_list.txt: "
			echo
			select menu in $v "/data/local/UnpackerSystem"; do
				case $REPLY in
				[1-9]*)
					i="$#"
					#j="$#"
					let i=i+1
					#let j=j+2
					file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
					if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
						if [ -d "$file" ]; then
							clear
							outdir="$file"
							set -- $outdir

						else
							clear
							outdir="/data/local/UnpackerSystem"
							set -- $outdir
							echo
							echo ".....Папки $file не существует!"
						fi
						return
						break
					elif [ "$REPLY" == "$i" ]; then
						clear
						#main_menu
						outdir="/data/local/UnpackerSystem"
						set -- $outdir
						return
						break
					else
						clear
						#echo
						#echo "      Вводите цифры, соответствующие меню."
						outdir="/data/local/UnpackerSystem"
						set -- $outdir
						return
						break
					fi
					break
					;;
				*)
					clear
					#echo
					#echo "      Вводите цифры, соответствующие меню."
					outdir="/data/local/UnpackerSystem"
					set -- $outdir
					return
					break
					;;
				esac
			done
		else
			clear
			echo
			echo ....."В файле path_list.txt нет записанных путей."
			echo
			outdir="/data/local/UnpackerSystem"
			set -- $outdir
			return
		fi
	else
		clear
		echo
		echo ....."Нет файла /data/local/binary/path_list.txt!"
		echo
		outdir="/data/local/UnpackerSystem"
		set -- $outdir
		return
	fi
	return
}

nn() {

	echo
	echo "     Выбор папки сохранения образа    "
	echo "     -----------------------------    "
	echo
	#echo ".....При вводе 0, папка сохранения: /data/local/UnpackerSystem"
	echo ".....При нажатии \"Enter\", папка сохранения /data/local/UnpackerSystem..."
	echo ".....При вводе 0, выбор папки из списка в файле /data/local/binary/path_list.txt..."
	echo
	echo ".....Нажмите \"Enter\", введите 0 или свой путь к папке сохранения образа..."
	echo
	read h && if [ "$h" = "0" ]; then

		qsn #функция выбора папки из списка.
		#set -- $outdir
		#mkdir "$outdir" 2> /dev/null

		#clear
		echo
		echo "    Установлена папка сохранения выходного образа:"
		echo "    $outdir"
		inf_space_menu
	elif [ -d "$h" -o -d /"$h" -a ! -z "$h" ]; then
		outdir=/"$(echo "$h" | busybox sed 's!^/!!')"
		set -- $outdir
		make_ext4fs -l 10485760 "$outdir"/testuka >/dev/null
		if busybox test -s "$outdir"/testuka; then

			clear
			echo
			echo "    Установлена папка сохранения выходного образа:"
			set -- $outdir
			echo "    $outdir"
			inf_space_menu
			busybox rm -f "$outdir"/testuka 2>/dev/null
		else
			clear
			echo
			echo "    \"$outdir\" недоступен для сохранения образа!"
			echo
			echo "    Установлена папка сохранения выходного образа:"
			outdir=/data/local/UnpackerSystem
			set -- $outdir
			mkdir "$outdir" 2>/dev/null
			echo "    $outdir"
			inf_space_menu
			busybox rm -f "$outdir"/testuka 2>/dev/null
		fi
	else
		clear
		echo
		echo "....Внимание! Папки сохранения не существует!"
		echo
		echo "    Установлена папка сохранения выходного образа:"
		outdir=/data/local/UnpackerSystem
		set -- $outdir
		mkdir "$outdir" 2>/dev/null
		echo "    $outdir"
		inf_space_menu
		return
	fi
	return
}

nnnnn() {

	echo
	echo "     Выбор папки сохранения образа    "
	echo "     -----------------------------    "
	echo
	echo ".....При вводе 0, папка сохранения: /data/local/UnpackerSystem"
	echo ".....Введите 0, или свой путь к папке сохранения образа..."
	echo
	read h && if [ "$h" = "0" ]; then
		outdir=/data/local/UnpackerSystem
		set -- $outdir

		clear
		echo
		echo "     Установлена папка сохранения выходного образа:"
		echo "     $outdir"
	elif [ -d "$h" -o -d /"$h" ]; then
		outdir=/"$(echo "$h" | busybox sed 's!^/!!')"
		set -- $outdir
		make_ext4fs -l 10485760 "$outdir"/testuka >/dev/null
		#if [ $(echo $?) -eq 0 ]; then
		if busybox test -s "$outdir"/testuka; then

			clear
			echo
			echo "     Установлена папка сохранения выходного образа:"
			set -- $outdir
			echo "     $outdir"
			busybox rm -f "$outdir"/testuka 2>/dev/null
		else
			clear
			echo
			echo "    \"$outdir\" недоступен для сохранения образа!"
			echo
			echo "    Установлена папка сохранения выходного образа:"
			outdir=/data/local/UnpackerSystem
			set -- $outdir
			echo "    $outdir"
			busybox rm -f "$outdir"/testuka 2>/dev/null
		fi
	else
		outdir="$h"
		set -- $outdir

		clear
		echo
		echo ".....Error! Папки сохранения не существует!"
		nnnnn
		return
	fi
	return
}

check_status() {

	make_ext4fs -s -J -T -1 -l "$i" -a /"$pack_d" tmp.img "$pack_d" &>/dev/null
	if [ $(echo $?) -eq 0 ]; then
		gg=1
		return
	else
		gg=0
		return
	fi
	return
}

check_size_img() {
	#cd /data/local/UnpackerSystem
	echo
	echo ".....Определение размера для сборки..."
	echo

	#i="$(avbtool add_hashtree_footer --partition_size "$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)" --do_not_generate_fec --calc_max_image_size)"

	i="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"

	#i=$(busybox cat "$config"/"$pack_d"_size.txt)

	while check_status; do
		if [ "$gg" -eq 1 ]; then
			if busybox test -s "$config"/"$pack_d"_avb.img; then
				c="$(avbtool add_hashtree_footer --partition_size "$i" --do_not_generate_fec --calc_max_image_size)"
				v="$(avbtool add_hashtree_footer --partition_size "$c" --do_not_generate_fec --calc_max_image_size)"

				until busybox test "$i" -lt "$v"; do
					v="$(busybox expr "$v" \+ "$get_add")"
					c="$(busybox expr "$c" \+ "$get_add")"
				done
				size_new="$(busybox expr "$c" / 4096 \* 4096 \+ "$get_size")"
			else
				size_new="$(busybox expr "$i" / 4096 \* 4096 \+ "$get_size")"
			fi
			busybox rm -f tmp.img
			break
		else
			i="$(busybox expr "$i" \+ "$get_add")"
		fi
	done
	return
}

ext_check() {
	file_ext="$1"

	if [ ! -z "$(busybox hexdump -C -n 20000 "$file_ext" | busybox grep -Eo '3a ff 26 ed|30 50 4c 41|4d 4f 54 4f|e2 e1 f5 e0|28 b5 2f fd' 2>/dev/null)" -o ! -z "$(busybox hexdump -C -n 2000 "$file_ext" | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" -o ! -z "$(busybox hexdump -C -n 2000 "$file_ext" | busybox grep -o "[.]cms" 2>/dev/null)" ]; then
		return 0
	else
		return 1
	fi
	return
}

ext_checkkk() {
	file_ext="$1"

	if [ ! -z "$(busybox hexdump -C -n 2000 "$file_ext" | busybox grep '3a ff 26 ed')" -o ! -z "$(busybox hexdump -C -n 2000 "$file_ext" | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" -o ! -z "$(busybox hexdump -C -n 20000 "$file_ext" | busybox grep -o "30 50 4c 41")" -o ! -z "$(busybox hexdump -C -n 20000 "$file_ext" | busybox grep -o "4d 4f 54 4f" 2>/dev/null)" -o ! -z "$(busybox hexdump -C -n 2000 "$file_ext" | busybox grep -o "[.]cms" 2>/dev/null)" ]; then
		return 0
	else
		return 1
	fi
	return
}

ext_check_super() {
	file_ext="$1"
	if [ ! -z "$(busybox hexdump -C -n 2000 "$file_ext" | busybox grep '3a ff 26 ed')" -o ! -z "$(busybox hexdump -C -n 2000 "$file_ext" | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" ]; then
		return 0
	else
		return 1
	fi
	return
}

check_mount() {
	[ -z "$(busybox mount | busybox grep "/data/local" | busybox grep -vi "AIK")" ] && return 0 || return 1
}

my_size_add() {
	clear
	real_size_orig="$(cat "$config"/"$pack_d"_size.txt)"
	real_size_orig_mb=$(busybox expr "$real_size_orig" / 1024 / 1024)
	echo
	echo ".....Оригинальный размер образа ~ "$real_size_orig_mb" mb"
	echo ".....Введите размер в mb, который хотите добавить к образу:"
	echo
	read a && set -- "$a"
	if [ $(echo $?) -eq 0 ]; then
		#real_size_orig="$(cat "$config"/"$pack_d"_size.txt)"
		#real_size_orig_mb=$(busybox expr "$real_size_orig" / 1024 / 1024)
		size_add=$(busybox expr "$a" \* 1024 \* 1024 / 4096 \* 4096)
		r_size=$(busybox expr "$real_size_orig" + "$size_add")
		real_size=$(busybox expr "$r_size" / 1024 / 1024)
		set -- "$r_size"

		fff_add
		return
		echo
	else
		echo
		echo ".....Ошибка!"
		echo
		my_size_add
		return
	fi
	return
}

fff_add() {
	clear
	if [ "$r_size" != 0 ]; then
		echo
		echo "...Оригинальный размер образа ~ "$real_size_orig_mb" mb"
		echo "...Собрать образ с размером ~ ${real_size} mb?"
		echo
	#else
	#echo
	#echo "...Введённый размер не кратен \"4096\", собрать образ с размером: $r_size байт?"
	#echo
	fi
	select img in "Да" "Нет, ввести другой размер" "Выход в главное меню"; do
		case $REPLY in
		1)
			set -- "$r_size"
			if [ ! -s "$config"/"$pack_d"*_avb.img ]; then
				#set -- "$b"
				#busybox cp -f "$config"/"$pack_d"*_avb.img "$config"/"$pack_d"_myavb.img
				#cat $file_sh > "$config"/"$pack_d"_gsize.sh
				#else
				busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
			fi
			. $file_size
			main_menu
			break
			;;
		2)
			clear
			my_size_add
			return
			break
			;;
		3)
			clear
			main_menu
			return
			break
			;;
		*)
			clear
			echo
			echo "      Вводите цифры, соответствующие этому меню."
			fff_add
			return
			break
			;;
		esac
	done
	return
}

my_size() {
	clear
	echo
	echo ".....Введите размер в байтах:"
	echo
	read a && set -- "$a"
	if [ $(echo $?) -eq 0 ]; then
		r_size=$(busybox expr "$a" / 4096 \* 4096)
		set -- "$r_size"

		fff
		return
		echo
	else
		echo
		echo ".....Ошибка!"
		echo
		my_size
		return
	fi
	return
}

fff() {
	clear
	if [ "$a" = "$r_size" ]; then
		echo
		echo "...Собрать образ с размером: $r_size байт?"
		echo
	else
		echo
		echo "...Введённый размер не кратен \"4096\", собрать образ с размером: $r_size байт?"
		echo
	fi
	select img in "Да" "Нет, ввести другой размер" "Выход в главное меню"; do
		case $REPLY in
		1)
			set -- "$r_size"
			if [ ! -s "$config"/"$pack_d"*_avb.img ]; then
				#set -- "$b"
				#busybox cp -f "$config"/"$pack_d"*_avb.img "$config"/"$pack_d"_myavb.img
				#cat $file_sh > "$config"/"$pack_d"_gsize.sh
				#else
				busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
			fi
			. $file_size
			main_menu
			break
			;;
		2)
			clear
			my_size
			return
			break
			;;
		3)
			clear
			main_menu
			return
			break
			;;
		*)
			clear
			echo
			echo "      Вводите цифры, соответствующие этому меню."
			fff
			return
			break
			;;
		esac
	done
	return
}

pack_dat() {
	cd /data/local/UnpackerSystem
	dir=/data/local/binary
	d=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | sed 's!./!!'); do
		if [ -f "config/"$a"/"$a"_file_contexts" ]; then
			echo "$a"
		fi
	done)

	set -- $d

	if [ ! -z "$d" ]; then
		echo
		echo ".....Выберите папку для сборки:"
		echo
		select menu in $d "Выход в главное меню"; do
			case $REPLY in
			[1-9]*)
				i="$#"

				let i=i+1

				file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
				if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
					clear
					pack_d="$file"
					config="config/$pack_d"

					size=100
					#. ${dir}/pack_img_dat
					. $file_size
					main_menu
					return
					break
				elif [ "$REPLY" -eq "$i" ]; then
					clear
					main_menu
					return
					break
				else
					clear
					echo
					echo " Вводите цифры, соответствующие меню."
					pack_dat
					return
					break
				fi
				break
				;;
			*)
				clear
				echo
				echo " Вводите цифры, соответствующие меню."
				pack_dat
				return
				break
				;;
			esac
		done
	else
		clear
		echo
		echo ....."В \"$PWD\" нет доступных папок для сборки."
		echo
		main_menu
		return
	fi
	return
}

pack_dat_my() {
	cd /data/local/UnpackerSystem
	dir=/data/local/binary
	d=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
		if [ -f "config/"$a"/"$a"_file_contexts" ]; then
			echo "$a"
		fi
	done)

	set -- $d

	if [ ! -z "$d" ]; then
		echo
		echo ".....Выберите папку для сборки:"
		echo
		select menu in $d "Выход в главное меню"; do
			case $REPLY in
			[1-9]*)
				i="$#"

				let i=i+1

				file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
				if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
					clear
					pack_d="$file"
					config="config/$pack_d"

					size=111
					set -- $size
					if [ -f ./"$config"/"$pack_d"*_avb.img ]; then
						file_sh=./"$config"/"$pack_d"*_pack_avb_sparse.sh
					else
						file_sh=./"$config"/"$pack_d"*_pack_sparse.sh
					fi
					#file_size=${dir}/pack_img_dat
					if [ "$size_add" == "1" ]; then
						my_size_add
					else
						my_size
					fi
					return

					main_menu
					return
					break
				elif [ "$REPLY" -eq "$i" ]; then
					clear
					main_menu
					return
					break
				else
					clear
					echo
					echo " Вводите цифры, соответствующие меню."
					pack_dat_my
					return
					break
				fi
				break
				;;
			*)
				clear
				echo
				echo " Вводите цифры, соответствующие меню."
				pack_dat_my
				return
				break
				;;
			esac
		done
	else
		clear
		echo
		echo ....."В \"$PWD\" нет доступных папок для сборки."
		echo
		main_menu
		return
	fi
	return
}

pack_dat_new() {

	free_place

	cd /data/local/UnpackerSystem
	dir=/data/local/binary
	d=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
		if [ -f "config/"$a"/"$a"_file_contexts" ]; then
			echo "$a"
		fi
	done)

	set -- $d

	if [ ! -z "$d" ]; then
		echo
		echo ".....Выберите папку для сборки:"
		echo
		select menu in $d "Собрать все образы" "Выход в главное меню" "Завершение работы"; do
			case $REPLY in
			[1-9]*)
				i="$#"
				j="$#"
				e="$#"

				let i=i+1
				let j=j+2
				let e=e+3

				file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
				if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
					clear
					pack_d="$file"
					config="config/$pack_d"

					size_orig="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"
					size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
					if busybox test "$size_orig" -le "10485760"; then
						get_add="8192"
						check_size_img
						#size_new="$(busybox expr "$size_orig" \* 109 / 105 / 4096 \* 4096)"
					else
						get_add="1048576"
						check_size_img
						#size_new="$(busybox expr "$size_orig" \* 12 / 11 / 4096 \* 4096)"
					fi
					size=111
					set -- $size
					r_size="$size_new"
					set -- $r_size
					#file_size=${dir}/pack_img_dat
					if busybox test -s ./"$config"/"$pack_d"*_avb.img; then
						file_sh=./"$config"/"$pack_d"*_pack_avb_sparse.sh
					else
						file_sh=./"$config"/"$pack_d"*_pack_sparse.sh
						busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
					fi
					. $file_size
					main_menu
					return
					break
				elif [ "$REPLY" -eq "$i" ]; then

					clear
					for br_pack in "$@"; do
						check_dat="222"
						pack_d="$br_pack"
						config="config/$pack_d"

						size_orig="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"
						size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
						if busybox test "$size_orig" -le "10485760"; then
							get_add="8192"
							check_size_img
							#size_new="$(busybox expr "$size_orig" \* 109 / 105 / 4096 \* 4096)"
						else
							get_add="1048576"
							check_size_img
							#size_new="$(busybox expr "$size_orig" \* 12 / 11 / 4096 \* 4096)"
						fi
						size=111
						set -- $size
						r_size="$size_new"
						set -- $r_size
						#file_size=${dir}/pack_img_dat
						if busybox test -s ./"$config"/"$pack_d"*_avb.img; then
							file_sh=./"$config"/"$pack_d"*_pack_avb_sparse.sh
						else
							file_sh=./"$config"/"$pack_d"*_pack_sparse.sh
							busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
						fi
						. $file_size
						sleep 3
					done
					main_menu
					return
					break
				elif [ "$REPLY" -eq "$j" ]; then
					clear
					main_menu
					return
					break
				elif [ "$REPLY" -eq "$e" ]; then
					clear
					return
					break
				else
					clear
					echo
					echo " Вводите цифры, соответствующие меню."
					pack_dat_new
					return
					break
				fi
				break
				;;
			*)
				clear
				echo
				echo " Вводите цифры, соответствующие меню."
				pack_dat_new
				return
				break
				;;
			esac
		done
	else
		clear
		echo
		echo ....."В \"$PWD\" нет доступных папок для сборки."
		echo
		main_menu
		return
	fi
	return
}

main_menu() {
	echo -en "\E[32;1m"
	MENU=("Меню: Извлечение file_contexts"
		"Меню: [Magisk] Перепаковка boot(recovery).img"
		"Меню: Распаковка .img"
		"Меню: Монтирование raw-образов *.img"
		"Меню: Распаковка .dat"
		"Меню: Распаковка .br"
		"Меню: Сборка .img"
		"Меню: Сборка и конвертация в .dat"
		"Меню: Сборка и конвертация в .br"
		"Меню: Конвертация sparse > raw; raw > sparse"
		"Меню: Прочие инструменты"
		"Меню: Очистка рабочих папок"
		"Меню: Удаление \"Unpacker Kitchen for Android\""
		"Завершение работы"
	)
	echo
	echo "               Главное МЕНЮ:"
	echo "               версия 5.32"
	echo "              --------------"
	echo
	echo "   Введите цифру, соответствующую нужному действию:"
	echo
	echo -en "\E[37;1m"

	select menu in "${MENU[@]}"; do
		case $REPLY in
		1)
			clear
			my1() {
				echo
				echo "      Меню: Извлечение file_contexts"
				echo
				echo "     Положите boot.img в папку: /data/local/UnpackerContexts"
				echo
				select img in "Извлечь file_contexts" "Конвертация file_contexts(txt) -> file_contexts(bin)(версия:8.38)" "Установка конфигурации" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						bootext
						main_menu
						break
						;;
					2)
						clear
						cd /data/local/UnpackerContexts
						if [ -f ./file_contexts ]; then
							$dir/sefcontext_compile -o ./file_contexts_new.bin ./file_contexts
							if [ $(echo $?) -eq 0 ]; then
								echo
								echo ".....Успешно создан file_contexts_new.bin!"
								echo
							else
								echo
								echo ".....error: Ошибка при конвертации!"
								echo
							fi
						else
							echo
							echo ".....В папке нет файла: file_contexts!"
							echo
						fi
						cd
						main_menu
						break
						;;
					3)
						clear
						/data/local/binary/install_sef.sh
						main_menu
						break
						;;
					4)
						clear
						main_menu
						break
						;;
					5)
						clear
						break
						;;
					*) echo "Вводите цифру, соответствующую пунктам Меню: Извлечение file_contexts." ;;
					esac
				done
			}
			my1
			break
			;;
		2)
			clear
			my_aik() {
				if [ -d /data/local/AIK-mobile ]; then
					cd /data/local/AIK-mobile
					echo
					echo "         Меню: AIK-mobile"
					echo
					echo "    Положите boot.img в папку: /data/local/AIK-mobile"
					echo
					select img in "Распаковать boot(recovery)" "Упаковать boot(recovery)" "Удалить AVB/dm-verity" "Патч boot.img(32bit, SAR) для magisk" "Очистка рабочей папки: /data/local/AIK-mobile" "Полное удаление AIK-mobile с телефона" "Выход в главное меню" "Завершение работы"; do
						case $REPLY in
						1)
							clear
							aik_mob="1"
							my_sel_boot() {
								aik_avb() {
									avb_file="$1"
									avb_dir=/data/local/AIK-mobile/split_img
									if [ -d "$avb_dir" ]; then
										avb_full="$(avbtool info_image --image "$avb_file" 2>"$avb_dir"/avb.log)"
										if [ ! -z "$(echo "$avb_full" | busybox grep -o "Image size:")" ]; then

											echo "$avb_full" | busybox awk '/Partition Name:/ { print $3 }' >"$avb_dir"/part_name.txt
											echo "$avb_full" >"$avb_dir"/avb.img
											echo "$avb_full" | busybox awk '/Image size:/ { print $3 }' | busybox head -1 >"$avb_dir"/avb_size.txt

											echo
											echo ".....Обнаружена структура AVB!"
										fi
									fi
									return
								}
								cd /data/local/AIK-mobile
								b=$(busybox find . -maxdepth 1 -name '*.img' -o -name '*.sin' -o -name '*.elf' -o -name '*.bin' -o -name '*.win' -o -name '*.lz4' -o -name '*.PARTITION' -type f)

								set -- $b

								if [ ! -z "$b" ]; then
									echo
									echo ".....Выберите файл для распаковки:"
									echo
									select menu in $b "Выход в Меню: AIK-mobile"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												outfile=$(echo "$file" | busybox awk -F".lz4" '{ print $1 }')
												if [ ! -z "$(echo "$file" | busybox grep -o '.lz4$')" ]; then
													lz4 -df "$file"
													./unpackimg.sh "$outfile" && aik_avb "$outfile"

												elif
													[ ! -z "$(echo "$file" | busybox grep ".sin$")" ]
												then
													name_sin="$(echo "$file" | busybox sed 's!\.sin$!!')"
													sony_dump "$PWD" "$file" | tee "$name_sin"_sin.log

													if [ $(echo $?) -eq 0 ]; then
														[ -f "$name_sin"_sin.log ] && u="$(busybox cat "$name_sin"_sin.log | busybox awk '/Extracting file/ { print $3 }' | busybox tail -1)"
														num=${u##*/}
														busybox mv -f "$num" "$name_sin"_sin.img && ./unpackimg.sh "$name_sin"_sin.img && aik_avb "$name_sin"_sin.img

													fi

												else
													./unpackimg.sh "$file" && aik_avb "$file" && . /data/local/binary/extract_key "$file"
												fi
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												my_aik
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												my_sel_boot
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my_sel_boot
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке нет файлов для распаковки."
									echo
									my_aik
									return
								fi
								return
							}
							my_sel_boot
							break
							my_aik
							break
							;;
						2)
							clear

							./repackimg.sh
							if [ -d ./split_img ]; then
								cd /data/local/AIK-mobile/split_img
								check_name_obraz="$(ls | busybox grep -Eoi 'boot|twrp|recovery|magisk|cwm' | busybox head -1)"
								case "$check_name_obraz" in
								"boot")
									cd ..
									busybox mv -f ./image-new.img ./boot-output.img && aik_pack ./boot-output.img
									;;
								twrp | recovery | cwm)
									cd ..
									busybox mv -f ./image-new.img ./recovery-output.img && aik_pack ./recovery-output.img
									;;
								"magisk")
									cd ..
									busybox mv -f ./image-new.img ./magisk-output.img && aik_pack ./magisk-output.img
									;;
								*)
									cd ..
									busybox mv -f ./image-new.img ./unknown-output.img && aik_pack ./unknown-output.img
									;;
								esac
							fi

							my_aik
							break
							;;

						3)
							clear
							rr() {
								file="$1"
								busybox rm -rf path
								mkdir path && cd path
								bootpatch unpack ../$file 2>../path_dtb.txt
								if [ "$?" -eq "0" ]; then
									echo >>../path_dtb.txt

									#echo
									#echo "...Ищем значения для патча..."
									clear
									for file_path in $(busybox find -maxdepth 1 -name "*dtb"); do
										[ -f $file_path ] && echo
										echo "...Поиск значений для патча в файле: $(echo $file_path | busybox sed "s!./!!")..." && /data/local/binary/bootpatch dtb $file_path patch &>>../path_dtb.txt
									done
									if [ ! -z "$(busybox cat ../path_dtb.txt | busybox grep ".*,avb")" ]; then
										echo >>../path_dtb.txt
										bootpatch repack ../$file 2>>../path_dtb.txt && busybox cp new-boot.img ../boot_noavb.img && busybox rm -rf ../path
										#echo >> ../path_dtb.txt
										echo
										echo "...Успешно завершено, получен файл: \"boot_noavb.img\"!"
										echo
										main_menu
										return
									else
										echo
										echo "...Нет значений для патча!"
										echo
										busybox rm -rf ../path
										main_menu
										return
									fi
								else
									echo
									echo "...Ошибка при распаковке!"
									busybox rm -rf ../path
									main_menu
									return
								fi
							}

							clear_dm() {

								cd /data/local/AIK-mobile
								b=$(busybox find . -maxdepth 1 -name '*.img' -o -name '*.sin' -o -name '*.elf' -o -name '*.bin' -o -name '*.lz4' -type f)

								set -- $b

								if [ ! -z "$b" ]; then
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $b "Выход в Меню: AIK-mobile"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												outfile=$(echo "$file" | busybox awk -F".lz4" '{ print $1 }')
												if [ ! -z "$(echo "$file" | busybox grep -o '.lz4$')" ]; then
													lz4 -df "$file"
													rr "$outfile"
													return
												else
													rr "$file"
													return
												fi
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												my_aik
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												clear_dm
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											clear_dm
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке нет файлов для патчинга."
									echo
									my_aik
									return
								fi
								return
							}
							clear_dm
							break

							my_aik
							break
							;;
						4)
							clear
							ker_path() {

								cd /data/local/AIK-mobile
								b=$(busybox find . -maxdepth 1 -name '*.img' -type f)

								set -- $b

								if [ ! -z "$b" ]; then
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $b "Выход в Меню: AIK-mobile"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												ker_name="$(echo "$file" | busybox sed 's!^./!!' | busybox awk -F".img" '{ print $1 }')"
												file="$ker_name".img
												file1="$ker_name"_path.img
												busybox cp -f "$file" "$file1"
												echo
												python31 /data/local/binary/bin_system/main.py "$file1" 2>ker.txt
												if [ $(echo $?) -eq 0 ]; then
													echo
													echo ".....Успешно пропатчен $file -> $file1"
													echo
												else
													echo
													busybox cat ker.txt | busybox grep "Exception:"
													busybox rm -f "$file1"
													echo
												fi
												busybox rm -f ker.txt
												my_aik
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												my_aik
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												ker_path
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											ker_path
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке нет файлов для патчинга."
									echo
									my_aik
									return
								fi
								return
							}
							ker_path
							break
							my_aik
							break
							;;
						5)
							clear
							./cleanup.sh
							my_aik
							break
							;;
						6)
							clear

							break
							;;
						7)
							clear
							main_menu
							break
							;;
						8)
							clear
							break
							;;
						*)
							echo
							echo "     Вводите цифру, соответствующую пунктам Меню: AIK-mobile"
							;;
						esac
					done
				else
					echo
					#echo -en "\E[31;47;1m"

					echo
					#echo -en "\E[37;0m"
					#echo -en "\E[37;1m"

					main_menu
					return
				fi
				return
			}
			my_aik
			break
			;;
		3)
			clear

			my_system() {
				cd /data/local/UnpackerSystem

				#clear
				dir_dat=/data/local/binary
				#b=/data/local/UnpackerSuper
				#nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
				v=$(for a in $(busybox find . -maxdepth 1 -name '*.img' -type f | busybox sed 's!./!!'); do

					ext_check "$a"

					if [ $(echo $?) -eq 0 ]; then
						echo "$a"
					fi
				done)

				set -- $v

				if [ ! -z "$v" ]; then
					echo
					echo ".....Находимся в папке: /$nd"
					echo ".....Выберите файл для распаковки:"
					echo
					select menu in $v "Выход в главное меню"; do
						case $REPLY in
						[1-9]*)
							i="$#"
							let i=i+1
							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								file=/"$nd"/"$file"
								. ${dir_dat}/unpack_img
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								main_menu
								return
								break
							else
								clear
								echo
								echo "      Вводите цифры, соответствующие меню."
								my_system
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo "      Вводите цифры, соответствующие меню."
							my_system
							return
							break
							;;
						esac
					done
				else
					echo
					echo ".....В папке: /$nd нет образов \".img\" для распаковки."
					echo
					main_menu
					return
				fi
				return
			}

			my_sin() {
				if [ ! -z "$(echo "$file" | busybox grep ".sin$")" ]; then

					name_sin="$(busybox basename ${file%.*})"

					sony_dump "$PWD" "$file"
					if [ $(echo $?) -eq 0 ]; then
						num="$(busybox find -maxdepth 1 | busybox grep -Ev ".sin$|.crt$|.img$|.log$" | busybox grep "$name_sin")"
						busybox mv -f "$num" "$name_sin"_sin.img && file=/"$nd"/"$name_sin"_sin.img

						ext_check "$file"

						if [ "$(echo $?)" -eq "0" ]; then

							. ${dir_dat}/unpack_img
						else
							echo
							echo ".....Успешно завершена конвертация!"
							echo ".....Получен файл $file"
							echo
							echo "...Файл имеет нулевой размер или неподдерживаемый формат, дальнейшая распаковка невозможна!"
							echo
						fi
					fi
				else
					ext_check "$file"
					if [ "$(echo $?)" -eq "0" ]; then
						. ${dir_dat}/unpack_img
					else
						echo
						echo "...Файл имеет нулевой размер или неподдерживаемый формат, дальнейшая распаковка невозможна!"
						echo
					fi
				fi
				return
			}
			qqq() {
				free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
				free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
				#echo "...В /${nd} свободно: $free_space"
				echo -e "\033[33;1m...В /${nd} свободно: $free_space \033[0m"
				if [ "$free_space" != "$free_data" ]; then
					#echo "...В /data свободно: $free_data"
					echo -e "\033[33;1m...В /data свободно: $free_data \033[0m"
				fi
				return
			}

			my_super() {

				dir_dat=/data/local/binary

				if [ "$nd" == "data/local/UnpackerSystem" ]; then
					cd /"$nd" && echo "$nd" >"$dir_dat"/last.txt
				elif [ "$nd" == "data/local/UnpackerSuper" ]; then
					cd /"$nd" && echo "$nd" >"$dir_dat"/last.txt
				elif [ "$nd" == "data/local/UnpackerPayload" ]; then
					cd /"$nd" && echo "$nd" >"$dir_dat"/last.txt
				elif [ "$nd" == "data/local/UnpackerSystem/uka_backup" -a -d /"$nd" ]; then
					cd /"$nd" && echo "$nd" >"$dir_dat"/last.txt
				elif [ "$nd" == "data/local/UnpackerQfil" -a -d /"$nd" ]; then
					cd /"$nd" && echo "$nd" >"$dir_dat"/last.txt
				elif [ "$nd" == "$(busybox cat "$dir_dat"/last.txt 2>/dev/null)" -a -d /"$nd" ]; then
					cd /"$nd" && echo "$nd" >"$dir_dat"/last.txt
				fi

				#dir_dat=/data/local/binary
				#b=/data/local/UnpackerSuper
				#nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')

				echo
				echo ".....Поиск образов..."
				v=$(busybox find . -maxdepth 1 -name '*.img' -o -name '*.zst' -o -name '*.PARTITION' -type f -o -name '*.sin' -o -name '*.win' -type f | busybox sed 's!./!!' | while read a; do

					ext_check $a

					if [ $(echo $?) -eq 0 ]; then
						echo "$a"
					fi
				done)

				set -- $v

				if [ ! -z "$v" -a "$PWD" == "/$nd" -a "$PWD" != "/" ]; then
					clear
					free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
					free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
					echo
					echo "...Находимся в папке: /$nd"
					echo "...В /${nd} свободно: $free_space"
					if [ "$free_space" != "$free_data" ]; then
						echo "...В /data свободно: $free_data"
					fi

					echo
					echo ".....Выберите файл для распаковки:"
					echo
					select menu in $v "Распаковать все образы" "Выход в главное меню" "Завершение работы"; do
						case $REPLY in
						[1-9]*)
							i="$#"
							j="$#"
							e="$#"
							let i=i+1
							let j=j+2
							let e=e+3
							#let i=i+1
							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								file=/"$nd"/"$file"
								my_sin
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								for bin in "$@"; do
									if [ ! -z "$(busybox hexdump -C -n 20000 /"$nd"/"$bin" | busybox grep -o "30 50 4c 41")" -a "$nd" == "data/local/UnpackerSuper" ]; then
										echo
										echo -e "\033[33;1m.....Пропущена распаковка "$bin" \033[0m"
										unset file
										continue
									else
										file=/"$nd"/"$bin"
									fi
									my_sin
									qqq
								done
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$j" ]; then
								clear
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$e" ]; then
								clear
								return
								break
							else
								clear
								echo
								echo "      Вводите цифры, соответствующие меню."
								my_super
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo "      Вводите цифры, соответствующие меню."
							my_super
							return
							break
							;;
						esac
					done
				else
					echo
					echo ".....В папке: /$nd нет поддерживаемых образов \".img\" для распаковки."
					echo
					main_menu
					return
				fi
				return
			}
			my_d() {

				cd
				echo
				echo "...Перейдите в папку где находятся файлы: \".img\", например: cd /sdcard"
				read b && $b
				if [ $(echo $?) -eq 0 ]; then
					clear
					echo
					echo ".....Поиск образов..."

					dir_dat=/data/local/binary
					nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!') && echo "$nd" >/data/local/binary/last.txt
					v=$(for a in $(busybox find . -maxdepth 1 -name '*.img' -o -name '*.zst' -o -name '*.sin' -o -name '*.win' -o -name '*.PARTITION' -type f -o -iname "*super" -type l | busybox sed 's!./!!'); do

						ext_check $a

						if [ $(echo $?) -eq 0 ]; then
							echo "$a"
						fi
					done)

					set -- $v

					if [ ! -z "$v" ]; then
						clear
						free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
						free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
						echo
						echo "...Находимся в папке: /$nd"
						echo "...В /${nd} свободно: $free_space"
						if [ "$free_space" != "$free_data" ]; then
							echo "...В /data свободно: $free_data"
						fi
						echo
						echo ".....Выберите файл для распаковки:"
						echo
						select menu in $v "Распаковать все образы" "Выход в главное меню" "Завершение работы"; do
							case $REPLY in
							[1-9]*)
								i="$#"
								j="$#"
								e="$#"
								let i=i+1
								let j=j+2
								let e=e+3
								#let i=i+1
								file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
								if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
									clear
									#if [ "$(echo "$file" | busybox grep "*..PARTITION$")" ]; then
									#file=/"$nd"/"$(busybox mv "$file" "$file".img)"
									#else
									file=/"$nd"/"$file"
									#fi

									my_sin
									main_menu
									return
									break
								elif [ "$REPLY" -eq "$i" ]; then
									clear
									for bin in "$@"; do
										if [ ! -z "$(busybox hexdump -C -n 20000 /"$nd"/"$bin" | busybox grep -o "30 50 4c 41")" -a "$nd" == "data/local/UnpackerSuper" ]; then
											echo
											echo -e "\033[33;1m.....Пропущена распаковка "$bin" \033[0m"
											unset file
											continue
										else
											file=/"$nd"/"$bin"
										fi
										my_sin
										qqq
									done
									main_menu
									return
									break
								elif [ "$REPLY" -eq "$j" ]; then
									clear
									main_menu
									return
									break
								elif [ "$REPLY" -eq "$e" ]; then
									clear
									return
									break
								else
									clear
									echo
									echo "      Вводите цифры, соответствующие меню."
									my_d
									return
									break
								fi
								break
								;;
							*)
								clear
								echo
								echo "      Вводите цифры, соответствующие меню."
								my_d
								return
								break
								;;
							esac
						done
					else
						echo
						echo ".....В папке: /$nd нет поддерживаемых образов \".img\" для распаковки."
						echo
						main_menu
						return
					fi
					echo
				else
					echo
					echo ".....error: Ошибка перехода в директорию!"
					echo
					echo "Введите директорию правильно!"
					echo
					my_d
					return
				fi
				return
			}
			my_new() {

				echo
				echo "      Меню: Распаковка .img"
				echo
				select menu in "Распаковка .img из папки: /data/local/UnpackerSystem" "Распаковка .img из папки: /data/local/UnpackerSuper" "Распаковка .img из папки: /data/local/UnpackerPayload" "Распаковка .img из папки: /data/local/UnpackerSystem/uka_backup" "Распаковка .img из папки: /data/local/UnpackerQfil" "Распаковка .img из последней использованной папки" "Ввести путь к папке с образом .img" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						nd=data/local/UnpackerSystem
						#my_system
						my_super
						return
						main_menu
						return
						break
						;;
					2)
						clear
						nd=data/local/UnpackerSuper
						my_super
						return
						main_menu
						return
						break
						;;
					3)
						clear
						nd=data/local/UnpackerPayload
						my_super
						return
						main_menu
						return
						break
						;;
					4)
						clear
						nd=data/local/UnpackerSystem/uka_backup
						my_super
						return
						main_menu
						return
						break
						;;
					5)
						clear
						nd=data/local/UnpackerQfil
						my_super
						return
						main_menu
						return
						break
						;;
					6)
						clear
						last_dir="$(busybox cat /data/local/binary/last.txt 2>/dev/null | busybox sed 's!^/!!')"
						if [ ! -z "$last_dir" -a -d /"$last_dir" ]; then
							nd="$last_dir"
							my_super
							return
							main_menu
							return
						else
							echo
							echo ".....Последняя папка ещё не была определена!"
							echo
							main_menu
							return
						fi

						#my_super
						#return
						#main_menu
						#return
						break
						;;
					7)
						clear

						my_d
						return
						main_menu
						return
						break
						;;
					8)
						clear
						main_menu
						break
						;;
					9)
						clear
						return
						break
						;;
					*)
						clear
						echo
						echo "      Вводите цифры, соответствующие меню."
						my_new
						break
						;;
					esac
				done
				return
			}
			my_new
			break
			;;
		4)
			clear
			my_mount() {

				#if [ $(echo $?) -eq 0 ] ; then
				#busybox rm -f /data/local/binary/papka.txt
				#fi
				#home_dir="/data/local/UnpackerSystem"
				cd $home_dir
				my_dir="/data/local/binary"
				>$my_dir/mm
				>$my_dir/mm1
				>$my_dir/spars
				#> $my_dir/fs_ext
				echo
				echo ".....Поиск образов..."

				obraz=$(
					a=$(busybox find "$home_dir" -maxdepth 1 -name '*.img' -type f | busybox sed "s!$home_dir!!")
					set -- $a

					for v in $a; do

						if [ "$(echo $v | busybox awk '{ print $3 }' | busybox grep "$v")" != "$(for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50; do
							loop=/dev/block/loop$i

							busybox losetup $loop 2>/dev/null | busybox grep "$v" | busybox awk '{ print $3 }'
						done)" ]; then

							zik=$(echo $v)
							zik1=$(echo $v | busybox sed "s!$home_dir!!" | busybox sed 's!.img!!')
							if [ "$home_dir" != /data/local/UnpackerSystem/ ]; then
								echo "$zik смонтирован в папку: /data/local/$zik1" >>$my_dir/mm1
							else
								echo "$zik смонтирован в папку: /data/local/$zik1" >>$my_dir/mm
							fi
						else
							if [ -z "$(busybox hexdump -C -n 20000 "$v" | busybox grep '3a ff 26 ed')" ]; then
								if [ ! -z "$(busybox hexdump -C -n 2000 "$v" | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" ]; then
									echo $v
								else
									echo $v >/dev/null
								fi
							else
								echo $v >>$my_dir/spars
							fi
						fi
					done
				)
				set -- $obraz

				if busybox test -s "$my_dir/mm" -o -s "$my_dir/mm1"; then
					clear
					echo
					echo
					echo "   Уже смонтированные образы в папке: \"/$print_dir\""
					busybox cat $my_dir/mm
					busybox cat $my_dir/mm1

				else
					clear
					echo
					echo "   Отсутствуют смонтированные образы в папке: \"/$print_dir\""
					echo
				fi

				if busybox test -s "$my_dir/spars"; then
					echo
					echo "   Образы sparse в папке /$print_dir:"
					busybox cat $my_dir/spars
				fi

				if [ ! -z "$obraz" ]; then
					echo
					echo "   Доступные raw-образы для монтирования. Выберите файл:"
					echo " --------------------------------------------------------"
					echo
					select menu in $obraz "Выход в главное меню"; do
						case $REPLY in
						[1-9]*)
							i="$#"
							let i=i+1
							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								if [ -z "$(busybox hexdump -C -n 20000 "$file" | busybox grep '3a ff 26 ed')" ]; then
									if [ ! -z "$(busybox hexdump -C -n 2000 "$file" | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" ]; then
										a=$(echo $file | busybox sed -e 's!./!!; s!.img!!')

										. /data/local/binary/my_mounting

										busybox echo -ne "/data/local/$a|" >>/data/local/binary/papka.txt

										main_menu
										return
									else
										echo
										echo
										echo "   $file не является образом ext4."
										main_menu
										return
										break
									fi
								else
									echo
									echo
									echo "   $file является sparse-образом. Чтобы смонтировать, конвертируйте в raw.img."
									main_menu
									return
								fi
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								main_menu
								return
								break
							else
								clear
								echo
								echo "      Вводите цифры, соответствующие меню."
								my_mount
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo "      Вводите цифры, соответствующие меню."
							my_mount
							return
							break
							;;
						esac
					done

				else
					echo
					echo "   В папке: \"/$print_dir\" нет файлов *.img, доступных для монтирования."
					echo
					main_menu
					return
				fi
				return
			}

			my_d() {
				cd
				echo
				echo "...Перейдите в папку где находятся файлы: \".img\", например: cd /sdcard"
				read b && $b
				if [ $(echo $?) -eq 0 ]; then
					clear

					home_dir="$PWD/"
					print_dir="$(echo "$PWD" | busybox sed 's!^/!!')"

					my_mount
					return
				else
					echo
					echo ".....error: Ошибка перехода в директорию!"
					echo
					echo "Введите директорию правильно!"
					echo
					my_d
					return
				fi
				return
			}
			my10() {
				echo
				echo "      Меню: Монтирование raw-образов *.img"
				echo "     --------------------------------------"
				echo
				select img in "Монтировать образ из папки: /data/local/UnpackerSystem" "Ввести путь к папке с образом .img для монтирования" "Размонтировать образ" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						home_dir="/data/local/UnpackerSystem/"
						print_dir="data/local/UnpackerSystem"
						my_mount
						break
						;;
					2)
						clear
						my_d
						break
						;;
					3)
						clear
						sel_umount() {
							if [ -z "$file" ]; then
								clear
								main_menu
								return
							else
								clear
								. /data/local/binary/my_unmounting
								check_mount
								if [ $(echo $?) -eq 0 ]; then
									busybox rm -f /data/local/binary/papka.txt
								fi
								main_menu
								return
							fi
							return
						}

						my_umount() {
							if busybox test -s /data/local/binary/papka.txt; then
								p="$(busybox cat /data/local/binary/papka.txt 2>/dev/null | busybox sed -e 's!|$!!; s!\+!\\+!')"

								b=$(busybox mount | busybox cut -d" " -f3 | busybox grep -E "$p") 2>/dev/null
							else
								unset b
							fi

							set -- $b

							if [ ! -z "$b" ]; then
								echo
								echo "     Выберите папку для размонтирования:"
								echo
								select menu in $b "Выход в Главное меню"; do
									case $REPLY in
									1)
										file="$1"
										clear
										sel_umount
										break
										;;
									2)
										file="$2"
										clear
										sel_umount
										break
										;;
									3)
										file="$3"
										clear
										sel_umount
										break
										;;
									4)
										file="$4"
										clear
										sel_umount
										break
										;;
									5)
										file="$5"
										clear
										sel_umount
										break
										;;
									6)
										file="$6"
										clear
										sel_umount
										break
										;;
									*)
										clear
										main_menu
										break
										;;
									esac
								done
							else
								echo
								echo "     Нет папок для размонтирования."
								main_menu
								return
							fi
							return
						}
						my_umount
						break
						my10
						break
						;;
					4)
						clear
						main_menu
						break
						;;
					5)
						clear
						break
						;;
					*) echo "Вводите цифру, соответствующую пунктам Меню: Монтирование образов" ;;
					esac
				done
				return
			}
			my10
			break
			;;
		5)
			clear
			my3() {
				echo
				echo "      Меню: Распаковка .dat"
				echo
				select img in "Распаковка.dat" "Распаковка .dat из последней использованной папки" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						cd
						echo
						echo "..Перейдите в папку где находятся файлы: \".dat\" и \".transfer.list\", например: cd /sdcard"
						my_d() {
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								ndd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!') && echo "$ndd" >"$dir_dat"/last.txt
								v=$(busybox find . -maxdepth 1 -name '*.new.dat' 2>/dev/null | busybox sed 's!./!!')

								set -- $v

								if [ ! -z "$v" ]; then
									free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
									free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
									echo
									echo "...Находимся в папке: /$ndd"
									echo "...В /${ndd} свободно: $free_space"
									if [ "$free_space" != "$free_data" ]; then
										echo "...В /data свободно: $free_data"
									fi
									echo
									echo ".....Выберите файл для распаковки:"
									echo
									select menu in $v "Выход в главное меню" "Завершение работы"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											j="$#"
											let i=i+1
											let j=j+2
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												#nd=data/local/UnpackerSystem
												. ${dir}/unpack_dat
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$i" ]; then
												clear
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$j" ]; then
												clear
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												my3
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my3
											return
											break
											;;
										esac
									done
								else
									echo
									echo ".....В папке \"/$ndd\" нет образов \".dat\" для распаковки."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo ".....error: Ошибка перехода в директорию!"
								echo
								echo "Введите директорию правильно!"
								echo
								my_d
								return
							fi
							return
						}
						my_d
						break
						;;
					2)
						clear
						my_last_dat() {
							v=$(busybox find . -maxdepth 1 -name '*.new.dat' 2>/dev/null | busybox sed 's!./!!')

							set -- $v

							if [ ! -z "$v" ]; then
								free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
								free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
								echo
								echo "...Находимся в папке: /$ndd"
								echo "...В /${ndd} свободно: $free_space"
								if [ "$free_space" != "$free_data" ]; then
									echo "...В /data свободно: $free_data"
								fi
								echo
								echo ".....Выберите файл для распаковки:"
								echo
								select menu in $v "Выход в главное меню" "Завершение работы"; do
									case $REPLY in
									[1-9]*)
										i="$#"
										j="$#"
										let i=i+1
										let j=j+2
										file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
										if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
											clear
											#nd=data/local/UnpackerSystem
											. ${dir}/unpack_dat
											main_menu
											return
											break
										elif [ "$REPLY" -eq "$i" ]; then
											clear
											main_menu
											return
											break
										elif [ "$REPLY" -eq "$j" ]; then
											clear
											return
											break
										else
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my3
											return
											break
										fi
										break
										;;
									*)
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										my3
										return
										break
										;;
									esac
								done
							else
								echo
								echo ".....В папке \"/$ndd\" нет образов \".dat\" для распаковки."
								echo
								main_menu
								return
							fi
							return
						}

						dir_dat=/data/local/binary
						last_dir="$(busybox cat /data/local/binary/last.txt 2>/dev/null | busybox sed 's!^/!!')"
						if [ ! -z "$last_dir" -a -d /"$last_dir" ]; then
							ndd="$last_dir"
							cd /"$ndd"
							my_last_dat
							return
						else
							echo
							echo ".....Последняя использованная папка ещё не была определена!"
							echo
							main_menu
						fi
						break
						;;
					3)
						clear
						main_menu
						break
						;;
					4)
						clear
						break
						;;
					*)
						clear
						echo
						echo ".....Вводите цифру, соответствующую этому меню."
						my3
						break
						;;
					esac
				done
				return
			}
			my3
			break
			;;
		6)
			clear

			qqq_br() {
				free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
				free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
				echo -e "\033[33;1m...В /${nb} свободно: $free_space \033[0m"
				if [ "$free_space" != "$free_data" ]; then
					echo -e "\033[33;1m...В /data свободно: $free_data \033[0m"
				fi
				return
			}

			my_br() {
				echo
				echo "      Меню: Распаковка .br"
				echo
				select img in "Распаковать .br" "Распаковка .br из последней использованной папки" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						cd
						echo
						echo "...Перейдите в папку где находятся файлы: \".br\" и \".transfer.list\", например: cd /sdcard"
						my_b() {
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nb=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!') && echo "$nb" >"$dir_dat"/last.txt
								v=$(busybox find . -maxdepth 1 -name '*.new.dat.br' -type f 2>/dev/null | busybox sed 's!./!!')

								set -- $v

								if [ ! -z "$v" ]; then
									free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
									free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
									echo
									echo "...Находимся в папке: /$nb"
									echo "...В /${nb} свободно: $free_space"
									if [ "$free_space" != "$free_data" ]; then
										echo "...В /data свободно: $free_data"
									fi
									echo
									echo ".....Выберите файл для распаковки:"
									echo
									select menu in $v "Распаковать все образы" "Выход в главное меню" "Завершение работы"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											j="$#"
											e="$#"
											let i=i+1
											let j=j+2
											let e=e+3
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												. ${dir}/unpack_br
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$i" ]; then
												clear
												for br in "$@"; do
													file=/"$nb"/"$br"
													. ${dir}/unpack_br
													qqq_br
												done
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$j" ]; then
												clear
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$e" ]; then
												clear
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												my_br
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my_br
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"/$nb\" нет образов \".br\" для распаковки."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								my_b
								return
							fi
							return
						}
						my_b
						break
						;;
					2)
						clear
						my_last_br() {

							v=$(busybox find . -maxdepth 1 -name '*.new.dat.br' -type f 2>/dev/null | busybox sed 's!./!!')

							set -- $v

							if [ ! -z "$v" ]; then
								free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
								free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
								echo
								echo "...Находимся в папке: /$nb"
								echo "...В /${nb} свободно: $free_space"
								if [ "$free_space" != "$free_data" ]; then
									echo "...В /data свободно: $free_data"
								fi
								echo
								echo ".....Выберите файл для распаковки:"
								echo
								select menu in $v "Распаковать все образы" "Выход в главное меню" "Завершение работы"; do
									case $REPLY in
									[1-9]*)
										i="$#"
										j="$#"
										e="$#"
										let i=i+1
										let j=j+2
										let e=e+3
										file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
										if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
											clear
											#nd=data/local/UnpackerSystem
											. ${dir}/unpack_br
											main_menu
											return
											break
										elif [ "$REPLY" -eq "$i" ]; then
											clear
											for br in "$@"; do
												file=/"$nb"/"$br"
												. ${dir}/unpack_br
												qqq_br
											done
											main_menu
											return
											break
										elif [ "$REPLY" -eq "$j" ]; then
											clear
											main_menu
											return
											break
										elif [ "$REPLY" -eq "$e" ]; then
											clear
											return
											break
										else
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my_br
											return
											break
										fi
										break
										;;
									*)
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										my_br
										return
										break
										;;
									esac
								done
							else
								echo
								echo ....."В папке \"/$nb\" нет образов \".br\" для распаковки."
								echo
								main_menu
								return
							fi
						}

						dir_dat=/data/local/binary
						last_dir="$(busybox cat /data/local/binary/last.txt 2>/dev/null | busybox sed 's!^/!!')"
						if [ ! -z "$last_dir" -a -d /"$last_dir" ]; then
							nb="$last_dir"
							cd /"$nb"
							my_last_br
							return
						else
							echo
							echo ".....Последняя использованная папка ещё не была определена!"
							echo
							main_menu
						fi
						break
						;;
					3)
						clear
						main_menu
						break
						;;
					4)
						clear
						break
						;;
					*)
						clear
						echo
						echo ".....Вводите цифру, соответствующую этому меню."
						my_br
						break
						;;
					esac
				done
				return
			}
			my_br
			break
			;;
		7) #Сборка .img начало +++++++++++++++++

			dir=/data/local/binary
			cd /data/local/UnpackerSystem

			check_d() {
				#cd /data/local/UnpackerSystem
				for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						return 0
					fi
				done
				return
			}

			qqq_space() {
				free_space="$(busybox df -h "$outdir" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
				free_data="$(busybox df -h /data | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
				echo -e "\033[33;1m...В $outdir свободно: $free_space \033[0m"
				if [ "$free_space" != "$free_data" ]; then
					echo -e "\033[33;1m...В /data свободно: $free_data \033[0m"
				fi
				return
			}
			pack_img_my() {
				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Выход в главное меню"; do
						case $REPLY in
						[1-9]*)
							i="$#"

							let i=i+1

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								#nd=data/local/UnpackerSystem
								pack_d="$file"
								config="config/$pack_d"

								size=111
								set -- $size
								file_size=${dir}/pack_img
								if [ -f ./"$config"/"$pack_d"*_avb.img ]; then
									file_sh=./"$config"/"$pack_d"*_pack_avb_sparse.sh
								else
									file_sh=./"$config"/"$pack_d"*_pack_sparse.sh
								fi
								if [ "$size_add" == "1" ]; then
									my_size_add
								else
									my_size
								fi
								return
								break
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								main_menu
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_my
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_my
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет доступных папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			pack_img_orig() {
				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Выход в главное меню"; do
						case $REPLY in
						[1-9]*)
							i="$#"

							let i=i+1

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								#nd=data/local/UnpackerSystem
								pack_d="$file"
								config="config/$pack_d"

								size=100
								. ${dir}/pack_img
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								main_menu
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_orig
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_orig
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			pack_img_raw_orig() {
				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Выход в главное меню"; do
						case $REPLY in
						[1-9]*)
							i="$#"

							let i=i+1

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								#nd=data/local/UnpackerSystem
								pack_d="$file"
								config="config/$pack_d"

								size=100
								. ${dir}/pack_img_raw
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								main_menu
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_raw_orig
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_raw_orig
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			pack_img_raw_my() {
				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Выход в главное меню"; do
						case $REPLY in
						[1-9]*)
							i="$#"

							let i=i+1

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								#nd=data/local/UnpackerSystem
								pack_d="$file"
								config="config/$pack_d"

								size=111
								set -- $size
								file_size=${dir}/pack_img_raw
								if [ -f ./"$config"/"$pack_d"_avb.img ]; then
									file_sh=./"$config"/"$pack_d"_pack_avb.sh
								else
									file_sh=./"$config"/"$pack_d"_pack.sh
								fi
								#my_size
								if [ "$size_add" == "1" ]; then
									my_size_add
								else
									my_size
								fi
								return
								break
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								main_menu
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_raw_my
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_raw_my
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет доступных папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			pack_img_raw_new() {

				free_place
				#if [ "$erof" == "1" ]; then
				#cd /data/local/UnpackerSystem/erofs
				#elif [ "$erof" == "0" ]; then
				#cd /data/local/UnpackerSystem
				#fi

				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Собрать все образы" "Выход в главное меню" "Завершение работы"; do
						case $REPLY in
						[1-9]*)
							i="$#"
							j="$#"
							e="$#"
							let i=i+1
							let j=j+2
							let e=e+3

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								#nd=data/local/UnpackerSystem
								pack_d="$file"
								config="config/$pack_d"

								size_orig="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"
								size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
								if busybox test "$size_orig" -le "10485760"; then
									get_add="8192"
									check_size_img
									#size_new="$(busybox expr "$size_orig" \* 109 / 105 / 4096 \* 4096)"
								else
									get_add="1048576"
									check_size_img
									#size_new="$(busybox expr "$size_orig" \* 12 / 11 / 4096 \* 4096)"
								fi
								size=111
								set -- $size
								r_size="$size_new"
								set -- $r_size
								file_size=${dir}/pack_img_raw
								if busybox test -s ./"$config"/"$pack_d"*_avb.img; then
									file_sh=./"$config"/"$pack_d"*_pack_avb.sh
								else
									file_sh=./"$config"/"$pack_d"*_pack.sh
									busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
								fi
								. $file_size
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								clear
								for papka in "$@"; do
									if [ "$erof" == "0" ]; then
										erof="0"
									elif [ "$erof" == "1" ]; then
										erof="1"
									fi
									pack_d="$papka"
									config="config/$pack_d"

									size_orig="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"
									size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
									if busybox test "$size_orig" -le "10485760"; then
										get_add="8192"
										check_size_img
									else
										get_add="1048576"
										check_size_img
									fi
									size=111
									set -- $size
									r_size="$size_new"
									set -- $r_size
									file_size=${dir}/pack_img_raw
									if busybox test -s ./"$config"/"$pack_d"*_avb.img; then
										file_sh=./"$config"/"$pack_d"*_pack_avb.sh
									else
										file_sh=./"$config"/"$pack_d"*_pack.sh
										busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
									fi
									. $file_size
									qqq_space
									sleep 2
								done
								main_menu
								return
								break

							elif [ "$REPLY" -eq "$j" ]; then
								clear
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$e" ]; then
								clear
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_raw_new
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_raw_new
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет доступных папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			pack_img_new() {
				free_place

				#if [ "$erof" == "1" ]; then
				#cd /data/local/UnpackerSystem/erofs
				#elif [ "$erof" == "0" ]; then
				#cd /data/local/UnpackerSystem
				#fi

				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Собрать все образы" "Выход в главное меню" "Завершение работы"; do
						case $REPLY in
						[1-9]*)
							i="$#"
							j="$#"
							e="$#"
							let i=i+1
							let j=j+2
							let e=e+3

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								#nd=data/local/UnpackerSystem
								pack_d="$file"
								config="config/$pack_d"

								size_orig="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"
								size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
								if busybox test "$size_orig" -le "10485760"; then
									get_add="8192"
									check_size_img
									#size_new="$(busybox expr "$size_orig" \* 109 / 105 / 4096 \* 4096)"
								else
									get_add="1048576"
									check_size_img
									#size_new="$(busybox expr "$size_orig" \* 12 / 11 / 4096 \* 4096)"
								fi
								size=111
								set -- $size
								r_size="$size_new"
								set -- $r_size
								file_size=${dir}/pack_img
								if busybox test -s ./"$config"/"$pack_d"*_avb.img; then
									file_sh=./"$config"/"$pack_d"*_pack_avb_sparse.sh
								else
									file_sh=./"$config"/"$pack_d"*_pack_sparse.sh
									busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
								fi
								. $file_size
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								for papka in "$@"; do
									clear
									if [ "$erof" == "0" ]; then
										erof="0"
									elif [ "$erof" == "1" ]; then
										erof="1"
									fi

									pack_d="$papka"
									config="config/$pack_d"

									size_orig="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"
									size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
									if busybox test "$size_orig" -le "10485760"; then
										get_add="8192"
										check_size_img
										#size_new="$(busybox expr "$size_orig" \* 109 / 105 / 4096 \* 4096)"
									else
										get_add="1048576"
										check_size_img
										#size_new="$(busybox expr "$size_orig" \* 12 / 11 / 4096 \* 4096)"
									fi
									size=111
									set -- $size
									r_size="$size_new"
									set -- $r_size
									file_size=${dir}/pack_img
									if busybox test -s ./"$config"/"$pack_d"*_avb.img; then
										file_sh=./"$config"/"$pack_d"*_pack_avb_sparse.sh
									else
										file_sh=./"$config"/"$pack_d"*_pack_sparse.sh
										busybox sed -e "s!-l [0-9]*!-l "$r_size"!" $file_sh >"$config"/"$pack_d"_gsize.sh
									fi
									. $file_size
									qqq_space
									sleep 2
								done
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$j" ]; then
								clear
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$e" ]; then
								clear
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_new
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_new
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет доступных папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			pack_img_erofs() {

				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Собрать все образы" "Выход в главное меню" "Завершение работы"; do
						case $REPLY in
						[1-9]*)
							i="$#"
							j="$#"
							e="$#"
							let i=i+1
							let j=j+2
							let e=e+3

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								pack_d="$file"
								config="config/$pack_d"
								. ${dir}/pack_img_erofs
								unset ext_erof
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								for papka in "$@"; do
									clear
									if [ "$erof" == "0" ]; then
										erof="0"
									elif [ "$erof" == "1" ]; then
										erof="1"
									fi

									pack_d="$papka"
									config="config/$pack_d"

									. ${dir}/pack_img_erofs
									qqq_space
									sleep 2
								done
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$j" ]; then
								clear
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$e" ]; then
								clear
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_erofs
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_erofs
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет доступных папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			pack_img_e2fs() {

				b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
					if [ -f "config/"$a"/"$a"_file_contexts" ]; then
						echo "$a"
					fi
				done)

				set -- $b

				if [ ! -z "$b" ]; then
					echo
					echo ".....Выберите папку для сборки:"
					echo
					select menu in $b "Собрать все образы" "Выход в главное меню" "Завершение работы"; do
						case $REPLY in
						[1-9]*)
							i="$#"
							j="$#"
							e="$#"
							let i=i+1
							let j=j+2
							let e=e+3

							file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
							if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
								clear
								config_e2fs="1"
								set -- $config_e2fs
								pack_d="$file"
								config="config/$pack_d"
								. ${dir}/pack_img_e2fsdroid
								unset config_e2fs
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$i" ]; then
								for papka in "$@"; do
									clear
									#if [ "$erof" == "0" ]; then
									#erof="0"
									#elif [ "$erof" == "1" ]; then
									#erof="1"
									#fi
									config_e2fs="1"
									set -- $config_e2fs
									pack_d="$papka"
									config="config/$pack_d"

									. ${dir}/pack_img_e2fsdroid
									unset config_e2fs
									qqq_space
									sleep 2
								done
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$j" ]; then
								clear
								main_menu
								return
								break
							elif [ "$REPLY" -eq "$e" ]; then
								clear
								return
								break
							else
								clear
								echo
								echo " Вводите цифры, соответствующие меню."
								pack_img_e2fs
								return
								break
							fi
							break
							;;
						*)
							clear
							echo
							echo " Вводите цифры, соответствующие меню."
							pack_img_e2fs
							return
							break
							;;
						esac
					done
				else
					clear
					echo
					echo ....."В \"$PWD\" нет доступных папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}

			my5() {
				clear
				check_d
				if [ $(echo $?) -eq 0 ]; then
					echo
					echo "      Меню: Сборка .img"
					echo
					select img in "Собрать .img(sparse)" "Собрать .img(raw)" "Сборка super.img" "Запись в fs_config" "Информация о размере папки для сборки" "Восстановление симлинков" "Выход в главное меню" "Завершение работы"; do
						case $REPLY in
						1)
							clear

							sparse_s() {
								echo
								select img in "Собрать .img(sparse) с оригинальным размером" "Собрать .img(sparse) с вводом размера образа" "Собрать .img(sparse) с размером папки для сборки" "Собрать .img(sparse) в ro с shared_blocks" "Собрать .img(sparse)(erofs в ext4)" "Собрать .img(sparse)(erofs в erofs)" "Собрать .img(sparse)(ext4 в erofs)" "Выход в главное меню" "Завершение работы"; do
									case $REPLY in
									1)
										clear
										erof="0"
										set -- $erof
										nn
										pack_img_orig
										break
										;;
									2)
										clear
										erof="0"
										set -- $erof
										nn
										pack_img_my
										break
										;;
									3)
										clear
										erof="0"
										set -- $erof
										nn
										pack_img_new
										break
										;;
									4)
										clear
										nn
										sparse_e2fs="1"
										set -- $sparse_e2fs
										#config_e2fs="1"
										#set -- $config_e2fs
										erof="0"
										set -- $erof
										pack_img_e2fs
										break
										;;
									5)
										clear
										erof="1"
										set -- $erof
										nn
										mkdir /data/local/UnpackerSystem/erofs 2>/dev/null
										cd /data/local/UnpackerSystem/erofs
										pack_img_new
										break
										;;
									6)
										clear
										erof="0"
										set -- $erof
										sparse_erof="1"
										set -- $sparse_erof
										nn
										mkdir /data/local/UnpackerSystem/erofs 2>/dev/null
										cd /data/local/UnpackerSystem/erofs
										pack_img_erofs
										break
										;;
									7)
										clear
										erof="0"
										set -- $erof
										sparse_erof="1"
										set -- $sparse_erof
										ext_erof="1"
										set -- $ext_erof
										nn
										mkdir /data/local/UnpackerSystem 2>/dev/null
										cd /data/local/UnpackerSystem
										pack_img_erofs
										break
										;;
									8)
										clear
										main_menu
										break
										;;
									9)
										clear
										break
										;;
									*)
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										echo
										sparse_s
										break
										;;
									esac
								done
								return
							}
							sparse_s
							break
							;;
						2)
							clear
							raw_s() {
								echo
								select img in "Собрать .img(raw) с оригинальным размером" "Собрать .img(raw) с вводом размера образа" "Собрать .img(raw) с размером папки для сборки" "Собрать .img(raw) в ro с shared_blocks" "Собрать .img(raw)(erofs в ext4)" "Собрать .img(raw)(erofs в erofs)" "Собрать .img(raw)(ext4 в erofs)" "Выход в главное меню" "Завершение работы"; do
									case $REPLY in
									1)
										clear
										nn
										erof="0"
										set -- $erof
										pack_img_raw_orig
										break
										;;
									2)
										clear
										nn
										erof="0"
										set -- $erof
										pack_img_raw_my
										break
										;;
									3)
										clear
										nn

										erof="0"
										set -- $erof
										pack_img_raw_new
										break
										;;
									4)
										clear
										nn
										sparse_e2fs="0"
										set -- $sparse_e2fs
										#config_e2fs="1"
										#set -- $config_e2fs
										erof="0"
										set -- $erof
										pack_img_e2fs
										break
										;;
									5)
										clear
										erof="1"
										set -- $erof
										nn
										mkdir /data/local/UnpackerSystem/erofs 2>/dev/null
										cd /data/local/UnpackerSystem/erofs
										pack_img_raw_new
										break
										;;
									6)
										clear
										erof="0"
										set -- $erof
										sparse_erof="0"
										set -- $sparse_erof
										nn
										mkdir /data/local/UnpackerSystem/erofs 2>/dev/null
										cd /data/local/UnpackerSystem/erofs
										pack_img_erofs
										break
										;;
									7)
										clear
										erof="0"
										set -- $erof
										sparse_erof="0"
										set -- $sparse_erof
										ext_erof="1"
										set -- $ext_erof
										nn
										mkdir /data/local/UnpackerSystem 2>/dev/null
										cd /data/local/UnpackerSystem
										pack_img_erofs
										break
										;;
									8)
										clear
										main_menu
										break
										;;
									9)
										clear
										break
										;;
									*)
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										raw_s
										break
										;;
									esac
								done
								return
							}
							raw_s
							break
							;;
						3)
							clear
							echo
							echo ".....Проверьте наличие нужных образов в папке /data/local/UnpackerSuper"
							echo
							select img in "Собрать super.img(sparse)" "Собрать super.img(raw)" "Выход в главное меню" "Завершение работы"; do
								case $REPLY in
								1)
									clear
									spars=1
									. /data/local/binary/pack_super_img
									main_menu
									break
									;;
								2)
									clear
									spars=0
									. /data/local/binary/pack_super_img
									main_menu
									break
									;;
								3)
									clear
									main_menu
									break
									;;
								4)
									clear
									break
									;;
								*) echo "Вводите цифру, соответствующую пунктам этого меню." ;;
								esac
							done
							break
							;;
						4)
							clear
							echo
							echo ".....Добавьте папки или файлы в распакованный образ..."
							echo
							select img in "Запись" "Выход в главное меню"; do
								case $REPLY in
								1)
									clear
									. /data/local/binary/a_atr
									break
									;;
								2)
									clear
									main_menu
									break
									;;
								*) echo "Вводите цифру, соответствующую пунктам этого меню." ;;
								esac
							done
							break
							;;
						5)
							clear
							cd /data/local/UnpackerSystem
							size_papka() {
								b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
									if [ -f "config/"$a"/"$a"_file_contexts" ]; then
										echo "$a"
									fi
								done)

								set -- $b

								if [ ! -z "$b" ]; then
									echo
									echo ".....Выберите папку:"
									echo
									select menu in $b "Выход в главное меню" "Завершение работы"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											j="$#"
											let i=i+1
											let j=j+2
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												pack_d="$file"
												config="config/$pack_d"

												size_orig="$(busybox expr $(busybox du -s "$pack_d" | busybox awk '{ print $1 }') \* 1024)"
												size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
												if busybox test "$size_orig" -le "10485760"; then
													get_size="0"
													get_add="8192"
													check_size_img
												else
													get_size="0"
													get_add="1048576"
													check_size_img
												fi

												size_real="$(busybox cat "$config"/"$pack_d"_size.txt)"
												echo
												echo "       -----------------------------"
												echo "       -----------------------------"
												echo
												echo ".....Текущий размер для сборки образа:"
												echo "     $size_real байт"
												echo
												echo ".....Размер папки \"$pack_d\":"
												echo "     $size_orig байт"
												echo
												echo ".....Примерный минимальный размер с которым соберётся образ:"
												echo "     $size_new байт"
												echo
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$i" ]; then
												clear
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$j" ]; then
												clear
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												size_papka
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											size_papka
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В \"$PWD\" нет папок для сборки."
									echo
									main_menu
									return
								fi
								return
							}
							size_papka
							break
							;;

						6)
							clear
							cd /data/local/UnpackerSystem
							symlink() {
								b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
									if [ -f "config/"$a"/"$a"_file_contexts" ]; then
										echo "$a"
									fi
								done)

								set -- $b

								if [ ! -z "$b" ]; then
									echo
									echo ".....Выберите папку для восстановления:"
									echo
									select menu in $b "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"

											let i=i+1

											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												pack_d="$file"
												config="config/$pack_d"
												if busybox test -s "$config"/"$pack_d"_sim.tar; then
													busybox tar -xf "$config"/"$pack_d"_sim.tar
													if [ $(echo $?) -eq 0 ]; then
														echo
														echo ".....Успешно восстановлено!"
														echo
													else
														echo
														echo ".....Ошибка при восстановлении!"
														echo
													fi
												else
													echo
													echo ".....Нет сохранённого архива для восстановления!"
													echo
												fi
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo " Вводите цифры, соответствующие меню."
												symlink
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo " Вводите цифры, соответствующие меню."
											symlink
											return
											break
											;;
										esac
									done
								else
									clear
									echo
									echo ....."В \"$PWD\" нет папок для восстановления."
									echo
									main_menu
									return
								fi
								return
							}
							symlink
							break
							;;
						7)
							clear
							main_menu
							break
							;;
						8)
							clear
							break
							;;
						*) echo "Вводите цифру, соответствующую пунктам Меню: Сборка sparse.img." ;;
						esac
					done
				else
					echo
					echo ....."В \"$PWD\" нет папок для сборки."
					echo
					main_menu
					return
				fi
				return
			}
			my5
			break
			;;
			#Конец функции сборка .img

		8)
			clear
			my6() {
				file_size=${dir}/pack_img_dat
				check_dat="222"
				echo
				echo "      Меню: Сборка и конвертация в .dat"
				echo
				select img in "Собрать .img -> .dat" "Собрать .img с вводом размера -> .dat" "Собрать .img с размером папки для сборки -> .dat" "Конвертировать \".img\" в \".dat\"" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						erof="0"
						set -- $erof
						nn
						pack_dat
						break
						;;
					2)
						clear
						erof="0"
						set -- $erof
						nn
						pack_dat_my
						break
						;;
					3)
						clear
						erof="0"
						set -- $erof
						nn
						pack_dat_new
						break
						;;
					4)
						clear
						my_k() {
							echo
							echo "..Перейдите в папку где находится файл \".img\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }')
								v=$(for sparse in $(busybox find . -maxdepth 1 -name '*.img' -type f 2>/dev/null); do
									if [ ! -z "$(busybox hexdump -C -n 20000 "$sparse" | busybox grep -Eo '3a ff 26 ed|30 50 4c 41')" -o ! -z "$(busybox hexdump -C -n 2000 "$sparse" | busybox awk '/00000430/ { print $10$11 }' | busybox grep -o "53ef")" -o ! -z "$(busybox hexdump -C -n 2000 "$sparse" | busybox awk '/00000400/ { print $2$3$4$5 }' | busybox grep -o "e2e1f5e0")" ]; then
										echo "$sparse"
									fi
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo ".....Выберите файл для конвертации в \".dat\":"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												br_check="false"
												. ${dir_dat}/konvert_img_dat
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												my_k
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my_k
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"$nd\" нет образов \".img\" для конвертации."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								my_k
								return
							fi
							return
						}
						my_k
						break
						;;
					5)
						clear
						main_menu
						break
						;;
					6)
						clear
						break
						;;
					*) echo "Вводите цифру, соответствующую пунктам Меню: Сборка и конвертация в .dat." ;;
					esac
				done
				return
			}
			my6
			break
			;;
		9)
			clear
			my7() {
				file_size=${dir}/pack_img_br
				check_dat="222"
				echo
				echo "      Меню: Сборка и конвертация в .br"
				echo
				select img in "Собрать .img -> .br" "Собрать .img с вводом размера -> .br" "Собрать .img с размером папки для сборки -> .br" "Конвертировать .img в .br" "Конвертировать .dat в .br" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						erof="0"
						set -- $erof
						nn

						pack_dat
						break
						;;
					2)
						clear
						erof="0"
						set -- $erof
						nn
						pack_dat_my
						break
						;;
					3)
						clear
						erof="0"
						set -- $erof
						nn
						pack_dat_new
						break
						;;
					4)
						clear
						my_imgbr() {
							echo
							echo "..Перейдите в папку где находится файл \".img\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }')
								v=$(for sparse in $(busybox find . -maxdepth 1 -name '*.img' -type f 2>/dev/null); do
									if [ ! -z "$(busybox hexdump -C -n 20000 "$sparse" | busybox grep -Eo '3a ff 26 ed|30 50 4c 41')" -o ! -z "$(busybox hexdump -C -n 2000 "$sparse" | busybox awk '/00000430/ { print $10$11 }' | busybox grep -o "53ef")" -o ! -z "$(busybox hexdump -C -n 2000 "$sparse" | busybox awk '/00000400/ { print $2$3$4$5 }' | busybox grep -o "e2e1f5e0")" ]; then
										echo "$sparse"
									fi
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo ".....Выберите файл для конвертации:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												br_check="true"
												. ${dir_dat}/konvert_img_dat
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												my_imgbr
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my_imgbr
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"$nd\" нет образов \".img\" для конвертации."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo ".....error: Ошибка перехода в директорию!"
								echo
								echo ".....Введите директорию правильно!"
								echo
								my_imgbr
								return
							fi
							return
						}
						my_imgbr
						break
						;;

					5)
						clear
						my_kbr() {

							echo
							echo "..Перейдите в папку где находится файл \".dat\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }')
								v=$(busybox find . -maxdepth 1 -name '*.new.dat' -type f 2>/dev/null | busybox sed 's!./!!')

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo ".....Выберите файл для конвертации:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												. ${dir_dat}/konvert_dat_br
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												my_kbr
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											my_kbr
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"$nd\" нет образов \".dat\" для конвертации."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo ".....error: Ошибка перехода в директорию!"
								echo
								echo ".....Введите директорию правильно!"
								echo
								my_kbr
								return
							fi
							return
						}
						my_kbr
						break
						;;
					6)
						clear
						main_menu
						break
						;;
					7)
						clear
						break
						;;
					*) echo "Вводите цифру, соответствующую пунктам Меню: Конвертация new.dat в .br" ;;
					esac
				done
				return
			}
			my7
			break
			;;
		10)
			clear
			my8() {
				echo
				echo "      Меню: Конвертация sparse > raw; raw > sparse"
				echo
				select img in "Конвертировать .img(raw) в .img (sparse)" "Конвертировать .img(sparse) в .img(raw)" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						konv_img() {
							echo
							echo "..Перейдите в папку где находится файл \".img(raw)\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
								#v=$(busybox find . -maxdepth 1 -name 'vendor*.img' -type f -o -name 'system*.img' -type f | busybox sed 's!./!!')

								#v=$(for raw in $(busybox find . -maxdepth 1 -name 'vendor*.img' -type f -o -name 'system*.img' -type f 2> /dev/null); do
								#if [ -z "$(busybox hexdump -C -n 4 "$raw" | busybox grep '3a ff 26 ed')" ]; then
								#echo "$raw"
								#fi
								#done)

								v=$(for raw in $(busybox find -maxdepth 1 -name '*.img' -type f | busybox sed 's!./!!'); do
									if [ -z "$(busybox hexdump -C -n 2000 "$raw" | busybox grep -E '3a ff 26 ed')" -a ! -z "$(busybox hexdump -C -n 2000 "$raw" | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" ]; then

										echo "$raw"
									elif [ -z "$(busybox hexdump -C -n 2000 "$raw" | busybox grep '3a ff 26 ed')" -a ! -z "$(busybox hexdump -C -n 20000 "$raw" | busybox grep "30 50 4c 41")" ]; then
										echo "$raw"
									elif [ -z "$(busybox hexdump -C -n 2000 "$raw" | busybox grep '3a ff 26 ed')" -a ! -z "$(busybox hexdump -C -n 2000 "$raw" | busybox grep -o "e2 e1 f5 e0")" ]; then
										echo "$raw"
									fi
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo "...Находимся в папке: /$nd"
									echo "...Показаны только \"raw\" образы"
									free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
									echo "...В /${nd} свободно: $free_space"
									echo

									echo ".....Выберите файл для конвертации в \"sparse\":"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												. ${dir_dat}/konvert_raw_sparse
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												konv_img
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											konv_img
											return
											break
											;;
										esac
									done
								else
									echo
									echo ..."В папке \"/$nd\" нет \"raw\" образов для конвертации."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								konv_img
								return
							fi
							return
						}
						konv_img
						break
						;;
					2)
						clear
						konv_img() {
							echo
							echo "..Перейдите в папку где находится файл \".img(sparse)\", например: cd /sdcard:"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
								v=$(for sparse in $(busybox find . -maxdepth 1 -name '*.img' -type f 2>/dev/null); do
									if [ ! -z "$(busybox hexdump -C -n 2000 "$sparse" | busybox grep '3a ff 26 ed')" ]; then
										echo "$sparse"
									fi
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo "...Находимся в папке: /$nd"
									echo "...Показаны только \"sparse\" образы"
									free_space="$(busybox df -h "$PWD" | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
									echo "...В /${nd} свободно: $free_space"
									echo
									echo ".....Выберите файл для конвертации в \"raw\":"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												. ${dir_dat}/konvert_sparse_raw
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												konv_img
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											konv_img
											return
											break
											;;
										esac
									done
								else
									echo
									echo ..."В папке \"/$nd\" нет \"sparse\" образов для конвертации."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								konv_img
								return
							fi
							return
						}
						konv_img
						break
						;;
					3)
						clear
						main_menu
						break
						;;
					4)
						clear
						break
						;;
					*) echo "Вводите цифру, соответствующую пунктам Меню: Конвертация sparse > raw; raw > sparse" ;;
					esac
				done
				return
			}
			my8
			break
			;;
		11)
			clear
			my2() {
				echo
				echo "      Меню: Прочие инструменты"
				echo

				select img in "Действия со структурой AVB" "Конвертация .sin -> .img" "Конвертация .lz4|.zst|.xz|.lzma" "Склеить образ из прошивки под Qfil" "Разделение super.img на части" "Извлечение образов из payload.bin" "Извлечение образов из UPDATE.APP" "Создание образа из блока памяти текущей прошивки" "Распаковка(конвертация) .ozip" "Создание tar.md5" "Распаковка прошивок .img" "Распаковка прошивок .ofp|.ops" "Распаковка прошивок .pac" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						read_avb() {
							echo
							select img in "Патч vbmeta" "Просмотр структуры AVB файла" "Извлечение публичного ключа подписи AVB" "Создание своего ключа подписи AVB" "Замена публичного ключа в образе" "Подпись boot(recovery).img с выбором ключа" "Выход в главное меню" "Завершение работы"; do
								case $REPLY in
								1)
									clear

									pvbm() {
										clear
										echo
										echo ".....Ищем значения для патча..."

										true_vb() {
											tru="$(avbtool info_image --image "$file" | busybox awk '/Flags:/ NR == 1 {if($2 == 3) { print $2 }}')"
											rolbak="$(avbtool info_image --image "$file" | busybox awk '/Rollback Index:/ NR == 1 {if($3 == 0) { print $3 }}')"
											return
										}
										#true_vb

										#if [ "$tru" != 3 -o "$rolbak" != 0 ]; then
										real_nd="$(echo /"$nd" | busybox grep -o "/dev/block")"
										if [ -z "$real_nd" ]; then

											file_name="$(echo "$file" | busybox sed 's!.img$!!')"
											file_orig="$file"
											file_path="${file_name}_path.img"
											busybox cp -f "$file_orig" "$file_path"
										#python39 /data/local/binary/bin_system/int.py "$file" "7b" "03"
										#echo '7b: 03' | xxd -r - "$file"
										else
											file_orig="$file"
											file_path="$file"
										fi

										#for vb in "78: $num_path" "74: 00000000" "7c: 00000000"; do

										echo "78: $num_path" | /data/local/binary/xxd -r - "$file_path"

										#done

										if [ $(echo $?) -eq 0 ]; then
											file="$file_path"
											true_vb

											#if [ "$tru" == 3 -a "$rolbak" == 0 ]; then
											if [ -z "$real_nd" ]; then
												echo
												echo ".....Успешно пропатчен /"$nd"/"$file_orig" -> /"$nd"/"$file_path""
												echo ".....Статус патча:  $file_vbm"
												echo
											else
												echo
												echo ".....Успешно пропатчен /"$nd"/"$file_orig""
												echo ".....Статус патча:  $file_vbm"
												echo
											fi
										else
											echo
											echo ".....Ошибка при патче /"$nd"/"$file""
											echo
										#fi
										fi
										#else
										#echo
										#$echo ".....Файл /"$nd"/"$file" уже пропатчен!"
										#echo
										#fi
									}
									vbmeta() {
										echo
										echo "..Перейдите в папку где находится файл \"vbmeta.img\", например: cd /sdcard"
										read b && $b
										if [ $(echo $?) -eq 0 ]; then
											clear
											nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')

											v=$(for a in $(busybox find . -maxdepth 1 -name "*.img" -type f -o -name "vbmeta*" | busybox sed 's!./!!'); do

												if [ ! -z "$(busybox hexdump -C -n 20 "$a" 2>/dev/null | busybox grep -o "41 56 42 30")" ]; then
													echo "$a"
												fi
											done)

											set -- $v

											if [ ! -z "$v" ]; then
												echo
												echo ".....Выберите файл для патча:"
												echo
												select menu in $v "Выход в главное меню"; do
													case $REPLY in
													[1-9]*)
														i="$#"
														let i=i+1
														file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
														if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
															#clear

															choice_vb() {
																clear
																v=$(echo "Disable_dm_verity" "Disable_dm_verification" "Disable_dm_verity+Disable_dm_verification")

																set -- $v
																echo
																echo ".....Выберите патч для vbmeta:"
																echo
																select menu in $v "Выход в главное меню"; do
																	case $REPLY in
																	[1-9]*)
																		i="$#"
																		let i=i+1
																		file_vbm=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
																		if [ ! -z "$file_vbm" -a "$REPLY" -lt "$i" ]; then
																			if [ "$file_vbm" == "Disable_dm_verity" ]; then
																				num_path="00000001"
																				pvbm
																			elif [ "$file_vbm" == "Disable_dm_verification" ]; then
																				num_path="00000002"
																				pvbm
																			elif [ "$file_vbm" == "Disable_dm_verity+Disable_dm_verification" ]; then
																				num_path="00000003"
																				pvbm
																			fi
																			main_menu
																			return
																			break
																		elif [ "$REPLY" == "$i" ]; then
																			clear
																			main_menu
																			return
																			break
																		else
																			clear
																			echo
																			echo "      Вводите цифры, соответствующие меню."
																			choice_vb
																			return
																			break
																		fi
																		break
																		;;
																	*)
																		clear
																		echo
																		echo "      Вводите цифры, соответствующие меню."
																		choice_vb
																		return
																		break
																		;;
																	esac
																done
																return
															}
															choice_vb
															#main_menu
															return
															break
														elif [ "$REPLY" == "$i" ]; then
															clear
															main_menu
															return
															break
														else
															clear
															echo
															echo "      Вводите цифры, соответствующие меню."
															vbmeta
															return
															break
														fi
														break
														;;
													*)
														clear
														echo
														echo "      Вводите цифры, соответствующие меню."
														vbmeta
														return
														break
														;;
													esac
												done
											else
												echo
												echo ....."В папке \"/$nd\" нет файлов \"vbmeta\" для патча."
												echo
												main_menu
												return
											fi
											echo
										else
											echo
											echo .....error: Ошибка перехода в директорию!
											echo
											echo Введите директорию правильно!
											echo
											vbmeta
											return
										fi
										return
									}
									vbmeta
									break
									;;
								2)
									clear
									vbmeta_info() {
										echo
										echo "..Перейдите в папку где находится файл \"*.img\", например: cd /sdcard"
										read b && $b
										if [ $(echo $?) -eq 0 ]; then
											clear
											echo
											echo ".....Поиск файлов..."
											nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')

											v=$(for a in $(busybox find -maxdepth 1 -name "*.img" -o -name '*.win' -type f -o -name "vbmeta*" -a -type l | busybox sed 's!./!!'); do

												#if [ ! -z "$(busybox hexdump -C -n 20 "$a" 2> /dev/null | busybox grep -o "41 56 42 30")" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox grep '3a ff 26 ed')" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox grep -o '41 4e 44 52 4f 49 44 21')" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox grep -o 'e2 e1 f5 e0')" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox grep -o '10 20 f5 f2 ')" ]; then
												echo "$a"
												#fi
											done)

											set -- $v

											if [ ! -z "$v" ]; then
												clear
												echo
												echo ".....Выберите файл:"
												echo
												select menu in $v "Выход в главное меню"; do
													case $REPLY in
													[1-9]*)
														i="$#"
														let i=i+1
														file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
														if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then

															t="     Файл: /$nd/$file"
															g=${#t}
															ggg="$(busybox expr "$g" - 6)"
															gg="$(busybox seq -s- "$ggg" | busybox tr -d '[:digit:]')"
															#gg1="$(busybox seq -s- 28 | busybox tr -d '[:digit:]')"
															clear
															echo
															echo
															echo "    $gg"
															echo "$t"
															echo "    $gg"
															#echo "     ------------------------------"
															#echo "     Файл: /"$nd"/"$file""
															#echo "     ------------------------------"
															echo
															f_avb=/data/local/binary/avb.txt
															avbtool info_image --image "$file" &>"$f_avb"
															if [ ! -z "$(busybox cat "$f_avb" | busybox grep -o "Minimum libavb version:")" ]; then
																busybox cat "$f_avb"
															else
																echo "     Структура AVB не найдена!"
															fi
															echo
															echo "    $gg"
															echo
															busybox rm -f "$f_avb"
															main_menu
															return
															break
														elif [ "$REPLY" == "$i" ]; then
															clear
															main_menu
															return
															break
														else
															clear
															echo
															echo "      Вводите цифры, соответствующие меню."
															vbmeta_info
															return
															break
														fi
														break
														;;
													*)
														clear
														echo
														echo "      Вводите цифры, соответствующие меню."
														vbmeta_info
														return
														break
														;;
													esac
												done
											else
												echo
												echo ....."В папке \"/$nd\" нет файлов \"*.img\""
												echo
												main_menu
												return
											fi
											echo
										else
											echo
											echo .....error: Ошибка перехода в директорию!
											echo
											echo Введите директорию правильно!
											echo
											vbmeta_info
											return
										fi
										return
									}
									vbmeta_info
									break
									;;

								\
									3)
									clear
									unset aik_mob
									extract_key() {
										echo
										echo "..Перейдите в папку где находится файл \"*.img\", например: cd /sdcard"
										read b && $b
										if [ $(echo $?) -eq 0 ]; then
											clear
											echo
											echo ".....Поиск файлов..."
											nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')

											v=$(for a in $(busybox find . -maxdepth 1 -name "*.img" -o -name "*.win" -type f | busybox sed 's!./!!'); do

												#if [ ! -z "$(busybox hexdump -C -n 20 "$a" 2> /dev/null | busybox grep -o "41 56 42 30")" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox grep '3a ff 26 ed')" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox awk '/00000430/ { print $10$11 }' | busybox grep "53ef")" -o ! -z "$(busybox hexdump -C -n 2000 "$a" 2> /dev/null | busybox grep -o '41 4e 44 52 4f 49 44 21')" -o ! -z "$(busybox hexdump -C -n 2000 "$a" | busybox grep -o 'e2 e1 f5 e0')" -o ! -z "$(busybox hexdump -C -n 2000 "$a" | busybox grep -o '10 20 f5 f2 ')" ]; then
												echo "$a"
												#fi
											done)

											set -- $v

											if [ ! -z "$v" ]; then
												clear
												echo
												echo ".....Выберите файл:"
												echo
												select menu in $v "Выход в главное меню"; do
													case $REPLY in
													[1-9]*)
														i="$#"
														let i=i+1
														file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
														if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
															clear
															. /data/local/binary/extract_key

															main_menu
															return
															break
														elif [ "$REPLY" == "$i" ]; then
															clear
															main_menu
															return
															break
														else
															clear
															echo
															echo "      Вводите цифры, соответствующие меню."
															extract_key
															return
															break
														fi
														break
														;;
													*)
														clear
														echo
														echo "      Вводите цифры, соответствующие меню."
														extract_key
														return
														break
														;;
													esac
												done
											else
												echo
												echo ....."В папке \"/$nd\" нет файлов \"*.img\""
												echo
												main_menu
												return
											fi
											echo
										else
											echo
											echo .....error: Ошибка перехода в директорию!
											echo
											echo Введите директорию правильно!
											echo
											extract_key
											return
										fi
										return
									}
									extract_key
									break
									;;
								4)
									clear
									gen_key() {
										v=$(echo "RSA2048" "RSA4096" "RSA8192")

										set -- $v
										echo
										echo ".....Выберите алгоритм для создания ключа:"
										echo
										select menu in $v "Выход в главное меню"; do
											case $REPLY in
											[1-9]*)
												i="$#"
												let i=i+1
												file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
												if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
													rs="$(echo "$file" | busybox sed 's!RSA!!')"
													out_gen_key=/data/local/UnpackerSystem/gen_keys
													mkdir "$out_gen_key" 2>/dev/null
													time="$(busybox date +%H_%M_%S)"
													clear
													echo
													echo ".....Создание ключей ${file}_${time}_private.pem и ${file}_${time}_pubkey.pem..."

													openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:"$rs" -outform PEM -out "$out_gen_key"/"$file"_${time}_private.pem &>/dev/null
													if [ $(echo $?) -eq 0 ]; then

														echo
														echo ".....Успешно создан "$file"_${time}_private.pem "
														echo ".....Сохранено: "$out_gen_key"/"$file"_${time}_private.pem"

														avbtool extract_public_key --key "$out_gen_key"/"$file"_${time}_private.pem --output "$out_gen_key"/"$file"_${time}_pubkey.pem
														if [ $(echo $?) -eq 0 ]; then
															sleep 1
															echo
															echo ".....Успешно создан "$file"_${time}_pubkey.pem"
															echo ".....Сохранено: "$out_gen_key"/"$file"_${time}_pubkey.pem"
															echo
														fi
													fi

													main_menu
													return
													break
												elif [ "$REPLY" == "$i" ]; then
													clear
													main_menu
													return
													break
												else
													clear
													echo
													echo "      Вводите цифры, соответствующие меню."
													gen_key
													return
													break
												fi
												break
												;;
											*)
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												gen_key
												return
												break
												;;
											esac
										done
										return
									}
									gen_key
									break
									;;
								5)
									clear
									. /data/local/binary/rem_key
									break
									;;
								6)
									clear
									. image_sign
									#main_menu
									break
									;;
								7)
									clear
									main_menu
									break
									;;
								8)
									clear
									break
									;;

								*)
									clear
									echo
									echo "      Вводите цифры, соответствующие этому меню."
									read_avb
									return
									break
									;;
								esac
							done
							return
						}
						read_avb
						break
						;;

					2)
						clear

						sin_img() {
							echo
							echo "..Перейдите в папку где находится файл \".sin\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
								v=$(busybox find . -maxdepth 1 -name '*.sin' 2>/dev/null | busybox sed 's!./!!')

								konv() {
									echo
									echo ".....Конвертация..."
									echo
									if [ ! -z "$(echo "$file" | busybox grep ".sin$")" ]; then

										name_sin="$(busybox basename ${file%%.*})"

										sony_dump "$PWD" "$file"
										if [ $(echo $?) -eq 0 ]; then
											num="$(busybox find -maxdepth 1 | busybox grep -Ev ".sin$|.crt$|.img$|.log$|.txt$" | busybox grep "$name_sin")"
											busybox mv -f "$num" "$name_sin"_sin.img && file=/"$nd"/"$name_sin"_sin.img
											echo
											echo ".....Успешно завершено!"
											echo ".....Получен файл $file"
											echo
										else
											echo
											echo ".....Error. Ошибка при конвертации!"
											echo
										fi
									fi
									return
								}

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												konv
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												sin_img
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											sin_img
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"/$nd\" нет файлов \".sin\"."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								sin_img
								return
							fi
							return
						}
						sin_img
						break
						;;

					3)
						clear
						echo
						echo "      Меню: Конвертация .lz4|.zst|.xz|.lzma"
						echo
						select img in "Извлечение из .lz4|.zst|.xz|.lzma" "Сжатие .img в .lz4|.zst|.xz|.lzma" "Выход в главное меню" "Завершение работы"; do
							case $REPLY in
							1)
								clear

								decomp_lz4() {
									echo
									echo "..Перейдите в папку где находится файл .lz4|.zst||.xz|.lzma, например: cd /sdcard"
									read b && $b
									if [ $(echo $?) -eq 0 ]; then
										clear
										dir_dat=/data/local/binary
										nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')

										#v=$(busybox find . -maxdepth 1 -name '*.lz4' 2> /dev/null | busybox sed 's!./!!')

										v=$(for fol in $(busybox find . -maxdepth 1 -name "*.lz4" -o -name "*.lzma" -o -name "*.zst" -o -name "*.xz" -type f); do
											mag="$(/data/local/binary/file -m /data/local/binary/magic "$fol" 2>/dev/null | busybox awk '{ print $2 }')"
											if [ "$mag" == "lzma" -o "$mag" == "lz4" -o "$mag" == "xz" -o ! -z "$(busybox hexdump -C -n 2000 "$fol" 2>/dev/null | busybox grep -o "28 b5 2f fd" 2>/dev/null)" ]; then
												echo "$fol"
											fi
										done)

										konv() {
											o="$(busybox basename $file)"
											o_name=${o%.*}
											file_or="$(echo "$file" | busybox sed 's!^./!!')"
											file_print="$(echo "$o_name" | busybox sed 's!^./!!')"
											echo
											echo ".....Извлечение из /$nd/$file_or..."
											echo
											#lz4 -df --no-sparse "$file"

											if [ -z "$(getprop ro.product.cpu.abilist64)" ]; then
												zstd32 -df "$file"
											else
												zstd64 -df "$file"
											fi

											if [ "$?" -eq "0" ]; then
												echo
												echo ".....Успешно завершено!"
												echo ".....Получен файл: /$nd/${file_print}"
												echo
												return
											else
												echo
												echo ".....Ошибка при извлечении!"
												echo
												return
											fi
											return
										}

										set -- $v

										if [ ! -z "$v" ]; then
											echo
											echo ".....Выберите файл для конвертации:"
											echo
											select menu in $v "Выход в главное меню"; do
												case $REPLY in
												[1-9]*)
													i="$#"
													let i=i+1
													file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
													if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
														clear
														konv
														main_menu
														return
														break
													elif [ "$REPLY" == "$i" ]; then
														clear
														main_menu
														return
														break
													else
														clear
														echo
														echo "      Вводите цифры, соответствующие меню."
														decomp_lz4
														return
														break
													fi
													break
													;;
												*)
													clear
													echo
													echo "      Вводите цифры, соответствующие меню."
													decomp_lz4
													return
													break
													;;
												esac
											done
										else
											echo
											echo ....."В папке \"/$nd\" нет файлов для извлечения."
											echo
											main_menu
											return
										fi
										echo
									else
										echo
										echo .....error: Ошибка перехода в директорию!
										echo
										echo Введите директорию правильно!
										echo
										decomp_lz4
										return
									fi
									return
								}
								decomp_lz4
								break
								;;
							2)
								clear

								comp_lz4() {
									echo
									echo "..Перейдите в папку где находится файл \".img\", например: cd /sdcard"
									read b && $b
									if [ $(echo $?) -eq 0 ]; then
										clear
										dir_dat=/data/local/binary
										nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
										v=$(busybox find . -maxdepth 1 -name '*.img' 2>/dev/null | busybox sed 's!./!!')

										konv() {
											clear
											if [ "$part_name" == "zst" ]; then
												part_name="zstd"
												part_print="zst"
											else
												part_name="$part_name"
												part_print="$part_name"
											fi
											echo
											echo ".....Сжатие в $part_print..."
											echo
											if [ -z "$(getprop ro.product.cpu.abilist64)" ]; then
												zstd32 --adapt --format="$part_name" -f "$file_conv"
											else
												zstd64 --adapt --format="$part_name" -f "$file_conv"
											fi
											if [ "$?" -eq "0" ]; then
												echo
												echo ".....Успешно завершено!"
												echo ".....Получен файл /$nd/${file_conv}.${part_print}"
												echo
												return
											else
												echo
												echo ".....Ошибка при конвертации!"
												echo
												return
											fi
											return
										}

										part_num() {
											clear
											v=$(echo "lz4" "zst" "xz" lzma)

											set -- $v
											echo
											echo ".....Выберите формат сжатия:"
											echo
											select menu in $v "Выход в главное меню"; do
												case $REPLY in
												[1-9]*)
													i="$#"
													let i=i+1
													file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
													if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then

														part_name="$file"

														konv
														return
														break
													elif [ "$REPLY" == "$i" ]; then
														clear
														#main_menu
														return
														break
													else
														clear
														echo
														echo "      Вводите цифры, соответствующие меню."
														part_num
														return
														break
													fi
													break
													;;
												*)
													clear
													echo
													echo "      Вводите цифры, соответствующие меню."
													part_num
													return
													break
													;;
												esac
											done
											return
										}

										set -- $v

										if [ ! -z "$v" ]; then
											#if [ "$#" -le "10" ]; then
											echo
											echo ".....Выберите файл для конвертации:"
											echo
											select menu in $v "Выход в главное меню"; do
												case $REPLY in
												[1-9]*)
													i="$#"
													let i=i+1
													file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
													if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
														clear
														file_conv="$file"
														part_num
														main_menu
														return
														break
													elif [ "$REPLY" == "$i" ]; then
														clear
														main_menu
														return
														break
													else
														clear
														echo
														echo "      Вводите цифры, соответствующие меню."
														comp_lz4
														return
														break
													fi
													break
													;;
												*)
													clear
													echo
													echo "      Вводите цифры, соответствующие меню."
													comp_lz4
													return
													break
													;;
												esac
											done
										else
											echo
											echo ....."В папке \"/$nd\" нет файлов \".img\" для сжатия."
											echo
											main_menu
											return
										fi
										echo
									else
										echo
										echo .....error: Ошибка перехода в директорию!
										echo
										echo Введите директорию правильно!
										echo
										comp_lz4
										return
									fi
									return
								}
								comp_lz4
								break
								;;
							3)
								clear
								main_menu
								break
								;;
							4)
								clear
								break
								;;
							esac
						done
						break
						;;
					4)
						clear

						resize_img() {
							blockcount=$(tune2fs -l ./$obraz | busybox awk '/Block count/ { print $3 }')
							size=$(stat -c %s ./$obraz)
							size_obraz=$(busybox expr $blockcount \* 4096)
							if [ -f ./$obraz ]; then
								busybox test "$size" -lt "$size_obraz"
								if [ "$?" -eq "0" ]; then
									busybox truncate -s $size_obraz ./$obraz
									echo " .....Получен образ \"$obraz\" с размером: $size_obraz байт."
									echo ".....Сохранено в /data/local/UnpackerQfil"
								else
									echo " .....Получен образ \"$obraz\" с размером: $size байт."
									echo ".....Сохранено в /data/local/UnpackerQfil"
								fi
							fi
						}

						qfil_img() {

							free_space="$(busybox df -h /data/local/UnpackerQfil | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
							echo
							echo "     Положите в папку: /data/local/UnpackerQfil все файлы \"super_xx|system_xx|vendor_xx|userdata_xx\" и все файлы \".xml\", начинающиеся на \"rawprogram*\", либо файлы  \"super|system|vendor.img_sparsechunk.*\"."
							echo
							echo "...В /data/local/UnpackerQfil свободно: $free_space"
							echo
							select img in "Склеить" "Выход в главное меню" "Завершение работы"; do
								case $REPLY in
								1)
									clear
									cd /data/local/UnpackerQfil
									>qfil.log
									#name_qfil="system_|vendor_|userdata_|.xml"
									if [ ! -z "$(busybox ls | busybox grep -E "super.img.*[0-9]|system_|vendor_|userdata_|.xml|chunk")" ]; then

										if [ ! -z "$(busybox ls *chunk* 2>/dev/null)" ]; then

											echo
											echo ".....Найдены файлы \"*sparsechunk*\""
											echo
											for name in "super" "system" "vendor" "product"; do
												#name1=$(busybox find . -name "${name}*sparsechunk.*[0-9]" -a ! -name "${name}*sparsechunk.*[0-9][0-9]" | sort -n)
												name1=$(find . -maxdepth 1 -name "${name}*chunk*" | sort -n | busybox grep -v "[0-9][0-9]")
												#name2=$(busybox find . -name "${name}*sparsechunk.*[0-9][0-9]" | sort -n)
												name2=$(find . -maxdepth 1 -name "${name}*chunk*" | sort -n | busybox grep "[0-9][0-9]")
												if [ ! -z "${name1}" ]; then
													mkdir ./output 2>/dev/null

													#name_out=$(echo $name1 | busybox sed 's!./!!' | busybox awk -F"img" '{ print $1 }')
													echo ".....Склейка ${name}_chunk.raw.img..."
													simg2img ${name1} ${name2} ./output/${name}_chunk.raw.img
													if [ "$?" -eq "0" ]; then
														#echo
														echo ".....Успешно создан файл ${name}_chunk.raw.img"
														echo ".....Сохранено в /data/local/UnpackerQfil/output"
														echo
													else
														echo
														echo ".....Ошибка при склейке ${name}_chunk.raw.img!"
														echo
													fi
												fi
											done

										elif [ ! -z "$(busybox ls super.img*[0-9] 2>/dev/null)" ]; then

											echo
											echo ".....Найдены файлы \"*sparsechunk*\""
											echo
											for name in "super"; do

												name1=$(find . -maxdepth 1 -name "super.img*[0-9]" | sort -n | busybox grep -v "[0-9][0-9]")

												name2=$(find . -maxdepth 1 -name "super.img*[0-9]" | sort -n | busybox grep "[0-9][0-9]")
												if [ ! -z "${name1}" ]; then
													mkdir ./output 2>/dev/null

													echo ".....Склейка ${name}_chunk.raw.img..."
													simg2img ${name1} ${name2} ./output/${name}_chunk.raw.img
													if [ "$?" -eq "0" ]; then
														#echo
														echo ".....Успешно создан файл ${name}_chunk.raw.img"
														echo ".....Сохранено в /data/local/UnpackerQfil/output"
														echo
													else
														echo
														echo ".....Ошибка при склейке ${name}_chunk.raw.img!"
														echo
													fi
												fi
											done
										fi

										#new str

										for name in "super" "system" "vendor" "userdata"; do
											obraz=$name.raw.img
											#rab_file=$(busybox find -name "rawprogram*" -exec busybox grep -rl "$name" {} \; | busybox sed 's!./!!' | busybox tail -1)

											busybox find -name "rawprogram*.xml" -exec busybox grep -rl "$name" {} \; | busybox sed 's!./!!' | while read a; do
												if [ "$(busybox cat "$a" | busybox grep "$name" | busybox wc -l)" -ge "3" ]; then
													echo "$a" >rab_file.txt
												fi
											done
											rab_file="$(busybox cat rab_file.txt 2>/dev/null)"

											#check_name="$(busybox cat $rab_file | busybox grep -o "${name}.*" | busybox head -1 | busybox awk '{print $1}' | busybox sed 's!"!!g')"

											#check_name="$(busybox cat $rab_file | busybox awk -v var="$name" -F"filename=" '$2 ~ var { print $2}' | busybox cut -d" " -f1 | busybox sed '1!d; s!"!!g')"

											if [ ! -z $rab_file ]; then
												check_name="$(busybox cat $rab_file | busybox awk -v var="$name" -F"filename=" '$2 ~ var { print $2}' | busybox cut -d" " -f1 | busybox sed '1!d; s!"!!g')"
												if [ -f ./$check_name ]; then
													echo
													echo ".....Найден файл ${rab_file}"
													echo ".....Склейка $obraz c использованием файла $rab_file..."
													python31 /data/local/binary/bin_system/qfil1.py /data/local/UnpackerQfil/"$rab_file" "$name"
													if [ "$?" -eq "0" ]; then
														obraz_real="/data/local/UnpackerQfil/$obraz"
														opla_r=$(busybox hexdump -C -n 20000 "$obraz_real" | busybox grep -o "30 50 4c 41")
														sparse_super_r=$(busybox hexdump -C -n 20000 "$obraz_real" | busybox grep -o "3a ff 26 ed")
														size_obraz_r="$(lpdump --slot=0 "$obraz_real" | busybox awk '/Size: / { print $2 }')"
														if [ ! -z "$opla_r" -a -z "$sparse_super_r" ]; then
															busybox truncate -s "$size_obraz_r" "$obraz_real"
															if [ "$?" -eq "0" ]; then
																echo
																echo " .....Получен образ \"$obraz\" с размером: $size_obraz_r байт."
																echo ".....Сохранено в /data/local/UnpackerQfil"
															else
																echo
																echo "Ошибка при корректировке размера $obraz"
																echo
															fi
														else
															resize_img
														fi
													else
														echo ".....Возникла ошибка"
														echo
													fi
												else
													echo
													echo ".....Нет файла \"$check_name\" в /data/local/UnpackerQfil" >>qfil.log
												fi
											else
												#clear
												echo
												echo ".....Нет нужного файла .xml в /data/local/UnpackerQfil" >>qfil.log
											fi
										done
									else
										echo
										echo ".....Нет файлов для склейки в /data/local/UnpackerQfil"
									fi
									main_menu
									break
									;;
								2)
									clear
									main_menu
									break
									;;
								3)
									clear
									break
									;;
								*)
									clear
									echo
									echo "      Вводите цифры, соответствующие этому меню."
									qfil_img
									break
									;;
								esac
							done
							return
						}
						qfil_img
						break
						;;
					5)
						clear
						split_super() {

							v=$(for a in $(busybox find . -maxdepth 1 -name '*.img' -type f | busybox sed 's!./!!'); do

								if [ ! -z "$(busybox hexdump -C -n 20000 "$a" | busybox grep -o "30 50 4c 41")" -o ! -z "$(busybox hexdump -C -n 2000 "$a" | grep -o "3a ff 26 ed")" ]; then
									echo "$a"
								fi
							done)

							set -- $v

							if [ ! -z "$v" ]; then
								echo
								echo ".....Выберите файл:"
								echo
								select menu in $v "Выход в главное меню"; do
									case $REPLY in
									[1-9]*)
										i="$#"
										let i=i+1
										file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
										if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
											clear

											if [ ! -z "$(getprop ro.product.cpu.abilist64)" ]; then
												if [ ! -z "$(busybox hexdump -C -n 2000 "$file" | grep -o "3a ff 26 ed")" ]; then

													echo
													echo "......Конвертация $file -> super.raw.img..."
													echo
													simg2img "$file" /data/local/UnpackerQfil/super.raw.img
													if [ "$?" -eq "0" ]; then
														file="super.raw.img"
														. /data/local/binary/ai
													else
														echo
														echo ".....Ошибка при конвертации $file"
														echo
													fi
												else
													. /data/local/binary/ai
												fi
											else
												echo
												echo ".....Разделение super.img не поддерживается на 32-битных прошивках!"
												echo
											fi
											main_menu
											return
											break
										elif [ "$REPLY" == "$i" ]; then
											clear
											main_menu
											return
											break
										else
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											split_super
											return
											break
										fi
										break
										;;
									*)
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										split_super
										return
										break
										;;
									esac
								done
							else
								echo
								echo ....."В папке \"/data/local/UnpackerQfil\" нет подходящего super.img для разделения."
								echo
								main_menu
								return
							fi
							return
						}

						split_selekt() {
							echo
							echo "...Положите super.img(raw), который надо разделить, в папку: /data/local/UnpackerQfil"

							free_space="$(busybox df -h /data/local/UnpackerQfil | busybox tail -1 | busybox awk '{ print $(NF-2) }')"
							echo
							echo "...В /data/local/UnpackerQfil свободно: $free_space"
							echo
							select img in "Разделить super.img" "Выход в главное меню" "Завершение работы"; do
								case $REPLY in
								1)
									clear
									cd /data/local/UnpackerQfil
									split_super
									#main_menu
									break
									;;
								2)
									clear
									main_menu
									break
									;;
								3)
									clear
									break
									;;
								*)
									clear
									echo
									echo "      Вводите цифры, соответствующие этому меню."
									split_selekt
									break
									;;
								esac
							done
							return
						}
						split_selekt
						break
						;;
					6)
						clear
						payload() {
							echo
							echo "         Извлечение из payload.bin     "
							echo
							echo "..Перейдите в папку где находится файл \"payload.bin\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')

								v=$(for a in $(busybox find . -maxdepth 1 -name '*.bin' -type f | busybox sed 's!./!!'); do

									if [ ! -z "$(busybox hexdump -C -n 20 "$a" | busybox grep -o "43 72 41 55")" ]; then
										echo "$a"
									fi
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												echo
												echo ".....Очистка /data/local/UnpackerPayload..."
												#echo
												busybox find /data/local/UnpackerPayload/* -maxdepth 1 ! -name "*.bin" -type f -exec busybox rm -f {} \; 2>/dev/null
												echo
												echo ".....Извлечение из /$nd/$file..."
												echo

												if [ -z "$(getprop ro.product.cpu.abilist64)" ]; then
													otadump="otadump7x32"
												else
													otadump="otadump7x64"
												fi

												"$otadump" -c 8 -o /data/local/UnpackerPayload "$file"
												if [ $(echo $?) -eq 0 ]; then
													clear
													echo
													echo ".....Образы успешно извлечены!"
													echo ".....Сохранено в /data/local/UnpackerPayload!"
													echo
												else
													echo
													echo ".....Ошибка при извлечении!"
													echo
													echo ".....Используем старый метод извлечения"
													echo ".....Извлечение из /$nd/$file..."
													echo

													busybox find /data/local/UnpackerPayload/* -maxdepth 1 ! -name "*.bin" -type f -exec busybox rm -f {} \; 2>/dev/null
													payload-dumper -c 8 -o /data/local/UnpackerPayload "$file"
													if [ $(echo $?) -eq 0 ]; then
														clear
														echo
														echo ".....Образы успешно извлечены!"
														echo ".....Сохранено в /data/local/UnpackerPayload!"
														echo
													else
														echo
														echo ".....Ошибка при извлечении!"
														echo
													fi
												fi
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												payload
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											payload
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"/$nd\" нет файлов \".bin\" для извлечения образов."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								payload
								return
							fi
							return
						}
						payload
						break
						;;

					7)
						clear
						update_app() {
							echo
							echo "         Извлечение из UPDATE.APP     "
							echo
							echo "..Перейдите в папку где находится файл \"*.app\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								#dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
								#v=$(busybox find . -maxdepth 1 -iname '*.app' 2> /dev/null | busybox sed 's!./!!')

								v=$(for a in $(busybox find . -maxdepth 1 -iname '*.app' -type f | busybox sed 's!./!!'); do

									if [ ! -z "$(busybox hexdump -C -n 100 "$a" | busybox grep -o "55 aa 5a a5")" ]; then
										echo "$a"
									fi
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												echo
												echo ".....Извлечение из /$nd/$file..."
												echo
												python31 /data/local/binary/bin_system/splitapp_v2.py -f "$file" -o /data/local/UnpackerUpdateApp

												if [ $(echo $?) -eq 0 ]; then
													cd /data/local/UnpackerUpdateApp
													napp=$(busybox find -name "super_[0-9].img" -type f | sort -n)
													if [ ! -z "$napp" ]; then
														echo
														echo ".....Склеиваем разбитый на части super.img..."
														simg2img ${napp} super.raw.img
														if [ $(echo $?) -eq 0 ]; then
															echo
															echo ".....Образы успешно извлечены!"
															echo ".....Сохранено в /data/local/UnpackerUpdateApp!"
															echo
														else
															echo
															echo ".....Ошибка при склеивании!"
															echo
														fi
													else
														echo
														echo ".....Образы успешно извлечены!"
														echo ".....Сохранено в /data/local/UnpackerUpdateApp!"
														echo
													fi
												else
													echo
													echo ".....Ошибка при извлечении!"
													echo
												fi
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												update_app
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											update_app
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"/$nd\" нет файлов \".app\" для извлечения образов."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								update_app
								return
							fi
							return
						}
						update_app
						break
						;;
					8)
						clear
						. /data/local/binary/mmm
						return
						main_menu
						return
						break
						;;
					9)
						clear
						my_ozip() {
							cd
							echo
							echo "...Перейдите в папку где находятся файлы: \".ozip\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								nd=$(echo $b | busybox awk '{ print $2 }')
								clear
								ss_ozip() {

									v=$(for a in $(busybox find . -maxdepth 1 -name '*.ozip' -type f | busybox sed 's!./!!'); do
										echo "$a"
									done)

									set -- $v
									if [ ! -z "$v" ]; then
										echo
										echo ".....Выберите файл:"
										echo
										select menu in $v "Выход в главное меню"; do
											case $REPLY in
											[1-9]*)
												i="$#"
												let i=i+1
												file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
												if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
													clear
													echo
													python31 /data/local/binary/bin_system/ozipdecrypt.py "$file"
													if [ $(echo $?) -eq 0 ]; then
														echo
														echo ".....Успешно завершено!"
														echo
													else
														echo
														echo ".....error: Возникла ошибка!"
														echo
													fi
													main_menu
													return
													break
												elif [ "$REPLY" -eq "$i" ]; then
													clear
													main_menu
													return
													break
												else
													clear
													echo
													echo "      Вводите цифры, соответствующие меню."
													ss_ozip
													return
													break
												fi
												break
												;;
											*)
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												ss_ozip
												return
												break
												;;
											esac
										done
									else
										echo
										echo ".....В папке \"$nd\" нет файлов \".ozip\"."
										echo
										main_menu
										return
									fi
									return
								}
								ss_ozip
							else
								echo
								echo ".....error: Ошибка перехода в директорию!"
								echo
								echo "Введите директорию правильно!"
								echo
								my_ozip
								return
							fi
							return
						}
						my_ozip
						break
						;;
					10)
						clear

						comp_md5() {
							echo
							echo "         Создание tar.md5     "
							echo
							echo "..Перейдите в папку где находится файл \"*.img\" или \"*.zip\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								dir_dat=/data/local/binary
								nd=$(echo $b | busybox awk '{ print $2 }')
								v=$(busybox find . -maxdepth 1 -name '*.img' -o -name '*.lz4' 2>/dev/null | busybox sed 's!./!!')

								set -- $v

								if [ ! -z "$v" ]; then
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												file_tar="$file".tar
												file_name="$(echo "$file" | busybox sed 's!\.[^.]*$!!')"
												busybox tar -cf "$file".tar "$file" && busybox md5sum "$file_tar" >>"$file_tar" && busybox mv "$file_tar" "$file_tar".md5
												if [ $(echo $?) -eq 0 ]; then
													echo
													echo ".....Успешно создан файл: "$file_tar".md5"
													echo
												else
													echo
													echo ".....Ошибка при создании "$file_tar".md5!"
													echo
												fi
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												comp_md5
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											comp_md5
											return
											break
											;;
										esac
									done
								else
									echo
									echo ....."В папке \"$nd\" нет файлов \".img\" для конвертации."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								comp_md5
								return
							fi
							return
						}
						comp_md5
						break
						;;
					11)
						clear

						rokchip_extract() {
							echo
							echo "         Распаковка прошивок .img     "

							rok_dir="/data/local/UnpackerSystem"

							echo
							echo "..Перейдите в папку где находится файл прошивки \".img\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
								echo
								echo ".....Поиск файлов..."

								v=$(for a in $(busybox find . -maxdepth 1 -name '*.img' -type f | busybox sed 's!./!!'); do

									if [ "$(busybox hexdump -C -n 300 "$a" | busybox grep -Eo "52 4b 46 57 66|52 4b 41 46|49 4d 41 47 45 57 54 59|56 19 b5 27")" ]; then
										echo "$a"
									fi
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									clear
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												name_rok="$(echo "$file" | busybox sed 's!.img$!!')"

												if [ -d "$rok_dir"/"$name_rok" -a "$rok_dir"/"$name_rok" != "$rok_dir"/ ]; then
													echo
													echo ".....Удаление старой папки: "$rok_dir"/"$name_rok""
													busybox rm -rf "$rok_dir"/"$name_rok"

												fi

												if [ "$(busybox hexdump -C -n 20 /"$nd"/"$file" | busybox grep -Eo "52 4b 46 57 66|52 4b 41 46")" ]; then

													echo
													echo ".....Detected Magic Rockchip..."
													echo
													echo ".....Извлечение из /$nd/$file..."
													echo
													if [ ! -z "$(busybox hexdump -C -n 20 /"$nd"/"$file" | busybox grep -o "52 4b 46 57 66")" ]; then
														busybox mkdir "$rok_dir"/"$name_rok" 2>/dev/null
														echo "rkfwf" >"$rok_dir"/"$name_rok"/conf

														busybox dd if="$file" of="$rok_dir"/"$name_rok"/tmpt bs=3000000 count=1 &>/dev/null
														VER="$(busybox strings "$rok_dir"/"$name_rok"/tmpt | busybox awk -F"\:" '/FIRMWARE_VER/ { print $2 }' | busybox awk -F"\." '{!$3} {$(NF+1)=0;} { print $1"."$2"."$3 }')"
														echo "rom_version: "$VER""
														busybox rm -f "$rok_dir"/"$name_rok"/tmpt
														img_unpack "$file" "$rok_dir"/"$name_rok"
														if busybox test -s "$rok_dir"/"$name_rok"/update.img; then
															cd "$rok_dir"/"$name_rok"
															afptool -unpack update.img .
															if busybox test -s "$(busybox find "$rok_dir"/"$name_rok" -name "parameter*" | busybox head -1)"; then
																echo
																echo ".....Образы успешно извлечены!"
																echo ".....Сохранено в "$rok_dir"/"$name_rok""
																echo
															else
																echo
																echo ".....Error! Ошибка при извлечении!"
																echo
															fi
														#fi
														else
															echo
															echo ".....Error! Ошибка при извлечении, нет update.img!"
															echo
														fi

													elif [ ! -z "$(busybox hexdump -C -n 20 /"$nd"/"$file" | busybox grep -o "52 4b 41 46")" ]; then
														busybox mkdir "$rok_dir"/"$name_rok" 2>/dev/null
														echo "rkaf" >"$rok_dir"/"$name_rok"/conf

														busybox cp -f /"$nd"/"$file" "$rok_dir"/"$name_rok"/update.img
														cd "$rok_dir"/"$name_rok"
														afptool -unpack update.img .
														if busybox test -s "$(busybox find "$rok_dir"/"$name_rok" -name "parameter*" | busybox head -1)"; then
															echo
															echo ".....Образы успешно извлечены!"
															echo ".....Сохранено в "$rok_dir"/"$name_rok""
															echo
														else
															echo
															echo ".....Error! Ошибка при извлечении!"
															echo
														fi
													fi

													busybox rm -f update.img
												elif [ "$(busybox hexdump -C -n 3000 /"$nd"/"$file" | busybox grep -o "49 4d 41 47 45 57 54 59")" ]; then
													clear
													echo
													echo ".....Detected Magic Alwinner..."
													echo
													echo ".....Извлечение из /$nd/$file..."
													echo
													busybox cp -f /"$nd"/"$file" "$rok_dir"/"$file"
													cd "$rok_dir"
													awimage "$file"
													if [ $(echo $?) -eq 0 ]; then
														busybox mv -f /"$rok_dir"/"$name_rok".img.dump /"$rok_dir"/"$name_rok"
														echo
														echo ".....Образы успешно извлечены!"
														echo ".....Сохранено в "$rok_dir"/"$name_rok""
														echo
														busybox rm -f "$file"
													else
														echo
														echo ".....Error! Ошибка при извлечении!"
														echo
													fi

												elif [ "$(busybox hexdump -C -n 3000 /"$nd"/"$file" | busybox grep -o "56 19 b5 27")" ]; then
													clear
													echo
													echo ".....Detected Magic Amlogic..."
													echo
													echo ".....Извлечение из /$nd/$file..."
													echo
													busybox mkdir "$rok_dir"/"$name_rok" 2>/dev/null
													aml_image_v2_packer -d /"$nd"/"$file" "$rok_dir"/"$name_rok"
													if [ $(echo $?) -eq 0 ]; then
														echo
														echo ".....Образы успешно извлечены!"
														echo ".....Сохранено в "$rok_dir"/"$name_rok""
														echo
													else
														echo
														echo ".....Error! Ошибка при извлечении!"
														echo
													fi
												fi

												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												rokchip_extract
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											rokchip_extract
											return
											break
											;;
										esac
									done
								else
									clear
									echo
									echo ....."В папке \"/$nd\" нет прошивок \".img\" для извлечения образов."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								rokchip_extract
								return
							fi
							return
						}

						rokchip_pack() {

							rok_dir="/data/local/UnpackerSystem"
							cd "$rok_dir"
							b=$(for a in $(busybox find -maxdepth 1 ! -name "." -type d | busybox sed 's!./!!'); do
								if busybox test -s "$a"/platform.conf; then
									echo "$a"
								fi
							done)

							set -- $b

							if [ ! -z "$b" ]; then
								echo
								echo ".....Выберите папку для сборки:"
								echo
								select menu in $b "Выход в главное меню" "Завершение работы"; do
									case $REPLY in
									[1-9]*)
										i="$#"
										j="$#"
										let i=i+1
										let j=j+2
										file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
										if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
											clear
											name_rok=$file
											if busybox test -s "$name_rok"/Image/parameter*; then
												busybox cp -f "$name_rok"/Image/parameter.txt "$name_rok"/parameter
												load="$(busybox grep "bootloader" "$name_rok"/package-file | busybox awk '{ print $2}')"
												for r in "29" "30" "31" "32" "33"; do
													rk_tmp="$(busybox cat "$name_rok"/parameter | busybox awk '/MACHINE:/ { print $2 }' | busybox grep -Eo '[0-9]{1,2}' | busybox head -1)"

													if [ "$rk_tmp" == "$r" ]; then
														rk_v="-rk$rk_tmp "
													fi
												done
												if [ ! -z "$load" ]; then
													clear
													echo
													echo ".....Сборка прошивки .img..."
													echo
													busybox sleep 2

													afptool -pack "$name_rok" update.new.img
													if [ $(echo $?) -eq 0 ]; then
														echo "img_maker "$rk_v""$name_rok"/"$load" update.new.img "$outdir"/"$name_rok"_new.img" >pack.sh
														chmod 755 ./pack.sh && ./pack.sh
														if [ $(echo $?) -eq 0 ]; then
															echo
															echo ".....Успешно создан "$outdir"/"$name_rok"_new.img"
															echo
														else
															echo
															echo ".....Ошибка при сборке общего образа!"
															echo
														fi
													else
														echo
														echo ".....Ошибка при сборке первичного образа!"
														echo
													fi
												else
													echo ".....Ошибка конфигурации!"
												fi
												busybox rm -f update.new.img pack.sh

											elif busybox test -s "$name_rok"/image.cfg; then
												echo
												echo ".....Сборка прошивки .img..."
												echo
												busybox sleep 2
												aml_image_v2_packer -r "$name_rok"/image.cfg "$rok_dir"/"$name_rok" "$outdir"/"$name_rok".new.img
												if [ $(echo $?) -eq 0 ]; then
													echo
													echo ".....Успешно создан "$outdir"/"$name_rok"_new.img"
													echo
												else
													echo
													echo ".....Ошибка при сборке общего образа!"
													echo
												fi
											fi
											main_menu
											return
											break
										elif [ "$REPLY" -eq "$i" ]; then
											clear
											main_menu
											return
											break
										elif [ "$REPLY" -eq "$j" ]; then
											clear
											return
											break
										else
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											rokchip_pack
											return
											break
										fi
										break
										;;
									*)
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										rokchip_pack
										return
										break
										;;
									esac
								done
							else
								echo
								echo ....."В \"$PWD\" нет папок для сборки."
								echo
								main_menu
								return
							fi
							return
						}

						menu_rok() {
							if [ ! -z "$(getprop ro.product.cpu.abilist64)" ]; then
								echo
								echo "         Распаковка прошивок .img     "
								echo
								select img in "Распаковать прошивку .img" "Выход в главное меню" "Завершение работы"; do
									case $REPLY in
									1)
										clear
										rokchip_extract
										break
										;;
									2)
										clear
										main_menu
										break
										;;
									3)
										clear
										break
										;;
									*)
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										echo
										menu_rok
										break
										;;
									esac
								done
							else
								echo
								echo ".....Работа пункта меню: \"Перепаковка прошивок .img\" не поддерживается на 32-битной прошивке!"
								echo
								main_menu
							fi
							return
						}
						menu_rok
						break
						main_menu
						break
						;;

					12)
						clear

						aa() {
							#m_name="$(busybox basename "$file" | busybox sed 's!.ofp$!!')"
							cd /data/local/UnpackerSystem
							if busybox test -s "$m_name"/super_map.csv; then
								v="$(busybox cat "$m_name"/super_map.csv | busybox awk -F"," '! /nv_text/ { print $1"-"$2 }')"
							elif busybox test -s "$m_name"/ProFile.xml; then
								v="$(busybox cat "$m_name"/ProFile.xml | busybox awk -F'"' '/<nv id/ { print $2"-"$4 }')"
							fi
							set -- $v
							echo
							echo ".....Выберите регион для склейки super.raw.img:"
							echo
							select menu in $v "Выход в главное меню"; do
								case $REPLY in
								[1-9]*)
									i="$#"
									let i=i+1
									file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
									if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
										if busybox test -s "$m_name"/super_map.csv; then
											ddd="$(echo "$file" | busybox sed 's!-!,!')"
											f_ext="$(busybox cat "$m_name"/super_map.csv | busybox grep "$ddd" | busybox awk -v a="$m_name" -F"," '! /nv_text/ { print a"/"$3" "a"/"$4" "a"/"$5 }')"

										elif busybox test -s "$m_name"/ProFile.xml; then
											f_ext="$(busybox cat "$m_name"/ProFile.xml | busybox awk -F'"' '/<nv id/ { print $2"-"$4" "$6" "$8" "$10 }' | busybox grep "$file" | busybox awk -v a="$m_name" '{ print a"/"$2" "a"/"$3" "a"/"$4 }')"
										fi
										f_out="super_"${file}".raw.img"
										echo "simg2img "$f_ext" "$m_name"/"$f_out"" >pack.sh

										clear
										echo
										echo ".....Склейка $f_out, Ждём..."
										chmod 755 ./pack.sh && ./pack.sh
										if [ $(echo $?) -eq 0 ]; then
											echo
											echo ".....Успешно завершено!"
											echo
											return
										else
											echo
											echo ".....Ошибка при склеивании super.raw.img!"
											echo
											return
										fi
										return
										break
									elif [ "$REPLY" -eq "$i" ]; then
										clear
										return
										break
									else
										clear
										echo
										echo "      Вводите цифры, соответствующие меню."
										aa
										return
										break
									fi
									break
									;;
								*)
									clear
									echo
									echo "      Вводите цифры, соответствующие меню."
									aa
									return
									break
									;;
								esac
							done
							return
						}

						ofp() {

							m_name="$(busybox basename "$file" | busybox sed -e 's!.ofp$!!; s!.ops$!!')"

							cd /data/local/UnpackerSystem
							mkdir "$m_name" 2>/dev/null
							>super_simg
							echo
							echo ".....Извлечение образов из "$file""
							echo ".....Ждём..."
							echo
							#python39 /data/local/binary/bin_oppo_decrypt/ofp_mtk_decrypt.py "$file" "$m_name" 1> log.txt
							#python39 /data/local/binary/bin_oppo_decrypt/ofp_qc_decrypt.py "$file" /"$ofp_dir"/"$m_name" 1>> log.txt
							#busybox cp -f log.txt "$m_name"/log.txt

							python31 /data/local/binary/OppoDecrypt-main -c mtk "$file" /"$ofp_dir"/"$m_name" 1>log.txt
							if [ -z "$(busybox cat log.txt | busybox tail -3 | busybox grep "ERROR")" -a -s log.txt ]; then
								echo
								echo ".....Образы успешно извлечены в /data/local/UnpackerSystem/$m_name"
								echo
								ofp_exit="10"
							else
								python31 /data/local//binary/OppoDecrypt-main -c qualcomm "$file" /"$ofp_dir"/"$m_name" 1>log.txt
								if [ -z "$(busybox cat log.txt | busybox tail -3 | busybox grep "ERROR")" -a -s log.txt ]; then
									echo
									echo ".....Образы успешно извлечены в /data/local/UnpackerSystem/$m_name"
									echo
									ofp_exit="10"
								else
									echo
									echo ".....Ошибка при извлечении!"
									echo
								fi
							fi

							busybox cp -f log.txt "$m_name"/log.txt

							#if [ ! -z "$(busybox cat log.txt | busybox grep -E "Files successfully|Done. Extracted")" ]; then
							#echo
							#echo ".....Образы успешно извлечены в /data/local/UnpackerSystem/$m_name"
							#echo
							#ofp_exit="10"
							#else
							#echo
							#echo ".....Ошибка при извлечении!"
							#echo
							#fi

							check_sup="$(busybox cat log.txt | busybox awk '/super.[0-9]/ { print $5 }' | busybox sed 's!"!!g')"
							if [ "$ofp_exit" == "10" -a ! -z "$check_sup" ]; then
								#>super_simg
								echo
								echo ".....Найден super.img, разбитый на части!"
								if [ "$check_pack" == "0" ]; then
									#i=0
									echo "$check_sup" | while read a; do
										#let i=i+1
										#f="$m_name/super."$i".img"
										f="$m_name/${a}"
										#echo -ne "$f " >> super_simg
										if [ ! -z "$(echo "$a" | busybox grep ".img")" ]; then
											echo -ne "$f " >>super_simg
										#busybox mv "$m_name"/"$a" "$f"
										else
											#busybox mv "$m_name"/"$a".img "$f"
											echo -ne "${f}.img " >>super_simg
										fi
									done

									echo
									echo ".....Склеиваем super.raw.img! Ждём..."

									echo "simg2img "$(busybox cat super_simg)"$m_name/super.raw.img" >super.sh
									if [ ! -z "$(busybox cat super.sh | busybox awk '/super/ { print $2 }')" ]; then
										chmod 755 super.sh && ./super.sh

										if [ $(echo $?) -eq 0 ]; then
											echo
											echo ".....Успешно завершено!"
											echo
										else
											echo
											echo ".....Ошибка при склеивании super.raw.img!"
											echo
										fi
									fi
								elif [ "$check_pack" == "1" -a -s "$m_name"/super_map.csv -o "$check_pack" == "1" -a -s "$m_name"/ProFile.xml ]; then
									aa
								else
									echo
									echo ".....Нет файла для склейки по регионам!"
									echo
								fi
							fi
							busybox rm -f super_simg super.sh log.txt pack.sh
							main_menu
							return
						}

						ofp_extract() {
							echo
							echo "         Распаковка прошивок .ofp|.ops     "

							ofp_dir="/data/local/UnpackerSystem"

							echo
							echo "..Перейдите в папку где находится файл прошивки \".ofp|.ops\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
								echo
								echo ".....Поиск файлов..."

								v=$(for a in $(busybox find . -maxdepth 1 -name '*.ofp' -o -name '*.ops' -type f | busybox sed 's!./!!'); do
									echo "$a"
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									clear
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $v "Выход в главное меню"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											let i=i+1
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												name_ofp="$(echo "$file" | busybox sed 's!.ofp$!!')"
												file=/"$nd"/"$file"

												if [ -d "$ofp_dir"/"$name_ofp" -a "$ofp_dir"/"$name_ofp" != "$ofp_dir"/ ]; then
													echo
													echo ".....Удаление старой папки: "$ofp_dir"/"$name_ofp""
													busybox rm -rf "$ofp_dir"/"$name_ofp"
												fi
												ofp
												return
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												ofp_extract
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											ofp_extract
											return
											break
											;;
										esac
									done
								else
									clear
									echo
									echo ....."В папке \"/$nd\" нет прошивок \".ofp|.ops\" для извлечения образов."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								ofp_extract
								return
							fi
							return
						}

						menu_ofp() {
							echo
							echo "         Распаковка прошивок .ofp|.ops     "
							echo
							select img in "Распаковать прошивку .ofp|.ops" "Выход в главное меню" "Завершение работы"; do
								case $REPLY in
								#1 ) #clear
								#check_pack=0
								#ofp_extract
								#break ;;
								1)
									clear
									check_pack=1
									ofp_extract
									#aa
									break
									;;
								2)
									clear
									main_menu
									return
									break
									;;
								3)
									clear
									break
									;;
								*)
									clear
									echo
									echo "      Вводите цифры, соответствующие меню."
									echo
									menu_ofp
									break
									;;
								esac
							done
							return
						}
						menu_ofp
						break
						main_menu
						break
						;;
					13)
						clear
						pac_extract() {
							echo
							echo "         Распаковка прошивок .pac     "

							pac_dir="/data/local/UnpackerSystem"

							echo
							echo "..Перейдите в папку где находится файл прошивки \".pac\", например: cd /sdcard"
							read b && $b
							if [ $(echo $?) -eq 0 ]; then
								clear
								nd=$(echo $b | busybox awk '{ print $2 }' | busybox sed 's!^/!!')
								echo
								echo ".....Поиск файлов..."

								v=$(for a in $(busybox find . -maxdepth 1 -name '*.pac' -type f | busybox sed 's!./!!'); do
									echo "$a"
								done)

								set -- $v

								if [ ! -z "$v" ]; then
									clear
									echo
									echo ".....Выберите файл:"
									echo
									select menu in $v "Выход в главное меню" "Завершение работы"; do
										case $REPLY in
										[1-9]*)
											i="$#"
											j="$#"
											let i=i+1
											let j=j+2
											file=$(echo "$@" | busybox cut -d' ' -f"$REPLY")
											if [ ! -z "$file" -a "$REPLY" -lt "$i" ]; then
												clear
												name_pac="$(echo "$file" | busybox sed 's!.pac$!!')"
												file=/"$nd"/"$file"

												if [ -d "$pac_dir"/"$name_pac" -a "$pac_dir"/"$name_pac" != "$pac_dir"/ ]; then
													echo
													echo ".....Удаление старой папки: "$pac_dir"/"$name_pac""
													busybox rm -rf "$pac_dir"/"$name_pac"
												fi
												echo
												echo "....Извлечение образов..."
												echo
												python31 /data/local/binary/pacextractor-test/python/pacExtractor.py -c "$file" "$pac_dir"/"$name_pac"
												if [ $(echo $?) -eq 0 ]; then
													echo
													echo ".....Образы успешно извлечены!"
													echo ".....Сохранено в "$pac_dir"/"$name_pac""
													echo
												#main_menu
												#return
												else
													echo
													echo "......Error...Ошибка при извлечении образов!"
													echo
												#main_menu
												#return
												fi
												#return
												main_menu
												return
												break
											elif [ "$REPLY" == "$i" ]; then
												clear
												main_menu
												return
												break
											elif [ "$REPLY" -eq "$j" ]; then
												clear
												return
												break
											else
												clear
												echo
												echo "      Вводите цифры, соответствующие меню."
												pac_extract
												return
												break
											fi
											break
											;;
										*)
											clear
											echo
											echo "      Вводите цифры, соответствующие меню."
											pac_extract
											return
											break
											;;
										esac
									done
								else
									clear
									echo
									echo ....."В папке \"/$nd\" нет прошивок \".pac\" для извлечения образов."
									echo
									main_menu
									return
								fi
								echo
							else
								echo
								echo .....error: Ошибка перехода в директорию!
								echo
								echo Введите директорию правильно!
								echo
								pac_extract
								return
							fi
							return
						}

						menu_pac() {
							echo
							echo "         Распаковка прошивок .pac     "
							echo
							select img in "Распаковать прошивку .pac" "Выход в главное меню" "Завершение работы"; do
								case $REPLY in
								1)
									clear
									pac_extract
									break
									;;
								2)
									clear
									main_menu
									return
									break
									;;
								3)
									clear
									break
									;;
								*)
									clear
									echo
									echo "      Вводите цифры, соответствующие меню."
									echo
									menu_pac
									break
									;;
								esac
							done
							return
						}
						menu_pac
						break
						main_menu
						break
						;;
					14)
						clear
						main_menu
						break
						;;
					15)
						clear
						break
						;;
					*) echo "Вводите цифру, соответствующую пунктам Меню: Прочие инструменты" ;;
					esac
				done
				return
			}
			my2
			break
			;;
		12)
			clear
			del_papka() {
				rm -rf $del
				mkdir $del
				chmod 755 $del

				echo
				echo " .....Выполнена очистка папки: $del"
				echo
				return
			}
			my9() {
				echo
				echo "      Меню: Очистка рабочих папок"
				echo
				echo -en "\E[31;47;1m"
				echo " Перед очисткой, переместите нужные файлы в другую папку! "
				echo -en "\E[37;0m"
				echo -en "\E[37;1m"
				echo
				select img in "Очистить папку: /data/local/UnpackerSystem" "Очистить папку: /data/local/UnpackerQfil" "Очистить папку: /data/local/UnpackerContexts" "Очистить папку: /data/local/UnpackerPayload" "Очистить папку: /data/local/UnpackerSuper" "Очистить папку: /data/local/UnpackerUpdateApp" "Очистить папку: /data/local/UnpackerPreloader" "Очистить сразу все папки" "Выход в главное меню" "Завершение работы"; do
					case $REPLY in
					1)
						clear
						del=/data/local/UnpackerSystem
						del_papka
						main_menu
						break
						;;
					2)
						clear
						del=/data/local/UnpackerQfil
						del_papka
						main_menu
						break
						;;
					3)
						clear
						del=/data/local/UnpackerContexts
						del_papka
						main_menu
						break
						;;
					4)
						clear
						del=/data/local/UnpackerPayload
						del_papka
						main_menu
						break
						;;
					5)
						clear
						del=/data/local/UnpackerSuper
						del_papka
						main_menu
						break
						;;
					6)
						clear
						del=/data/local/UnpackerUpdateApp
						del_papka
						main_menu
						break
						;;
					7)
						clear
						del=/data/local/UnpackerPreloader
						del_papka
						main_menu
						break
						;;
					8)
						clear
						del_dir=/data/local/Unpacker
						for del_all in "$del_dir"Contexts "$del_dir"System "$del_dir"Qfil "$del_dir"Payload "$del_dir"Super "$del_dir"UpdateApp "$del_dir"Preloader; do
							rm -rf $del_all
							mkdir $del_all
							chmod 755 $del_all
						done
						echo
						echo " .....Выполнена очистка всех рабочих папок."
						echo
						main_menu
						break
						;;
					9)
						clear
						main_menu
						break
						;;
					10)
						clear
						break
						;;
					*) echo "Вводите цифру, соответствующую пунктам меню: Очистка рабочих папок" ;;
					esac
				done
				return
			}
			my9
			break
			;;
		13)
			clear

			reb() {
				echo
				echo -ne "        Перезагрузка через 5 сек      \r"
				sleep 1
				echo -ne "         ..... 5 .....                \r"
				sleep 1
				echo -ne "          .... 4 ....                 \r"
				sleep 1
				echo -ne "           ... 3 ...                  \r"
				sleep 1
				echo -ne "            .. 2 ..                   \r"
				sleep 1
				echo -ne "             . 1 .                    \r"
				sleep 1
				echo -ne "                                      \r"
			}

			del_unpack() {
				echo
				echo -en "\E[31;47;1m"
				echo "     Удалить \"Unpacker Kitchen for Android\" с телефона?     "
				echo -en "\E[37;0m"
				echo -en "\E[37;1m"
				echo
				select img in "Да" "Нет,выйти в главное меню"; do
					case $REPLY in
					1)
						clear

						delit_uka="/data/adb/modules/UKA/uninstall.sh"
						if busybox test -s "$delit_uka"; then
							busybox chmod 755 "$delit_uka" && "$delit_uka"
							#if [ $(echo $?) -eq 0 ]; then

							reb
							reboot

						#else
						elif busybox test -f /data/local/binary/UninstallerUnpack.zip -a ! -f "$delit_uka"; then
							busybox mkdir /cache/recovery 2>/dev/null
							busybox chmod 755 /cache/recovery 2>/dev/null
							busybox cp -f /data/local/binary/UninstallerUnpack.zip /cache/recovery/UninstallerUnpack.zip
							echo "install /cache/recovery/UninstallerUnpack.zip" >/cache/recovery/openrecoveryscript
							busybox chmod 755 /cache/recovery/openrecoveryscript 2>/dev/null

							reb
							reboot recovery
						fi
						#fi
						#fi
						main_menu
						break
						;;
					2)
						clear
						main_menu
						break
						;;
					*)
						clear
						echo
						echo "      Вводите цифры, соответствующие этому меню."
						del_unpack
						break
						;;
					esac
				done
				return
			}
			del_unpack
			break
			;;

		14)
			clear
			break
			;;
		*) echo "Вводите цифру, соответствующую пунктам меню." ;;
		esac
	done
	return
}
main_menu
