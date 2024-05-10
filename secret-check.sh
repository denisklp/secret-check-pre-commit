#!/bin/sh

install_dir="$HOME/.local/bin/"

#checks, if gitleaks is installed in system.
gitleaksInstalled() {
  gitleak_install=0
  if [ "$(gitleaks --version 2>&1 | grep 'not found' | wc -l)" = "0" ]; then
    gitleak_install=1
  elif [ -e "${install_dir}" ]; then
    if [ -e "${install_dir}gitleaks" ]; then
      gitleak_install=2
    fi
  else
    mkdir -p $install_dir
  fi
  echo "INFO: <gitleaksInstalled>: found(${gitleak_install})"
  return $gitleak_install
}

gitleaksCheck() {
  gitleak_result=0
  cur_ext=""
  cur_tar_ext="tar.gz"
  gitleak_url="https://github.com/gitleaks/gitleaks"
  target_os=$(uname -s | tr '[:upper:]' '[:lower:]')
  target_arch=$(uname -m | tr '[:upper:]' '[:lower:]')

  #for longer than 7 symbols OS type, we try to check if returned string contains one of known OS
  len_target_os=${#target_os}
  if [ $len_target_os -gt 7 ]; then
    if [ "$target_os#mingw64" != "$target_os" ]; then
      target_os="mingw64"
    elif [ "$target_os#darwin" != "$target_os" ]; then
      target_os="darwin"
    elif [ "$target_os#linux" != "$target_os" ]; then
      target_os="linux"
    fi
  fi

  #for each OS type gitleaks tags are being assigned on case basis. for windows extension is changed to .exe.
  echo "INFO: os=$target_os, arch=$target_arch"
  case "$target_os" in
    "linux" )                       current_os="linux";;
    "darwin" )                      current_os="darwin";;
    "mingw64" | "win" | "windows" ) current_os="windows"; cur_tar_ext="zip"; cur_ext=".exe";;
    * )                             current_os="unknown";;
  esac
  case "$target_arch" in
    "i386" | "i686" | "x32" | "x86" ) current_arch="x32";;
    "amd64" | "x86_64" )              current_arch="x64";;
    "arm64" | "aarch64" )             current_arch="arm64";;
    * )                               current_arch="unknown";;
  esac
  if [ "$current_os" = "unknown" -o "$current_arch" = "unknown" ]; then
    echo "WARN: Unable to determine system OS and/or Arch. Commit command will be stopped."
    exit 1
  fi

  #runs gitleaksInstalled function and performs gitleaks installation, if needed
  gitleaksInstalled
  gitleak_installed=$?
  if [ $gitleak_installed -eq 1 ]; then install_dir=""; fi
  if [ $gitleak_installed -eq 0 ]; then
    # install gitleaks into $install_dir
    tmp_dir=$(mktemp -d)
    gitleak_tag=$(curl -k -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
    if [ "${gitleak_tag}" = "" ]; then
      echo "WARN: get empty tag string. try to get tag via 'git fetch'"
      if [ "$(git remote -v | grep $gitleak_url | wc -l)" = "0" ]; then
        git remote add gitleaks $gitleak_url
      fi
      gitleak_tag=$(git fetch gitleaks --tags && git tag | sort -V | tail -1)
    fi
    gitleak_file_name="gitleaks_${gitleak_tag#v}_${current_os}_${current_arch}.${cur_tar_ext}"
    gitleak_file_url="${gitleak_url}/releases/download/${gitleak_tag}/${gitleak_file_name}"
    echo "INFO: Archive url: ${gitleak_file_url}"
    if [ $current_os = "windows" ]; then
      curl -k -o "${tmp_dir}/${gitleak_file_name}" -L $gitleak_file_url
      unzip "${tmp_dir}/${gitleak_file_name}" -d "${tmp_dir}"
    else
      curl -k -L $gitleak_file_url | tar -C $tmp_dir -xz
    fi
    cp "${tmp_dir}/gitleaks${cur_ext}" "$install_dir"
    rm -rf $tmp_dir
  fi

  #runs gitleaks checks using protect argument.
  "${install_dir}gitleaks${cur_ext}" protect -v --staged --redact
  if [ "$?" != "0" ]; then
    echo "
WARN: gitleaks has detected sensitive information in your changes.
To disable the gitleaks precommit hook run the following command:

    git config hooks.gitleaks disable"
    gitleak_result=1
  fi
  return $gitleak_result
}

gitleaksEnabled() {
  gitleak_config=$(git config hooks.gitleaks)
  if [ "$gitleak_config" = "enable" ]; then
    return 1
  fi
  return 0
}

echo "-= pre-commit hook check started =-"
gitleaksEnabled
if [ $? -eq 1 ]; then
  gitleaksCheck
  if [ $? -eq 1 ]; then exit 1; fi
else
  echo "INFO: gitleaks precommit hook disabled
(enable with 'git config hooks.gitleaks enable')"
fi
echo "-= pre-commit hook check ended=-"