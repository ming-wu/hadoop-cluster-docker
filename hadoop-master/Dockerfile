FROM comp689/hadoop-base:1.0.0

# move all confugration files into container
COPY files/* /tmp/
RUN ls /usr/local/hadoop/
ENV HADOOP_INSTALL /usr/local/hadoop

RUN mkdir -p ~/hdfs/namenode && \ 
mkdir -p ~/hdfs/datanode && \
mkdir $HADOOP_INSTALL/logs

RUN mv /tmp/hdfs-site.xml $HADOOP_INSTALL/etc/hadoop/hdfs-site.xml 
RUN mv /tmp/core-site.xml $HADOOP_INSTALL/etc/hadoop/core-site.xml
RUN mv /tmp/mapred-site.xml $HADOOP_INSTALL/etc/hadoop/mapred-site.xml
RUN mv /tmp/yarn-site.xml $HADOOP_INSTALL/etc/hadoop/yarn-site.xml
RUN mv /tmp/slaves $HADOOP_INSTALL/etc/hadoop/slaves
RUN mv /tmp/start-hadoop.sh ~/start-hadoop.sh 
RUN mv /tmp/start-ssh.sh ~/start-ssh.sh 
RUN mv /tmp/run-wordcount.sh ~/run-wordcount.sh  

RUN chmod +x ~/start-hadoop.sh && \
chmod +x ~/run-wordcount.sh && \
chmod +x ~/start-ssh.sh && \
chmod 1777 tmp

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

EXPOSE 22 7373 7946 9000 50010 50020 50070 50075 50090 50475 8030 8031 8032 8033 8040 8042 8060 8088 50060

CMD '/root/start-ssh.sh'; 'bash'


