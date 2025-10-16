#!/bin/bash
set -e

password_file=${BASH_SOURCE%/*}/ansible/roles/bootstrap/files/vault-password-file
echo "running ansible bootstrap playbook..."
if [ ! -f ${password_file} ]; then
  read -s -p "  ansible vault password: " ansible_vault_password
  touch ${password_file}
  chmod 600 ${password_file}
  echo "${ansible_vault_password}" > ${password_file}
fi

export ANSIBLE_INVENTORY=${BASH_SOURCE%/*}/ansible/hosts
export ANSIBLE_VAULT_PASSWORD_FILE=${password_file}
ansible-playbook ${BASH_SOURCE%/*}/ansible/bootstrap.yml
