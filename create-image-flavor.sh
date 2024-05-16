#!/bin/bash

rundir="$(dirname "$(readlink -f "$0")")"

create_env(){
   set -e
   rm -rf "${rundir}/venv"
   python3 -m venv "${rundir}/venv"
   source "${rundir}/venv/bin/activate"
   pip install -r "${rundir}/requirements.txt"
   touch --reference "${rundir}/requirements.txt" "${rundir}/venv/bin/activate"
   set +e
}

if ! [ -d venv ] ;then
   echo "Creating venv: ${rundir}/venv"
   echo
   create_env
elif [[ "$(stat --format='%Y' "${rundir}/requirements.txt")" -gt "$(stat --format='%Y' "${rundir}/venv/bin/activate")" ]];then
   echo "Recreating venv: ${rundir}/venv"
   echo
   create_env
else
   source "${rundir}/venv/bin/activate"
fi

cd "${rundir}" || exit 1
"${rundir}/contrib/create-image-flavor.py" $@
