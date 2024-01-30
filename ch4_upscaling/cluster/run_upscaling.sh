#!/root/bash

echo 'changing directory'  
cd /home/groups/robertj2/ch4_upscaling/scripts

# convert the bash script from microsoft to unix
# to remove '/r'
sed -i 's/\r$//' submit.sh

bash submit.sh