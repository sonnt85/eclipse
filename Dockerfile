FROM sonnt/eclipse:lastest
MAINTAINER sonnt
CMD sleep 5; echo "/opt/eclipse/eclipse" | bash - &>/dev/null&

