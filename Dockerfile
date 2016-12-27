FROM sonnt/eclipse:v1.0.0
MAINTAINER sonnt
CMD sleep 5; echo "/opt/eclipse/eclipse" | bash - &>/dev/null&

