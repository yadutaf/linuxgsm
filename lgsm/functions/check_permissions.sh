#!/bin/bash
# LGSM check_permissions.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="150316"

# Description: Checks script, files and folders ownership and permissions.

# Useful variables
currentuser="$(whoami)"
scriptfullpath="${rootdir}/${selfname}"
conclusionpermissionerror="0"

fn_check_ownership(){
# Check script ownership
if [ "${currentuser}" != "$(stat -c %U "${scriptfullpath}")" ] && [ "${currentuser}" != "$(stat -c %G "${scriptfullpath}")" ]; then
  fn_print_fail_nl "Oops ! Permission denied on ${selfname}"
  echo "	* To check allowed user and group run ls -l ${selfname}"
  exit 1
fi
# Check rootdir ownership
if [ "${currentuser}" != "$(stat -c %U "${rootdir}")" ] && [ "${currentuser}" != "$(stat -c %G "${rootdir}")" ]; then
  fn_print_fail_nl "Oops ! Permission denied on ${rootdir}"
  echo "	* To check allowed user and group run ls -l ${rootdir}"
  exit 1
}

fn_check_permissions(){
# Check rootdir permissions
if [ -n "${rootdir}" ]; then
  rootdirperm="$(stat -c %a "${rootdir}")"
  userrootdirperm="${rootdirperm:0:1}"
  grouprootdirperm="${rootdirperm:1:1}"
  if [ "${userrootdirperm}" != "7" ] && [ "${grouprootdirperm}" != "7" ]; then
    fn_print_fail_nl "Permission issues found in root directory"
    echo "  * Neither the user or group has full control of \"${rootdir}\""
    echo "  * You might wanna run : chmod -R 755 \"${rootdir}\""
    conclusionpermissionerror="1"
  fi
fi
  
# Check functions permissions
funcpermfail="0"
if [ -n "${functionsdir}" ]; then
  while read -r filename
    do
      funcperm="$(stat -c %a "${filename}")"
      userfuncdirperm="${funcperm:0:1}"
      groupfuncdirperm="${duncperm:1:1}"
      if [ "${userfuncdirperm}" != "7" ] && [ "${groupfuncdirperm}" != "7" ]; then
        funcpermfail="1"
        conclusionpermissionerror="1"
      fi
  done <<< "$(find "${functionsdir}" -name "*.sh")"
  
  if [ "${funcpermfail}" == "1" ]; then
    fn_print_fail_nl "Permission issues found in functions."
    echo "  * Neither the user or group has full control of at least some scripts in \"${functionsdir}\""
    echo "  * You might wanna run : chmod -R 755 \"${functionsdir}\""
  fi
fi
}

fn_check_permissions_conclusion(){
# Exit if errors found
if [ "${conclusionpermissionerror}" == "1" ]; then
  exit 1
fi
}

fn_check_ownership
fn_check_permissions
fn_check_permissions_conclusion