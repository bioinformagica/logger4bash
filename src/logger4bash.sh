#!/usr/bin/env bash

##########################
# Returns the lenght of the longest
# level string.
# arg 1: One or more strings.
# output: Echos the lenght of the longest string.
function longest_string(){
  local max=0

  for word in "${@}";do 
    [ "${#word}" -ge "${max}" ] && max="${#word}"
  done
  
  echo "$max"

}

##########################
# Default log function
# arg 1 (int): Variable to sign if a log massage
#              will be printed (0) or not (1).
# arg 2 (int): Lenght of padding.]
# arg 2 (str): Log level ('ERROR', 'INFO', etc...)
# arg * (str): Log message.
# out:         None.
function shlog(){

    local is_printed="${1}"
    local padding="${2}"
    local level="${3}"
    shift 3
    local message="${*}"
    local datetime="$( date '+%Y-%m-%d %H:%M:%S' )"
    local current_file="${BASH_SOURCE[0]}"


    [ "${is_printed}" -eq 0 ] && { 
      
      printf '%s | %s | %-*s | %s\n' \
        "$datetime" \
        "$current_file" \
        "$padding" \
        "$level" \
        "$message" >&2     

    }      
}

function parse_args ()
{

  [ "$#" -eq 0 ] && {
    usage
    exit 0
  }

  declare -n args_handler="$1"
  shift

  while [ -n "$1" ];do
    case "$1" in

      *=* )
        args_handler["${1/=*}"]="${1/*=}"
        ;;

      * )
        args_handler["${1}"]="true"
    esac

    shift
  done
}

function setup_log_file ()
{
  local log_fname="${1}"
  local append="${2:-false}"

  case "${append}" in 

    'true'  )
      exec 2>>"${log_fname}"
      ;;

    'false' )
      exec 2>"${log_fname}"

  esac

}

##########################
# Function to genarete level  
# log functions (ex: shlog.error, shlog.info, ...).
# arg 1 (str):  Log level: ERROR, WARNING, 'INFO'(default) or 'DEBUG'.
# out        :  None
function setup_logger (){
    local logger_level="${__LOGGER_LEVEL:-INFO}"
    local levels
    local is_printed
    local padding

    declare -A levels=(
        ['ERROR']=0
        ['WARNING']=1
        ['INFO']=2
        ['DEBUG']=3
    )
    
    # parsing args
    declare -A args
    parse_args args "${@}"

    # Redirecting to a file
    [ "${args['to_file']}" ] && setup_log_file "${args['to_file']}" "${args['append_log']}"

    # Setting args logger level with an arg
    [ "${args['logger_level']}" ] && \
      [ "${level[${args[logger_level]}]}" ] && \
      __LOGGER_LEVEL="${level[${args[logger_level]}]}"

    padding="$( longest_string ${!levels[@]} )"
    
    # Dynamically create logger level functions: Ex shlog.error(), shlog.warning()
    for level in "${!levels[@]}";do
        is_printed=1
        [ "${levels[$level]}" -le "${levels[$logger_level]}" ] && is_printed=0
        eval "shlog.${level,,} (){ shlog ${is_printed} ${padding} ${level}  \${*}; }"
    done

}

function test (){
    setup_logger 'to_file=./teste_log.txt' 'append_log=true' 'logger_level=DEBUG'
    shlog.error "this is a test"
    shlog.warning "this is a test"
    shlog.info "this s a test"
    shlog.debug "this is a test"
}

[ "${BASH_SOURCE[0]}" == "${0}" ] && test "${@}"
