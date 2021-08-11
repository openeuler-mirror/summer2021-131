Prepare the environment
```
sh prepare.sh
```
Start to tuning
```
atune-adm tuning --project memcached_memaslap --detail memcached_memaslap_client.yaml
```
Restore the environment
```
atune-adm tuning --restore --project memcached_memaslap
```