#FROM ubuntu:xenial
FROM ubuntu_impala3.4.1

RUN mkdir -p /root/work
WORKDIR /root/work

# download
RUN apt update
RUN apt install -y openjdk-8-jdk ssh vim sudo wget
RUN wget -O - https://dlcdn.apache.org/hadoop/common/hadoop-3.2.4/hadoop-3.2.4.tar.gz | tar zxf -
RUN wget -O - https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz | tar zxf -
RUN wget -O - https://dlcdn.apache.org/tez/0.9.2/apache-tez-0.9.2-bin.tar.gz | tar zxf -

ARG JAVA_HOME
ARG HADOOP_HOME
ARG HIVE_HOME
ARG TEZ_HOME

# ssh
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys
RUN service ssh start && ssh-keyscan -t rsa localhost >> ~/.ssh/known_hosts

# hadoop
RUN ln -s /root/work/hadoop-3.2.4 $HADOOP_HOME
COPY ./hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY ./core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY ./mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY ./yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY ./hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# hive
RUN ln -s /root/work/apache-hive-3.1.3-bin $HIVE_HOME
COPY ./hive-site.xml $HIVE_HOME/conf/hive-site.xml

# tez
RUN ln -s /root/work/apache-tez-0.9.2-bin $TEZ_HOME
COPY ./tez-site.xml $TEZ_HOME/conf/tez-site.xml

# fix guava version conflict
RUN rm $HIVE_HOME/lib/guava-*
RUN cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-27.0-jre.jar $HIVE_HOME/lib/

COPY ./init.txt /root/work/init.txt
CMD /bin/bash

