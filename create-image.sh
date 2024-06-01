#!/bin/bash

rundir="$(dirname "$(readlink -f "$0")")"

create_env(){
   set -e
   rm -rf "${rundir}/venv"
   python3 -m venv "${rundir}/venv"
   source "${rundir}/venv/bin/activate"
   pip install -r "${rundir}/requirements.txt"
   touch -r "${rundir}/requirements.txt" "${rundir}/venv/bin/activate"
   set +e
}

if ! [ -d "${rundir}/venv" ] ;then
   echo "Creating venv: ${rundir}/venv"
   echo
   create_env
elif [[ "$(perl -e 'print((stat(shift))[9])' "${rundir}/requirements.txt")" -gt "$(perl -e 'print((stat(shift))[9])' "${rundir}/venv/bin/activate")" ]];then
   echo "Recreating venv: ${rundir}/venv"
   echo
   create_env
else
   source "${rundir}/venv/bin/activate"
fi

cd "${rundir}" || exit 1
python3 ${rundir}/contrib/create-image.py "$@"
