FROM bitnami/spark:latest

LABEL description="Docker image with Spark (3.2.0) and Hadoop (3.3.1), based on bitnami/spark:latest. \
For more information, please visit https://github.com/s1mplecc/spark-hadoop-docker."

USER root

ENV HADOOP_HOME="/opt/hadoop"
ENV HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"
ENV HADOOP_LOG_DIR="/var/log/hadoop"
ENV PATH="$HADOOP_HOME/hadoop/sbin:$HADOOP_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="$HADOOP_HOME/lib/native"

WORKDIR /opt

RUN apt-get update && apt-get install -y openssh-server

RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

COPY hadoop-3.3.1.tar.gz hadoop-3.3.1.tar.gz
RUN tar -xzvf hadoop-3.3.1.tar.gz && \
	mv hadoop-3.3.1 hadoop && \
	rm -rf hadoop-3.3.1.tar.gz && \
	mkdir /var/log/hadoop

RUN mkdir -p /root/hdfs/namenode && \ 
    mkdir -p /root/hdfs/datanode 

COPY config/* /tmp/

RUN mv /tmp/ssh_config /root/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_CONF_DIR/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml && \
    mv /tmp/workers $HADOOP_CONF_DIR/workers

COPY start-hadoop.sh /opt/start-hadoop.sh

RUN chmod +x /opt/start-hadoop.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

RUN hdfs namenode -format
RUN sed -i "1 a /etc/init.d/ssh start > /dev/null &" /opt/bitnami/scripts/spark/entrypoint.sh

ENTRYPOINT [ "/opt/bitnami/scripts/spark/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/spark/run.sh" ]
