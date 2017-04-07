#!/bin/bash

if [ "$ICESCRUM_HTTPS" ]; then protocol="https"; else protocol="http"; fi

if [ -z "$ICESCRUM_HOST" ]; then host="localhost"; else host="$ICESCRUM_HOST"; fi

if [ -z "$ICESCRUM_PORT" ]; then
    port=":8080"
elif [ "$ICESCRUM_PORT" = "80" ] || ([ "$ICESCRUM_PORT" = "443" ] && [ "$protocol" = "https" ]); then
    port=""
else
    port=":$ICESCRUM_PORT"
fi

if [ -z "$ICESCRUM_CONTEXT" ]; then
    context="/icescrum"
    warName="icescrum"
elif [ "$ICESCRUM_CONTEXT" = "/" ]; then
    context=""
    warName="ROOT"
else
    context="/$ICESCRUM_CONTEXT"
    warName="$ICESCRUM_CONTEXT"
fi

url="${protocol}://${host}${port}${context}"
CATALINA_OPTS="$CATALINA_OPTS -Dicescrum.serverURL=$url"
CATALINA_OPTS="$CATALINA_OPTS -Dicescrum.environment=docker"
export CATALINA_OPTS
echo "iceScrum will be available at this URL: $url"

cp /icescrum/icescrum.war "${CATALINA_HOME}/webapps/${warName}.war"

mkdir -p /root/logs
mkdir -p /root/.icescrum

config_file="/root/.icescrum/config.groovy"
if [ ! -f "$config_file" ]; then
    mkdir -p /root/hsqldb
    echo "dataSource.url = 'jdbc:hsqldb:file:/root/hsqldb/prodDba;shutdown=true'\n" >> "$config_file"
fi

if [ ! -z "$ICESCRUM_SMTP_HOST" ]; then
    echo "grails.mail.host = '$ICESCRUM_SMTP_HOST'\n" >> "$config_file"
fi

if [ ! -z "$ICESCRUM_SMTP_PORT" ]; then
    echo "grails.mail.port = $ICESCRUM_SMTP_PORT\n" >> "$config_file"
fi

if [ ! -z "$ICESCRUM_SMTP_UNAME" ]; then
    echo "grails.mail.username = '$ICESCRUM_SMTP_UNAME'\n" >> "$config_file"
else
    echo "grails.mail.props = [\"mail.smtp.auth\":\"false\"]\n" >> "$config_file"
fi

if [ ! -z "$ICESCRUM_SMTP_PW" ]; then
    echo "grails.mail.password = '$ICESCRUM_SMTP_PW'\n" >> "$config_file"
fi