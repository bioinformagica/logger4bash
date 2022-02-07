#!/usr/bin/env bash

function fix_word_leght (){
  local lenght="${1}"
  local word="${2}"
  local difference

  [ "${#word}" -eq "$lenght" ] && {
    echo "$word"
    return
  }
  
  difference="$(( ${lenght}-${#word} ))"
  echo "$word$(printf ' %.0s' {1..$difference})"
}

function log(){
    local is_printed="${1}"
    local level="${2}"
    shift 2
    [ "${is_printed}" -eq 0 ] && {
      log_format_string="$(date '+%Y-%m-%d %H:%M:%S') | ${BASH_SOURCE[0]} | ${level} |"
      echo -e "${log_format_string} ${*}" >&2 
    }      
}

function set_logger (){
    local LOGGER_LEVEL="${LOGGER_LEVEL:-INFO}"
    local levels
    local is_printed

    declare -A levels=(
        ['ERROR']=0
        ['WARNING']=1
        ['INFO']=2
        ['DEBUG']=3
    )

    for level in "${!levels[@]}";do
        is_printed=1
        [ "${levels[$level]}" -le "${levels[$LOGGER_LEVEL]}" ] && is_printed=0
        eval "log.${level,,} (){ log ${is_printed} "$(fix_word_leght 7 ${level,,})" \${*}; }"
    done

}

function main (){
    set_logger
    
    log.error "this is a "
    log.warning "this is a "
    log.info "this s a "
    log.debug "this"
}

[ "${BASH_SOURCE[0]}" == "${0}" ] && main "${@}"
