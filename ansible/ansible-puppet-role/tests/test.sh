#!/bin/sh
dir=`pwd`
cd ..
echo "Executing syntax check.\n"
ansible-playbook --syntax-check "$dir/playbook.yml"
echo "\nExecuting style check.\n"
ansible-lint "$dir/playbook.yml"
echo "\nExecuting smoke test.\n"
ansible-playbook -C -D "$dir/playbook.yml"
echo "\nExecuting acceptance test.\n"
cd $dir
#sudo molecule test
