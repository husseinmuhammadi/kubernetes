
[DRAFT]

To change node node ip Address
edit `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
add the `--node-ip` flag to `KUBELET_CONFIG_ARGS`

```text
--node-ip=192.168.56.126
```

restart the kubelet service
```shell
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

