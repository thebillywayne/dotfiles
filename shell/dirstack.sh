#!/usr/bin/env bash

dirstack() {

	local COMMAND="$1"

	_sort() {
		# sort dirstack
		dir_stack=$(printf "%s\n" $dir_stack | sort | tr "\n" " ")
	}

	_ds_to_file() {
		# write dirstack to ~/.dirstack
		_sort
		echo $dir_stack > ~/.dirstack
	}

	_echo_ds() {
		# print dirstack to screen
		printf "%s\n" "${dir_stack}" | tr "[:blank:]" "\n"
	}

	_export_ds() {
		# export new dir_stack to environment
		local new_ds="$@"
		dir_stack="$new_ds"
		_sort
		export dir_stack="$dir_stack"
	}


	case ${COMMAND} in
		"")
			_echo_ds ;;

		"push"|"p")
			grep "${PWD}" "${dir_stack}" >&/dev/null
			local EXISTS=$?

			if [[ "${EXISTS}" == 0 ]]
			then
				echo "The current directory ALREADY EXISTS in the stack."
			else
				if [[ -z "${dir_stack}" ]]; then
					_export_ds "$PWD"
					_echo_ds
					_ds_to_file
				else
					_export_ds "${dir_stack} ${PWD}"
					_echo_ds
					_ds_to_file
				fi
			fi
			;;

		"sel"|"s")
			PS3='cd to directory : '
			select DIR in ${dir_stack}
			do
				builtin cd "${DIR}"
				break
			done

			echo "Now in ${PWD}."
			/bin/ls
			;;

		"remove"|"r")

			PS3='remove directory #: '
			select DIR in ${dir_stack};
			do
				if [ "${REPLY}" == "1" ]; then
					_export_ds "${dir_stack/${DIR} /}"
					_ds_to_file
				else
					_export_ds "${dir_stack/ ${DIR}/}"
					_ds_to_file
				fi
				break
			done

			_echo_ds
			;;

		"clear"|"c")
			echo "This will clear the entire directory stack."
			read -p "Ctrl-c to abort." RESPONSE
			_export_ds ""
			_ds_to_file
			echo "dir_stack cleared"
			;;

		"backup"|"b")
			echo "Backing up stack to ~/.dirstack"
			_ds_to_file
			;;

		"restore"|"r")
			dir_stack="$( cat ~/.dirstack )"
			_echo_ds
			;;

		"help" | "h")
			echo "options are : "
			echo " push: alias='dp'"
			echo " sel: alias='ds'"
			echo " remove: alias = 'dr'"
			echo " clear: alias = 'dc'"
			echo " backup: alias = 'db'"
			echo " restore: alias = 'dres'"
			;;

		"*")
			echo "I don't know how to do that"
			echo "see dirstack help (dh)"
			;;

	esac
}

alias d='dirstack'
alias dp='dirstack p'
alias dh='dirstack h'
alias ds='dirstack s'
alias dr='dirstack r'
alias dc='dirstack c'
alias db='dirstack b'
alias dres='dirstack restore'
