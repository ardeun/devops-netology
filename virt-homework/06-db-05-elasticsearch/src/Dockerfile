FROM centos:7

RUN yum update -y &&\
    yum install wget -y && \
    yum install perl-Digest-SHA -y

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.3-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.3-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.3.3-linux-x86_64.tar.gz.sha512 && \ 
    tar -xzf elasticsearch-8.3.3-linux-x86_64.tar.gz && \
    mv elasticsearch-8.3.3  /usr/share/elasticsearch &&\
    rm elasticsearch-8.3.3-linux-x86_64.tar.gz


RUN adduser -m -u 1000 elasticsearch && \
    mkdir /var/lib/logs && \
    mkdir /var/lib/data && \
    mkdir /usr/share/elasticsearch/snapshots && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch && \
    chown -R elasticsearch:elasticsearch /var/lib/logs && \
    chown -R elasticsearch:elasticsearch /var/lib/data

WORKDIR /usr/share/elasticsearch

COPY elasticsearch.yml config/

ENV PATH /usr/share/elasticsearch/bin:$PATH \
    ES_HOME="/usr/share/elasticsearch" \
    ES_PATH_CONF="/usr/share/elasticsearch/config"

EXPOSE 9200 9300

USER elasticsearch
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]