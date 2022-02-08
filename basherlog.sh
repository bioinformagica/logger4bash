#!/usr/bin/env bash

function longest_string(){
  local max=0

  for word in "${@}";do 
    [ "${#word}" -ge "${max}" ] && max="${#word}"
  done
  
  echo "$max"

}

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

function set_logger (){
    local LOGGER_LEVEL="${LOGGER_LEVEL:-INFO}"
    local levels
    local is_printed
    local padding

    declare -A levels=(
        ['ERROR']=0
        ['WARNING']=1
        ['INFO']=2
        ['DEBUG']=3
    )

    padding="$( longest_string ${!levels[@]} )"

    for level in "${!levels[@]}";do
        is_printed=1
        [ "${levels[$level]}" -le "${levels[$LOGGER_LEVEL]}" ] && is_printed=0
        eval "shlog.${level,,} (){ shlog ${is_printed} ${padding} ${level}  \${*}; }"
    done

}

function main (){
    set_logger
    
    shlog.error "this is a test"
    shlog.warning "this is a test"
    shlog.info "this s a test"
    shlog.debug "this is a test"
}

[ "${BASH_SOURCE[0]}" == "${0}" ] && main "${@}"
