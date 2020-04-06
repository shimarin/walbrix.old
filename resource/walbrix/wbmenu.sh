#!/bin/sh
select item in "Linuxコンソール" "シャットダウン" "再起動" "メニューを終了";do
	case "$item" in
		"Linuxコンソール" )
			echo "コンソールを抜けるには exit と入力してください。"
			exit 9;;
		"シャットダウン" )
			poweroff;;
		"再起動" )
			reboot;;
		"メニューを終了" )
			exit 0;;
	esac
done
