

agent1=192.168.2.41
agent2=192.168.2.42
agent3=192.168.2.43


master1=192.168.2.32
user=ubuntu
certName=id_rsa


token=`ssh $user@$master1 "sudo cat /var/lib/rancher/rke2/server/token"`
echo -e "token: -------------- $token --------------------"
agents=($agent1 $agent2 $agent3)




# Step 7: Add Workers
for newnode in "${agents[@]}"; do
  ssh -tt $user@$newnode -i ~/.ssh/$certName sudo su <<EOF
  mkdir -p /etc/rancher/rke2
  touch /etc/rancher/rke2/config.yaml
  echo "token: $token" >> /etc/rancher/rke2/config.yaml
  echo "server: https://$master1:9345" >> /etc/rancher/rke2/config.yaml
  echo "node-label:" >> /etc/rancher/rke2/config.yaml
  echo "  - worker=true" >> /etc/rancher/rke2/config.yaml
  echo "  - longhorn=true" >> /etc/rancher/rke2/config.yaml
  curl -sfL curl -sfL https://rancher-mirror.rancher.cn/rke2/install.sh | INSTALL_RKE2_MIRROR=cn INSTALL_RKE2_TYPE="agent" sh -
  systemctl enable rke2-agent.service
  systemctl start rke2-agent.service
  exit
EOF
  echo -e " \033[32;5mMaster node joined successfully!\033[0m"
done