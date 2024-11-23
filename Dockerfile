# Use a base image with Java installed (GeoServer requires Java)
FROM openjdk:8-jre

# Set environment variables for GeoServer
ENV GEOSERVER_VERSION=2.26.0 \
    GEOSERVER_HOME=/opt/geoserver \
    DATA_DIR=/opt/geoserver_data

# Create necessary directories
RUN mkdir -p $GEOSERVER_HOME $DATA_DIR

# Download and extract GeoServer
RUN curl -fsSL https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-bin.zip/download \
    -o geoserver.zip \
    && unzip geoserver.zip -d $GEOSERVER_HOME \
    && mv $GEOSERVER_HOME/geoserver-$GEOSERVER_VERSION/* $GEOSERVER_HOME/ \
    && rm -rf geoserver.zip $GEOSERVER_HOME/geoserver-$GEOSERVER_VERSION

# Download and install plugins
RUN PLUGINS="ysld h2 css authkey gdal oracle importer sldservice querylayer" \
    && for plugin in $PLUGINS; do \
        curl -fsSL https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$plugin-$GEOSERVER_VERSION.zip/download \
        -o $plugin.zip \
        && unzip $plugin.zip -d $GEOSERVER_HOME/webapps/geoserver/WEB-INF/lib/ \
        && rm -rf $plugin.zip; \
    done

# Set GeoServer as the working directory
WORKDIR $GEOSERVER_HOME

# Expose necessary ports (default GeoServer port is 8080)
EXPOSE 8080

# Set the entrypoint to start GeoServer
CMD ["sh", "bin/startup.sh"]
